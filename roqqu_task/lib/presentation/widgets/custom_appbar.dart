import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:roqqu_task/app/app_color.dart';
import 'package:roqqu_task/app/theme/app_theme.dart';
import 'package:roqqu_task/app/theme/theme_state.dart';
import 'package:roqqu_task/presentation/components/app_image.dart';
import 'package:roqqu_task/presentation/utils/app_spacer.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? height;

  const CustomAppBar({
    super.key,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height ?? 60);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final themeModeState = ref.watch(themesModeProvider);
      return AppBar(
        backgroundColor:
            context.isDark ? AppColors.containerColor : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            SvgPicture.asset(
              AppImage.logo,
              colorFilter: ColorFilter.mode(
                  context.isDark ? Colors.white : AppColors.containerColor,
                  BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            const Text(
              'Sisyphus',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Switch(
              value: themeModeState == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themesModeProvider.notifier).changeTheme(value);
              }),
          Image.asset(
            AppImage.avatar,
            height: 30,
          ),
          Space(10),
          SvgPicture.asset(AppImage.globe, height: 30),
          Space(10),
          SvgPicture.asset(
            AppImage.menu,
            height: 30,
          ),
          Space(10),
        ],
      );
    });
  }
}
