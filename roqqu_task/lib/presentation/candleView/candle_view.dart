import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roqqu_task/app/app_color.dart';
import 'package:roqqu_task/app/theme/app_theme.dart';
import 'package:roqqu_task/presentation/tabs/charts_tab.dart';
import 'package:roqqu_task/presentation/tabs/order_book.dart';

class CandleView extends ConsumerStatefulWidget {
  const CandleView({super.key});

  @override
  ConsumerState<CandleView> createState() => _CandleViewState();
}

class _CandleViewState extends ConsumerState<CandleView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      color: context.isDark ? AppColors.containerColor : Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.w, right: 10.w),
            child: Container(
                decoration: BoxDecoration(
                  color: context.isDark
                      ? AppColors.scaffoldColor
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    if (!context.isDark) ...[
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 2.9,
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ]
                  ],
                ),
                padding:
                    EdgeInsets.only(left: 5.w, right: 5.w, top: 5, bottom: 5),
                height: 40.h,
                width: MediaQuery.of(context).size.width,
                child: TabBar(
                  isScrollable: false,
                  controller: _tabController,
                  unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Colors.black),
                  indicatorPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: context.isDark
                        ? AppColors.containerColor.withValues(alpha: 0.7)
                        : Colors.white,
                    boxShadow: [
                      if (!context.isDark) ...[
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.6),
                          spreadRadius: 0.2,
                          blurRadius: 3,
                          offset: const Offset(0, 0),
                        ),
                      ]
                    ],
                  ),
                  tabs: const [
                    Tab(
                      text: 'Charts',
                    ),
                    Tab(
                      text: 'Orderbook',
                    ),
                    Tab(
                      text: 'Recent trades',
                    )
                  ],
                )),
          ),
          SizedBox(
            height: size.height * 0.60,
            child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  CandleChart(),
                  OrderBookScreen(),
                  Container(
                    color: Colors.green,
                  )
                ]),
          ),
        ],
      ),
    );
  }
}
