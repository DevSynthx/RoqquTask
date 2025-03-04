import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class LoadingView extends StatelessWidget {
  final int count;
  final double height;
  final double width;
  final double mainHeight;
  const LoadingView(
      {super.key,
      this.count = 4,
      this.height = 50,
      this.width = 100,
      this.mainHeight = 50});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: mainHeight,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: SkeletonAvatar(
                style: SkeletonAvatarStyle(width: width, height: height),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class SingleLoader extends StatelessWidget {
  final double? height;
  final double? width;
  const SingleLoader({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return SkeletonAvatar(
      style: SkeletonAvatarStyle(width: width ?? 50, height: height ?? 20),
    );
  }
}
