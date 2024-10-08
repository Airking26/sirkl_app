import 'package:flutter/material.dart';
import 'package:sirkl/views/global/stream_chat/src/misc/stream_svg_icon.dart';
import 'package:sirkl/views/global/stream_chat/src/theme/stream_chat_theme.dart';
import 'package:sirkl/views/global/stream_chat/src/utils/utils.dart';

/// {@template deleteMessageButton}
/// A button that allows a user to delete the selected message.
///
/// Used by [MessageActionsModal]. Should not be used by itself.
/// {@endtemplate}
class DeleteMessageButton extends StatelessWidget {
  /// {@macro deleteMessageButton}
  const DeleteMessageButton({
    super.key,
    required this.isDeleteFailed,
    required this.onTap,
  });

  /// Indicates whether the deletion has failed or not.
  final bool isDeleteFailed;

  /// The action (deleting the message) to be performed on tap.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.delete(
              color: Colors.red,
            ),
            const SizedBox(width: 16),
            Text(
              context.translations.toggleDeleteRetryDeleteMessageText(
                isDeleteFailed: isDeleteFailed,
              ),
              style: StreamChatTheme.of(context)
                  .textTheme
                  .body
                  .copyWith(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
