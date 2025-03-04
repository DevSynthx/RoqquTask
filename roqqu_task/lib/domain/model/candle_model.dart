import 'package:equatable/equatable.dart';

class Candle extends Equatable {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  @override
  List<Object> get props => [time, open, high, low, close, volume];
}

class CandleModel extends Candle {
  const CandleModel({
    required super.time,
    required super.open,
    required super.high,
    required super.low,
    required super.close,
    required super.volume,
  });

  factory CandleModel.fromWebSocket(Map<String, dynamic> json) {
    final k = json['k'];
    return CandleModel(
      time: DateTime.fromMillisecondsSinceEpoch(k['t']),
      open: double.parse(k['o']),
      high: double.parse(k['h']),
      low: double.parse(k['l']),
      close: double.parse(k['c']),
      volume: double.parse(k['v']),
    );
  }
}
