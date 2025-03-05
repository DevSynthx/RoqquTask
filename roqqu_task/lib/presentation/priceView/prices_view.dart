import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:roqqu_task/app/app_color.dart';
import 'package:roqqu_task/app/theme/app_theme.dart';
import 'package:roqqu_task/core/extension/currency_extension.dart';
import 'package:roqqu_task/presentation/components/app_image.dart';
import 'package:roqqu_task/presentation/provider/market_data_provider.dart';
import 'package:roqqu_task/presentation/utils/app_spacer.dart';
import 'package:roqqu_task/presentation/utils/loading_view.dart';

class PricesView extends ConsumerStatefulWidget {
  const PricesView({super.key});

  @override
  ConsumerState<PricesView> createState() => _PricesViewState();
}

class _PricesViewState extends ConsumerState<PricesView> {
  @override
  Widget build(BuildContext context) {
    final tickerAsync = ref.watch(tickerProvider);
    return Container(
      color: context.isDark ? AppColors.containerColor : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Row(
                children: [
                  SvgPicture.asset(AppImage.cyptoIcon),
                  const Space(8),
                  const Text(
                    'BTC/USDT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Space(8),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
              Space(20),
              Text(
                tickerAsync.when(
                  data: (ticker) => ticker.lastPrice.toCurrency(),
                  loading: () => '\$0.00',
                  error: (_, __) => '\$0.00',
                ),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const Space(20),
          tickerAsync.when(
            data: (ticker) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PriceWidget(
                        title: '24h change',
                        icon: Icons.access_time,
                        color: Colors.green,
                        value:
                            '${ticker.priceChange.toStringAsFixed(2)} +${ticker.priceChangePercent.toStringAsFixed(2)}%'),
                  ),
                  CustomDivider(),
                  Space(10),
                  Expanded(
                    child: PriceWidget(
                        title: '24h high',
                        icon: Icons.arrow_upward,
                        value:
                            '${ticker.high24h.toStringAsFixed(2)} +${ticker.priceChangePercent.toStringAsFixed(2)}%'),
                  ),
                  CustomDivider(),
                  Space(10),
                  Expanded(
                    child: PriceWidget(
                        title: '24h low',
                        icon: Icons.arrow_downward,
                        value:
                            '${ticker.low24h.toStringAsFixed(2)} +${ticker.priceChangePercent.toStringAsFixed(2)}%'),
                  ),
                ],
              );
            },
            loading: () => LoadingView(
              count: 3,
              height: 50,
            ),
            error: (_, __) => LoadingView(
              count: 3,
              height: 50,
            ),
          ),
          const Space(10),
        ],
      ),
    );
  }
}

class PriceWidget extends StatelessWidget {
  const PriceWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 11, color: color),
        ),
      ],
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.grey);
  }
}
