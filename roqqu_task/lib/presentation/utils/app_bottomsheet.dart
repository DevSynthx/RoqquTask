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
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        builder: (BuildContext context) {
          return widget;
        });

    return res;
  }

  //  static Future<dynamic> showBottomsheet(BuildContext context,
  //     {required Widget widget,
  //     bool isDismissible = true,
  //     bool isScrollControlled = false,
  //     bool enableDrag = true}) async {
  //   final res = await showModalBottomSheet(
  //       enableDrag: true,
  //       isDismissible: true,
  //       backgroundColor: Colors.transparent,
  //       barrierColor: Colors.black.withValues(alpha: 0.2),
  //       context: context,
  //       isScrollControlled: true,
  //       useRootNavigator: true,
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(15), topRight: Radius.circular(15))),
  //       builder: (BuildContext context) {
  //         return BackdropFilter(
  //             filter: ImageFilter.blur(sigmaX: 0.8, sigmaY: 0.8),
  //             child: widget);
  //       });
  //   return res;
  // }
}
