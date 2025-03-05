import 'package:flutter/material.dart';
import 'package:roqqu_task/app/app_color.dart';
import 'package:roqqu_task/app/theme/app_theme.dart';
import 'package:roqqu_task/presentation/components/app_button.dart';
import 'package:roqqu_task/presentation/components/custom_tabbar.dart';
import 'package:roqqu_task/presentation/utils/app_bottomsheet.dart';
import 'package:roqqu_task/presentation/utils/app_spacer.dart';
import 'package:roqqu_task/presentation/widgets/no_open_order_view.dart';
import 'package:roqqu_task/presentation/widgets/order_form.dart';

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
      color: context.isDark ? AppColors.containerColor : Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: [
          CustomTabBar(
            tabController: _tabController,
            tabs: const [
              Tab(
                text: 'Open Orders',
              ),
              Tab(
                text: 'Positions',
              ),
            ],
          ),
          SizedBox(
            height: size.height * 0.20,
            child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: List.generate(2, (index) => NoOpenOrderView())),
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
      color: context.isDark ? AppColors.containerColor : Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                onPressed: () {
                  AppBottomSheet.showBottomsheet(context, widget: OrderForm());
                },
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
