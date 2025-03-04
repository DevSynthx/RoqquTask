import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          SvgPicture.asset(AppImage.logo),
          const SizedBox(width: 8),
          const Text(
            'Sisyphus',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        SvgPicture.asset(
          AppImage.avatar,
          height: 25,
        ),
        Space(10),
        SvgPicture.asset(AppImage.globe),
        Space(10),
        SvgPicture.asset(
          AppImage.menu,
          height: 25,
        ),
        Space(10),
      ],
    );
  }
}
