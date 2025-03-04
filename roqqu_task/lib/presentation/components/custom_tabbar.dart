import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;
  final List<Tab> tabs;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? borderRadius;

  const CustomTabBar(
      {super.key,
      required this.tabController,
      required this.tabs,
      this.borderColor,
      this.height,
      this.borderRadius,
      this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(borderRadius ?? 7),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 2.9,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 5.w, vertical: 5),
        height: height ?? 40.h,
        width: MediaQuery.of(context).size.width,
        child: TabBar(
          isScrollable: false,
          controller: tabController,
          dividerColor: Colors.transparent,
          labelColor: Colors.black,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: Colors.white,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: Colors.black,
          ),
          unselectedLabelColor: Colors.black26,
          labelPadding: EdgeInsets.zero,
          indicatorPadding: EdgeInsets.zero,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            border: Border.all(color: borderColor ?? Colors.white),
            borderRadius: BorderRadius.circular(borderRadius ?? 7),
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
          tabs: tabs,
        ),
      ),
    );
  }
}
