import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sirkl/views/global/story_insta/editor/editor.dart';
import 'package:sirkl/views/global/story_insta/editor/src/widgets/background_switcher.dart';
import 'package:sirkl/views/global/story_insta/editor/src/widgets/editor_button_collection.dart';
import 'package:sirkl/views/global/story_insta/editor/src/widgets/editor_close_button.dart';
import 'package:sirkl/views/global/story_insta/editor/src/widgets/editor_shutter_button.dart';
import 'package:sirkl/views/global/story_insta/editor/src/widgets/editor_textfield.dart';

const _top = 16.0;

///
class EditorOverlay extends StatelessWidget {
  ///
  const EditorOverlay({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EditorValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            //

            // Textfield
            EditorTextfield(controller: controller),

            // Close button
            Positioned(
              left: 16,
              top: _top,
              child: EditorCloseButton(controller: controller),
            ),

            // Background changer
            Positioned(
              left: 16,
              bottom: 16,
              child: BackgroundSwitcher(controller: controller),
            ),

            // Screenshot capture button
            Positioned(
              right: 16,
              bottom: 16,
              child: EditorShutterButton(controller: controller),
            ),

            // Sticker buttons
            Positioned(
              right: 16,
              top: controller.value.isStickerPickerOpen ? 0.0 : _top,
              child: EditorButtonCollection(controller: controller),
            ),

            //
          ],
        );
      },
    );
  }
}
