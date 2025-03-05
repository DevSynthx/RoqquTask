import 'package:flutter/material.dart';

class AppBottomSheet {
  static Future<dynamic> showBottomsheet(BuildContext context,
      {required Widget widget,
      bool isDismissible = true,
      bool enableDrag = true}) async {
    var res = await showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.2),
        enableDrag: enableDrag,
        isScrollControlled: true,
        isDismissible: isDismissible,
        useRootNavigator: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (BuildContext context) {
          return widget;
        });

    return res;
  }
}
