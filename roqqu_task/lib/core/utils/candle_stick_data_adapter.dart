import 'package:candlesticks/candlesticks.dart';
import 'package:roqqu_task/domain/model/candle_model.dart' as domain;

extension CandleAdapter on domain.Candle {
  Candle toCandlesticksCandle() {
    return Candle(
      date: time,
      high: high,
      low: low,
      open: open,
      close: close,
      volume: volume,
    );
  }
}

//------> Utility function to convert a list of domain Candles to candlesticks
List<Candle> convertToCandlesticksList(List<domain.Candle> candles) {
  return candles.map((candle) => candle.toCandlesticksCandle()).toList();
}
