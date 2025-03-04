import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roqqu_task/presentation/sample.dart';
import 'package:roqqu_task/presentation/trading_screen.dart';

void main() {
  runApp(ProviderScope(child: const CryptoTradingApp()));
}

class CryptoTradingApp extends StatelessWidget {
  const CryptoTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 800),
        minTextAdapt: true,
        ensureScreenSize: true,
        builder: ((context, child) {
          return MaterialApp(
            title: 'Crypto Trading App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: "Satoshi",
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
            ),
            home: const TradingScreen(),
            builder: (context, widget) {
              return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(0.98)),
                  child: widget!);
            },
          );
        }));
  }
}
