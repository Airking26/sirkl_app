import 'package:flutter/material.dart';
import 'package:sirkl/common/view/story_insta/camera/src/controllers/cam_controller.dart';
import 'package:sirkl/common/view/story_insta/camera/src/widgets/camera_builder.dart';
import 'package:sirkl/common/view/story_insta/camera/src/widgets/ui_handler.dart';
///
class CameraCloseButton extends StatelessWidget {
  ///
  const CameraCloseButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final CamController controller;

  @override
  Widget build(BuildContext context) {
    return CameraBuilder(
      controller: controller,
      builder: (value, child) {
        if (value.hideCameraCloseButton) {
          return const SizedBox();
        }
        return child!;
      },
      child: InkWell(
        onTap: UIHandler.of(context).pop,
        child: Container(
          height: 36,
          width: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black26,
          ),
          child: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}
