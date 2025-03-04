import 'package:flutter/widgets.dart';

class AppPadding {
  AppPadding._();

  static const EdgeInsetsGeometry c2 = EdgeInsets.symmetric(horizontal: 25);
  static const EdgeInsetsGeometry c3 =
      EdgeInsets.symmetric(horizontal: 20, vertical: 20);
  static const BorderRadius c4 = BorderRadius.all(Radius.circular(4));
  static const BorderRadius c6 = BorderRadius.all(Radius.circular(6));
  static const BorderRadius c8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius c12 = BorderRadius.all(Radius.circular(12));

  static const BorderRadius verticalV =
      BorderRadius.vertical(top: Radius.circular(20));
}

class AppBorderRadius {
  AppBorderRadius._();

  static const BorderRadius vertical =
      BorderRadius.vertical(top: Radius.circular(20));
  static const BorderRadius c4 = BorderRadius.all(Radius.circular(4));
  static const BorderRadius c6 = BorderRadius.all(Radius.circular(6));
  static const BorderRadius c12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius c16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius c18 = BorderRadius.all(Radius.circular(18));
  static const BorderRadius c25 = BorderRadius.all(Radius.circular(25));

  static const BorderRadius verticalV =
      BorderRadius.vertical(top: Radius.circular(20));
}
