import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/views/global/story_insta/animations/animations.dart';
import 'package:sirkl/views/global/story_insta/camera/src/widgets/ui_handler.dart';
import 'package:sirkl/views/global/story_insta/drishya_picker.dart';
import 'package:sirkl/views/global/story_insta/editor/src/widgets/editor_builder.dart';

///
class EditorCloseButton extends StatelessWidget {
  ///
  const EditorCloseButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  Future<bool> _onPressed(BuildContext context, {bool pop = true}) async {
    if (!controller.value.hasStickers) {
      if (pop) {
        UIHandler.of(context).pop();
      }
      //  else {
      //   await UIHandler.showStatusBar();
      // }
      return true;
    } else {
      await showDialog<bool>(
        context: context,
        builder: (context) => const _AppDialog(),
      ).then((value) {
        if (value ?? false) {
          controller.clear();
        }
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onPressed(context, pop: false),
      child: EditorBuilder(
        controller: controller,
        builder: (context, value, child) {
          final crossFadeState = value.isEditing || value.hasFocus
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond;
          return AppAnimatedCrossFade(
            firstChild: const SizedBox(),
            secondChild: child!,
            crossFadeState: crossFadeState,
          );
        },
        child: InkWell(
          onTap: () {
            _onPressed(context);
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppDialog extends StatelessWidget {
  const _AppDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cancel = TextButton(
      onPressed: Navigator.of(context).pop,
      child: Text(
        'NO',
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: SColors.activeColor,
            ),
      ),
    );
    final unselectItems = TextButton(
      onPressed: () {
        Navigator.of(context).pop(true);
      },
      child: Text(
        'DISCARD',
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: SColors.activeColor,
            ),
      ),
    );

    return AlertDialog(
      title: Text(
        'Discard changes?',
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white70,
            ),
      ),
      content: Text(
        'Are you sure you want to discard your changes?',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Colors.grey.shade600,
            ),
      ),
      actions: [cancel, unselectItems],
      backgroundColor: Colors.grey.shade900,
      titlePadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ),
    );
  }
}
