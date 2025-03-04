import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roqqu_task/presentation/candleView/candle_view.dart';
import 'package:roqqu_task/presentation/open_order_view.dart';
import 'package:roqqu_task/presentation/priceView/prices_view.dart';
import 'package:roqqu_task/presentation/utils/app_spacer.dart';
import 'package:roqqu_task/presentation/widgets/custom_appbar.dart';

class TradingScreen extends ConsumerStatefulWidget {
  const TradingScreen({super.key});

  @override
  ConsumerState<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends ConsumerState<TradingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: CustomAppBar(),
      body: Column(
        spacing: 10,
        children: [
          PricesView(),
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Column(
                spacing: 10,
                children: [
                  CandleView(),
                  OpenOrderView(),
                  Space(40),
                  BuyAndSellButton()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
