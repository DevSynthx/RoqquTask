// lib/core/utils/candle_data_adapter.dart
import 'package:candlesticks/candlesticks.dart';
import 'package:roqqu_task/domain/model/candle_model.dart' as domain;

// Extension method to convert our domain Candle to Candle for the candlesticks package
extension CandleAdapter on domain.Candle {
  Candle toCandlesticksCandle() {
    // Pass DateTime directly since that's what the package expects
    return Candle(
      date: time, // Pass DateTime directly, not milliseconds
      high: high,
      low: low,
      open: open,
      close: close,
      volume: volume,
    );
  }
}

// Utility function to convert a list of domain Candles to candlesticks Candles
List<Candle> convertToCandlesticksList(List<domain.Candle> candles) {
  return candles.map((candle) => candle.toCandlesticksCandle()).toList();
}
