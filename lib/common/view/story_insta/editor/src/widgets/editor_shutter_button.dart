import 'package:sirkl/common/view/story_insta/drishya_picker.dart';
import 'package:sirkl/common/view/story_insta/animations/animations.dart';
import 'package:sirkl/common/view/story_insta/camera/src/widgets/ui_handler.dart';
import 'package:sirkl/common/view/story_insta/editor/src/widgets/widgets.dart';
import 'package:flutter/material.dart';

///
class EditorShutterButton extends StatelessWidget {
  ///
  const EditorShutterButton({
    Key? key,
    required this.controller,
    this.onSuccess,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  ///
  final ValueSetter<DrishyaEntity>? onSuccess;

  @override
  Widget build(BuildContext context) {
    return EditorBuilder(
      controller: controller,
      builder: (context, value, child) {
        final crossFadeState =
            (controller.currentBackground is GradientBackground &&
                        !value.hasStickers) ||
                    value.isEditing ||
                    value.hasFocus
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond;
        return AppAnimatedCrossFade(
          crossFadeState: crossFadeState,
          firstChild: const SizedBox(),
          secondChild: IgnorePointer(
            ignoring: crossFadeState == CrossFadeState.showFirst,
            child: InkWell(
              onTap: () async {
                if (controller.value.isColorPickerOpen) {
                  controller.updateValue(isColorPickerOpen: false);
                  return;
                }
                final uiHandler = UIHandler.of(context);

                final entity = await controller.completeEditing();
                if (entity != null) {
                  UIHandler.transformFrom = TransitionFrom.topToBottom;
                  if (onSuccess != null) {
                    onSuccess!(entity);
                  } else {
                    uiHandler.pop(entity);
                  }
                } else {
                  uiHandler.showSnackBar(
                    'Something went wront! Please try again.',
                  );
                }
              },
              child: Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.only(left: 4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Color(0xFF00CB7D),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
