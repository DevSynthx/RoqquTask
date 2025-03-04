import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roqqu_task/domain/model/order_book_model.dart';
import 'package:roqqu_task/presentation/provider/market_data_provider.dart';

class OrderBookScreen extends ConsumerWidget {
  const OrderBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderbookAsync = ref.watch(orderbookProvider);
    final ticker = ref.watch(tickerProvider);
    final currentPrice = ref.watch(currentPriceProvider);
    final priceChangePercent = ref.watch(priceChangePercentProvider);

    return Column(
      children: [
        // View mode selector
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.table_rows_outlined, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.view_week_outlined, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
              DropdownButton<String>(
                value: '10',
                items: const [
                  DropdownMenuItem(value: '10', child: Text('10')),
                  DropdownMenuItem(value: '20', child: Text('20')),
                  DropdownMenuItem(value: '50', child: Text('50')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),

        // Orderbook main view
        Expanded(
          child: orderbookAsync.when(
            data: (orderbook) => OrderBookViewx(
              buyOrders: _convertToOrderBookEntries(orderbook.bids),
              sellOrders: _convertToOrderBookEntries(orderbook.asks),
              spreadPrice: currentPrice,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }

  // Helper method to convert API model to UI model
  List<OrderBookEntry> _convertToOrderBookEntries(
      List<OrderbookEntry> entries) {
    // Calculate cumulative total for more accurate visualization
    double runningTotal = 0.0;

    return entries.map((entry) {
      runningTotal += entry.total;
      return OrderBookEntry(
        price: entry.price,
        amount: entry.amount,
        total: runningTotal, // Using cumulative total
      );
    }).toList();
  }
}

class OrderBookViewx extends StatelessWidget {
  final List<OrderBookEntry> buyOrders;
  final List<OrderBookEntry> sellOrders;
  final double spreadPrice;
  final bool isLoading;

  const OrderBookViewx({
    super.key,
    required this.buyOrders,
    required this.sellOrders,
    required this.spreadPrice,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'Price',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Amounts',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Total',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),

        // Sell orders (displayed in reverse order - highest price at top)
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: sellOrders.length,
            reverse: true,
            itemBuilder: (context, index) {
              final order = sellOrders[index];
              return _buildOrderRowx(
                context: context,
                price: order.price,
                amount: order.amount,
                total: order.total,
                isBuyOrder: false,
              );
            },
          ),
        ),

        // Spread indicator
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                spreadPrice.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Icon(
                Icons.arrow_upward,
                color: Colors.green,
                size: 16,
              ),
              Text(
                spreadPrice.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        // Buy orders
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: buyOrders.length,
            itemBuilder: (context, index) {
              final order = buyOrders[index];
              return _buildOrderRowx(
                context: context,
                price: order.price,
                amount: order.amount,
                total: order.total,
                isBuyOrder: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderRowx({
    required BuildContext context,
    required double price,
    required double amount,
    required double total,
    required bool isBuyOrder,
  }) {
    final Color textColor = isBuyOrder ? Colors.green : Colors.red;
    final Color bgColor = isBuyOrder
        ? Colors.green.withValues(alpha: 0.1)
        : Colors.red.withValues(alpha: 0.1);

    return Container(
      //height: 60,
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            right: 0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: MediaQuery.of(context).size.width *
                    (amount / _getMaxAmount()) *
                    0.5,
                decoration: BoxDecoration(
                  color: bgColor,
                ),
              ),
            ),
          ),

          // Order details
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    price.toStringAsFixed(2),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    amount.toStringAsFixed(6),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    total.toStringAsFixed(2),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to determine the maximum amount for scaling the background bars
  double _getMaxAmount() {
    double maxBuy = buyOrders.isNotEmpty
        ? buyOrders.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
        : 1.0;

    double maxSell = sellOrders.isNotEmpty
        ? sellOrders.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return maxBuy > maxSell ? maxBuy : maxSell;
  }
}

class OrderBookEntry {
  final double price;
  final double amount;
  final double total;

  OrderBookEntry({
    required this.price,
    required this.amount,
    required this.total,
  });
}
