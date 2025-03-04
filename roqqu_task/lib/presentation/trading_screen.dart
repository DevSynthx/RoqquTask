// lib/presentation/screens/trading_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:roqqu_task/core/extension/currency_extension.dart';
import 'package:roqqu_task/presentation/candleView/candle_view.dart';
import 'package:roqqu_task/presentation/open_order_view.dart';
import 'package:roqqu_task/presentation/priceView/prices_view.dart';
import 'package:roqqu_task/presentation/provider/market_data_provider.dart';
import 'package:roqqu_task/presentation/utils/app_spacer.dart';
import 'package:roqqu_task/presentation/widgets/custom_appbar.dart';

class TradingScreen extends ConsumerStatefulWidget {
  const TradingScreen({super.key});

  @override
  ConsumerState<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends ConsumerState<TradingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Space(10),
          PricesView(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Space(10),
                  CandleView(),
                  Space(10),
                  OpenOrderView(),
                  Space(50),
                  BuyAndSellButton()

                  // Expanded(
                  //   child: _buildTabContent(candlesAsync),
                  // ),
                  // _buildBottomSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderForm(OrderSide side) {
    // Set order side in the provider
    ref.read(orderFormProvider.notifier).updateSide(side);

    // Initialize with current market price
    ref.read(orderFormProvider.notifier).initWithMarketPrice();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => OrderFormWidget(
          scrollController: scrollController,
        ),
      ),
    );
  }
}

// Order form widget to be shown in the bottom sheet
class OrderFormWidget extends ConsumerWidget {
  final ScrollController scrollController;

  const OrderFormWidget({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderForm = ref.watch(orderFormProvider);
    final isValid = ref.watch(isOrderFormValidProvider);
    final currentPrice = ref.watch(currentPriceProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView(
        controller: scrollController,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => ref
                        .read(orderFormProvider.notifier)
                        .updateSide(OrderSide.buy),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orderForm.side == OrderSide.buy
                          ? Colors.green
                          : Colors.white,
                      foregroundColor: orderForm.side == OrderSide.buy
                          ? Colors.white
                          : Colors.black,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(8)),
                      ),
                    ),
                    child: const Text('Buy'),
                  ),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(orderFormProvider.notifier)
                        .updateSide(OrderSide.sell),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orderForm.side == OrderSide.sell
                          ? Colors.red
                          : Colors.white,
                      foregroundColor: orderForm.side == OrderSide.sell
                          ? Colors.white
                          : Colors.black,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.horizontal(right: Radius.circular(8)),
                      ),
                    ),
                    child: const Text('Sell'),
                  ),
                ],
              ),
              Row(
                children: [
                  _orderTypeButton(
                      context, ref, OrderType.limit, orderForm.type, 'Limit'),
                  _orderTypeButton(
                      context, ref, OrderType.market, orderForm.type, 'Market'),
                  _orderTypeButton(context, ref, OrderType.stopLimit,
                      orderForm.type, 'Stop-Limit'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormField(
            label: 'Limit price',
            hint: currentPrice > 0 ? currentPrice.toStringAsFixed(2) : '0.00',
            value: orderForm.price,
            onChanged: (value) =>
                ref.read(orderFormProvider.notifier).updatePrice(value),
            suffix: 'USD',
            enabled: orderForm.type != OrderType.market,
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Amount',
            hint: '0.00',
            value: orderForm.amount,
            onChanged: (value) =>
                ref.read(orderFormProvider.notifier).updateAmount(value),
            suffix: 'BTC',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Type', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'Good till cancelled',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Good till cancelled',
                      child: Text('Good till cancelled'),
                    ),
                    DropdownMenuItem(
                      value: 'Fill or Kill',
                      child: Text('Fill or Kill'),
                    ),
                    DropdownMenuItem(
                      value: 'Immediate or Cancel',
                      child: Text('Immediate or Cancel'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: orderForm.isPostOnly,
                onChanged: (value) =>
                    ref.read(orderFormProvider.notifier).togglePostOnly(),
              ),
              const Text('Post Only'),
              IconButton(
                icon: const Icon(Icons.info_outline, size: 16),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16)),
              Text(
                orderForm.total.toCurrency(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isValid
                ? () {
                    ref.read(orderFormProvider.notifier).placeOrder();
                    Navigator.pop(context);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  orderForm.side == OrderSide.buy ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              orderForm.side == OrderSide.buy ? 'Buy BTC' : 'Sell BTC',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (orderForm.error != null) ...[
            const SizedBox(height: 16),
            Text(
              orderForm.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total account value'),
              Row(
                children: [
                  Text('0.00'),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Open Orders'),
              const Text('0.00'),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Available'),
              const Text('0.00'),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  Widget _orderTypeButton(
    BuildContext context,
    WidgetRef ref,
    OrderType type,
    OrderType currentType,
    String label,
  ) {
    return ElevatedButton(
      onPressed: () => ref.read(orderFormProvider.notifier).updateType(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: type == currentType ? Colors.grey[300] : Colors.white,
        foregroundColor: type == currentType ? Colors.black : Colors.grey,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: TextStyle(fontSize: 12)),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required String value,
    required Function(String) onChanged,
    required String suffix,
    bool enabled = true,
  }) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            enabled: enabled,
            controller: TextEditingController(text: value)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: value.length),
              ),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hint,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixText: suffix,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
