import 'package:equatable/equatable.dart';

class OrderbookEntry extends Equatable {
  final double price;
  final double amount;
  final double total;
  final bool isBuy;

  const OrderbookEntry({
    required this.price,
    required this.amount,
    required this.total,
    required this.isBuy,
  });

  @override
  List<Object> get props => [price, amount, total, isBuy];
}

class Orderbook extends Equatable {
  final List<OrderbookEntry> bids;
  final List<OrderbookEntry> asks;

  const Orderbook({
    required this.bids,
    required this.asks,
  });

  @override
  List<Object> get props => [bids, asks];
}

class OrderbookEntryModel extends OrderbookEntry {
  const OrderbookEntryModel({
    required super.price,
    required super.amount,
    required super.total,
    required super.isBuy,
  });

  factory OrderbookEntryModel.fromList(List<dynamic> data, bool isBuy) {
    final price = double.parse(data[0]);
    final amount = double.parse(data[1]);

    return OrderbookEntryModel(
      price: price,
      amount: amount,
      total: price * amount,
      isBuy: isBuy,
    );
  }
}

class OrderbookModel extends Orderbook {
  const OrderbookModel({
    required super.bids,
    required super.asks,
  });

  factory OrderbookModel.fromWebSocket(Map<String, dynamic> json) {
    final bids = (json['bids'] as List)
        .map((bid) => OrderbookEntryModel.fromList(bid, true))
        .toList();

    final asks = (json['asks'] as List)
        .map((ask) => OrderbookEntryModel.fromList(ask, false))
        .toList();

    return OrderbookModel(bids: bids, asks: asks);
  }
}
