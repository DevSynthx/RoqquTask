import 'package:equatable/equatable.dart';

class Ticker extends Equatable {
  final String symbol;
  final double lastPrice;
  final double priceChange;
  final double priceChangePercent;
  final double high24h;
  final double low24h;
  final double volume24h;

  const Ticker({
    required this.symbol,
    required this.lastPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
  });

  @override
  List<Object> get props => [
        symbol,
        lastPrice,
        priceChange,
        priceChangePercent,
        high24h,
        low24h,
        volume24h
      ];
}

class TickerModel extends Ticker {
  const TickerModel({
    required String symbol,
    required double lastPrice,
    required double priceChange,
    required double priceChangePercent,
    required double high24h,
    required double low24h,
    required double volume24h,
  }) : super(
          symbol: symbol,
          lastPrice: lastPrice,
          priceChange: priceChange,
          priceChangePercent: priceChangePercent,
          high24h: high24h,
          low24h: low24h,
          volume24h: volume24h,
        );

  factory TickerModel.fromWebSocket(Map<String, dynamic> json) {
    return TickerModel(
      symbol: json['s'],
      lastPrice: double.parse(json['c']),
      priceChange: double.parse(json['p']),
      priceChangePercent: double.parse(json['P']),
      high24h: double.parse(json['h']),
      low24h: double.parse(json['l']),
      volume24h: double.parse(json['v']),
    );
  }
}
