import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roqqu_task/presentation/components/app_button.dart';
import 'package:roqqu_task/presentation/utils/app_spacer.dart';

class OpenOrderView extends StatefulWidget {
  const OpenOrderView({super.key});

  @override
  State<OpenOrderView> createState() => _OpenOrderViewState();
}

class _OpenOrderViewState extends State<OpenOrderView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.w, right: 10.w),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 2.9,
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                padding:
                    EdgeInsets.only(left: 5.w, right: 5.w, top: 5, bottom: 5),
                height: 40.h,
                width: MediaQuery.of(context).size.width,
                child: TabBar(
                  isScrollable: false,
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.black,
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Colors.white),
                  unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Colors.black),
                  unselectedLabelColor: Colors.black26,
                  labelPadding: EdgeInsets.zero,
                  indicatorPadding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        spreadRadius: 0.2,
                        blurRadius: 3,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  tabs: const [
                    Tab(
                      text: 'Open Orders',
                    ),
                    Tab(
                      text: 'Positions',
                    ),
                  ],
                )),
          ),
          SizedBox(
            height: size.height * 0.20,
            child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  NoOpenOrderView(),
                  NoOpenOrderView(),
                ]),
          ),
        ],
      ),
    );
  }
}

class NoOpenOrderView extends StatelessWidget {
  const NoOpenOrderView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No Open Orders',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit. Id pulvinar nullam sit imperdiet pulvinar.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class BuyAndSellButton extends StatelessWidget {
  const BuyAndSellButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                onPressed: () {},
              ),
            ),
            Space(16),
            Expanded(
              child: AppButton(
                onPressed: () {},
                title: "Sell",
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
