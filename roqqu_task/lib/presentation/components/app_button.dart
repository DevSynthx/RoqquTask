import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String? title;
  final Color? color;
  final Function()? onPressed;
  const AppButton({super.key, this.title, this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
        onPressed: onPressed
        // final orderFormNotifier =
        //     ref.read(orderFormProvider.notifier);
        // orderFormNotifier.updateSide(OrderSide.buy);
        // orderFormNotifier.initWithMarketPrice();
        // Navigate to order form or show sheet

        // final orderFormNotifier =
        //     ref.read(orderFormProvider.notifier);
        // orderFormNotifier.updateSide(OrderSide.sell);
        // orderFormNotifier.initWithMarketPrice();
        // Navigate to order form or show sheet
        ,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title ?? 'Buy',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
