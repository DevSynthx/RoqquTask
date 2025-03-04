import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roqqu_task/presentation/components/app_button.dart';
import 'package:roqqu_task/presentation/components/custom_tabbar.dart';
import 'package:roqqu_task/presentation/utils/app_bottomsheet.dart';
import 'package:roqqu_task/presentation/utils/app_spacer.dart';
import 'package:roqqu_task/presentation/utils/text_form.dart';

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
          Text(
            'No Open Orders',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit. Id pulvinar nullam sit imperdiet pulvinar.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.sp,
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

class OrderForm extends StatefulWidget {
  const OrderForm({super.key});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm>
    with SingleTickerProviderStateMixin {
  TextEditingController amount = TextEditingController();
  TextEditingController price = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  List<Tab> tabs = [
    Tab(
      text: "Buy",
    ),
    Tab(
      text: "Sell",
    )
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        padding: deviceWidth.viewInsets,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTabBar(
              height: 35,
              borderRadius: 10,
              borderColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              tabController: _tabController,
              tabs: tabs.toList(),
            ),
            const Space(16),
            TextFormInput(
              controller: price,
              suffix: '0.00 USD',
              prefix: "Limit",
            ),
            const Space(16),
            TextFormInput(
              controller: amount,
              suffix: '0.00 USD',
              prefix: "Amount",
            ),
            const Space(16),
            TextFormInput(
              controller: price,
              suffix: 'Good till cancelled',
              prefix: "Type",
              hasDropdown: true,
              readOnly: true,
            ),
            const Space(10),
            Row(
              children: [
                Checkbox(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    value: false,
                    onChanged: (value) {}),
                const Text('Post Only'),
                Space(10),
                const Icon(Icons.info_outline, size: 16),
              ],
            ),
            Space(15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total'),
                const Text('0.00'),
              ],
            ),
            const Space(20),
            BtcGradientButton(
              onPressed: () {},
            ),
            const Space(10),
            Divider(),
            const Space(10),
            TotalView(
              hasIcon: true,
            ),
            const Space(16),
            TotalView(
              title: "Open order",
            ),
            const Space(30),
            DepositButton()
          ],
        ),
      ),
    );
  }
}

class TotalView extends StatelessWidget {
  const TotalView({super.key, this.hasIcon = false, this.title});
  final bool hasIcon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title ?? 'Total account value'),
            const Text('0.00',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
        if (hasIcon) ...[
          Row(
            children: [
              Text('NGN'),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ] else ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'NGN',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }
}
