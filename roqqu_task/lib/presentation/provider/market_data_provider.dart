import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roqqu_task/domain/model/order_book_model.dart';
import 'package:roqqu_task/domain/model/ticker_model.dart';
import 'package:roqqu_task/presentation/data_source_provider.dart';

class MarketConfig {
  final String symbol;
  final String interval;

  MarketConfig({required this.symbol, required this.interval});

  MarketConfig copyWith({String? symbol, String? interval}) {
    return MarketConfig(
      symbol: symbol ?? this.symbol,
      interval: interval ?? this.interval,
    );
  }
}

// Provider for market configuration
final marketConfigProvider = StateProvider<MarketConfig>((ref) {
  return MarketConfig(symbol: 'BTCUSDT', interval: '1m');
});

// Provider for orderbook
final orderbookProvider = StreamProvider<Orderbook>((ref) {
  final repository = ref.watch(binanceRepositoryProvider);
  final config = ref.watch(marketConfigProvider);

  return repository.getOrderbookStream(config.symbol);
});

// Provider for ticker
final tickerProvider = StreamProvider<Ticker>((ref) {
  final repository = ref.watch(binanceRepositoryProvider);
  final config = ref.watch(marketConfigProvider);

  return repository.getTickerStream(config.symbol);
});

// Convenience provider for current price
final currentPriceProvider = Provider<double>((ref) {
  final tickerValue = ref.watch(tickerProvider);

  return tickerValue.when(
    data: (ticker) => ticker.lastPrice,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Convenience provider for price change percentage
final priceChangePercentProvider = Provider<double>((ref) {
  final tickerValue = ref.watch(tickerProvider);

  return tickerValue.when(
    data: (ticker) => ticker.priceChangePercent,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// lib/presentation/providers/order_providers.dart

enum OrderSide { buy, sell }

enum OrderType { limit, market, stopLimit }

class OrderFormState {
  final OrderSide side;
  final OrderType type;
  final String price;
  final String amount;
  final bool isPostOnly;
  final String? error;

  const OrderFormState({
    required this.side,
    required this.type,
    required this.price,
    required this.amount,
    required this.isPostOnly,
    this.error,
  });

  double? get total {
    try {
      final priceValue = double.parse(price);
      final amountValue = double.parse(amount);
      return priceValue * amountValue;
    } catch (_) {
      return null;
    }
  }

  OrderFormState copyWith({
    OrderSide? side,
    OrderType? type,
    String? price,
    String? amount,
    bool? isPostOnly,
    String? error,
  }) {
    return OrderFormState(
      side: side ?? this.side,
      type: type ?? this.type,
      price: price ?? this.price,
      amount: amount ?? this.amount,
      isPostOnly: isPostOnly ?? this.isPostOnly,
      error: error,
    );
  }
}

// Provider for order form state
final orderFormProvider =
    StateNotifierProvider<OrderFormNotifier, OrderFormState>((ref) {
  return OrderFormNotifier(ref);
});

class OrderFormNotifier extends StateNotifier<OrderFormState> {
  final Ref ref;

  OrderFormNotifier(this.ref)
      : super(
          const OrderFormState(
            side: OrderSide.buy,
            type: OrderType.limit,
            price: '0.00',
            amount: '0.00',
            isPostOnly: false,
          ),
        );

  void initWithMarketPrice() {
    final currentPrice = ref.read(currentPriceProvider);
    if (currentPrice > 0) {
      state = state.copyWith(price: currentPrice.toStringAsFixed(2));
    }
  }

  void updateSide(OrderSide side) {
    state = state.copyWith(side: side, error: null);
  }

  void updateType(OrderType type) {
    state = state.copyWith(type: type, error: null);
  }

  void updatePrice(String price) {
    state = state.copyWith(price: price, error: null);
  }

  void updateAmount(String amount) {
    state = state.copyWith(amount: amount, error: null);
  }

  void togglePostOnly() {
    state = state.copyWith(isPostOnly: !state.isPostOnly, error: null);
  }

  bool validateForm() {
    try {
      final priceValue = double.parse(state.price);
      final amountValue = double.parse(state.amount);

      if (state.type != OrderType.market && priceValue <= 0) {
        state = state.copyWith(error: 'Price must be greater than 0');
        return false;
      }

      if (amountValue <= 0) {
        state = state.copyWith(error: 'Amount must be greater than 0');
        return false;
      }

      state = state.copyWith(error: null);
      return true;
    } catch (_) {
      state = state.copyWith(error: 'Invalid price or amount format');
      return false;
    }
  }

  Future<bool> placeOrder() async {
    if (!validateForm()) {
      return false;
    }

    try {
      // Here you would implement the actual order placement logic
      // For now, just simulate a successful order
      print(
          'Placing ${state.side} ${state.type} order: ${state.amount} @ ${state.price}');

      // Reset form after successful order
      state = state.copyWith(
        amount: '0.00',
        error: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to place order: $e');
      return false;
    }
  }
}

// Computed provider for total order value
final orderTotalProvider = Provider<double?>((ref) {
  final orderForm = ref.watch(orderFormProvider);
  return orderForm.total;
});

// Computed provider for form validity
final isOrderFormValidProvider = Provider<bool>((ref) {
  final orderForm = ref.watch(orderFormProvider);

  try {
    final priceValue = double.parse(orderForm.price);
    final amountValue = double.parse(orderForm.amount);

    // For market orders, we only need to validate amount
    if (orderForm.type == OrderType.market) {
      return amountValue > 0;
    }

    return priceValue > 0 && amountValue > 0;
  } catch (_) {
    return false;
  }
});
