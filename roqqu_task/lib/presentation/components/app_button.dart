import 'package:flutter/material.dart';
import 'package:roqqu_task/app/theme/app_color.dart';

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
        onPressed: onPressed,
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

class DepositButton extends StatelessWidget {
  const DepositButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.depositColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Deposit'),
      ),
    );
  }
}

class BtcGradientButton extends StatelessWidget {
  final VoidCallback onPressed;

  final double height;

  const BtcGradientButton({
    super.key,
    required this.onPressed,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF483BEB),
            Color(0xFF7847E1),
            Color(0xFFDD568D),
          ],
          stops: [0.0, 0.4792, 0.9635],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onPressed,
          splashColor: Colors.white.withValues(alpha: 0.1),
          child: const Center(
            child: Text(
              'Buy BTC',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
