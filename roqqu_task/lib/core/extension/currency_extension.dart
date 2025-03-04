import 'package:intl/intl.dart';

extension CurrencyFormat on num? {
  String toCurrency() {
    if (this == null) return '\$0.00';
    return '\$${NumberFormat('#,##0.00').format(this)}';
  }

  String toCompact() {
    if (this == null || this == 0) return '0';
    return NumberFormat.compact().format(this);
  }
}
