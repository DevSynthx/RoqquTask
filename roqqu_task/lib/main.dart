import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roqqu_task/app/theme/app_theme.dart';
import 'package:roqqu_task/app/theme/theme_state.dart';
import 'package:roqqu_task/presentation/trading_screen.dart';

void main() {
  runApp(ProviderScope(child: const CryptoTradingApp()));
}

class CryptoTradingApp extends StatelessWidget {
  const CryptoTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final darkEnabled = ref.watch(themesModeProvider);
      return GestureDetector(
        onTap: () =>
            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(),
        child: ScreenUtilInit(
            designSize: const Size(360, 800),
            minTextAdapt: true,
            ensureScreenSize: true,
            builder: ((context, child) {
              return MaterialApp(
                title: 'Crypto Trading App',
                debugShowCheckedModeBanner: false,
                // theme: ThemeData(
                //   fontFamily: "Satoshi",
                //   primarySwatch: Colors.blue,
                //   scaffoldBackgroundColor: Colors.white,
                // ),
                theme: themeBuilder(ThemeData.light()),
                darkTheme: themeBuilder(ThemeData.dark()),
                themeMode: darkEnabled,
                home: const TradingScreen(),
                builder: (context, widget) {
                  return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaler: const TextScaler.linear(0.98)),
                      child: widget!);
                },
              );
            })),
      );
    });
  }
}
