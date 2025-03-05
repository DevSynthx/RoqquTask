import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roqqu_task/app/app_color.dart';

const Color _kPrimaryLightColor = AppColors.primaryColor;
const Color _kPrimaryDarkColor = Colors.white;
const Color _kBackgroundDarkColor = Color(0xFF262932);
const Color _kBackgroundWhiteColor = Colors.white;

const Color _scaffoldBackgroundDarkColor = Color(0xFF262932);
Color _scaffoldBackgroundlightColor = Colors.grey.shade200;
const double _kIconSize = 20.0;
const String kAppPrimaryFontFamily = 'Satoshi';

class AppColorTheme {
  const AppColorTheme._();
}

extension ThemeContextExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AppTheme extends ThemeExtension<AppTheme> {
  const AppTheme._();

  final AppColorTheme color = const AppColorTheme._();

  @override
  ThemeExtension<AppTheme> copyWith() => this;

  @override
  ThemeExtension<AppTheme> lerp(ThemeExtension<AppTheme>? other, double t) =>
      this;
}

ThemeData themeBuilder(
  ThemeData defaultTheme, {
  AppTheme appTheme = const AppTheme._(),
}) {
  final Brightness brightness = defaultTheme.brightness;
  final bool isDark = brightness == Brightness.dark;

  //Style App Color Scheme
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    secondary: isDark ? _kPrimaryDarkColor : _kPrimaryLightColor,
    seedColor: isDark ? _kPrimaryDarkColor : _kPrimaryLightColor,
    primary: isDark ? _kPrimaryDarkColor : _kPrimaryLightColor,
    surface: Colors.white,
    surfaceTint: isDark ? _kPrimaryDarkColor : _kPrimaryLightColor,
    brightness: brightness,
  );

  final Color scaffoldBackgroundColor =
      isDark ? _scaffoldBackgroundDarkColor : _scaffoldBackgroundlightColor;

  //Style TextInput Color
  const OutlineInputBorder textFieldBorder = OutlineInputBorder(
    borderSide: BorderSide.none,
  );
  final OutlineInputBorder textFieldErrorBorder = textFieldBorder.copyWith(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(width: 0.5, color: AppColors.textField));

  /// FocusedBorder
  final OutlineInputBorder focusedBorder = textFieldBorder.copyWith(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(width: 0.5, color: AppColors.primaryColor));

  /// disabledBorder
  final OutlineInputBorder disabledBorder = textFieldBorder.copyWith(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(width: 0.5, color: AppColors.textField));

  //Style Text textstyle
  final TextTheme textTheme = defaultTheme.textTheme.copyWith(
    bodyMedium: TextStyle(
        fontSize: 12.sp,
        color: isDark ? _kPrimaryDarkColor : _kPrimaryLightColor,
        fontFamily: kAppPrimaryFontFamily,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.0),
    bodySmall: TextStyle(
        fontSize: 12.sp,
        color: isDark ? _kPrimaryDarkColor : _kPrimaryLightColor,
        fontFamily: kAppPrimaryFontFamily,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.0),
  );

  final tabBarTheme = defaultTheme.tabBarTheme.copyWith(
    dividerColor: Colors.transparent,
    labelPadding: EdgeInsets.zero,
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: isDark ? Colors.white : AppColors.primaryColor,
    unselectedLabelColor: Colors.grey,
    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    unselectedLabelStyle: const TextStyle(fontSize: 14),
  );

//Style AppBar
  final AppBarTheme appBarTheme = defaultTheme.appBarTheme.copyWith(
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
  //Style button textstyle
  final TextStyle? buttonTextStyle = textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 13,
      color: isDark ? _kBackgroundWhiteColor : _kBackgroundDarkColor);

  //Style hintTextStyle
  final TextStyle? hintTextStyle = textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.normal,
      fontSize: 14.sp,
      color: AppColors.textField);
  final ButtonStyle buttonStyle = ButtonStyle(
    textStyle: WidgetStateProperty.all(buttonTextStyle),
    elevation: WidgetStateProperty.all(0),
  );

  return ThemeData(
    useMaterial3: true,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      foregroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      disabledForegroundColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30).r,
      ),
      elevation: 0,
    )),
    appBarTheme: appBarTheme,
    iconTheme: defaultTheme.iconTheme
        .copyWith(size: _kIconSize, color: AppColors.primaryColor),
    textTheme: defaultTheme.textTheme.merge(textTheme),
    primaryTextTheme: defaultTheme.primaryTextTheme.merge(textTheme),
    shadowColor: colorScheme.scrim,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    textButtonTheme: TextButtonThemeData(style: buttonStyle),
    filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: colorScheme.onPrimary,
      foregroundColor: colorScheme.onSurface,
    ),
    colorScheme: colorScheme,
    tabBarTheme: tabBarTheme,
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: hintTextStyle,
      labelStyle: hintTextStyle,
      disabledBorder: disabledBorder,
      border: disabledBorder,
      focusedBorder: focusedBorder,
      enabledBorder: disabledBorder,
      errorBorder: textFieldErrorBorder,
      focusedErrorBorder: textFieldErrorBorder,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      filled: false,
    ),
    fontFamily: kAppPrimaryFontFamily,
  );
}
