import 'package:flutter/material.dart';
import 'package:sirkl/common/view/stream_chat/src/misc/stream_svg_icon.dart';
import 'package:sirkl/common/view/stream_chat/src/theme/stream_chat_theme.dart';
import 'package:sirkl/common/view/stream_chat/src/utils/utils.dart';

/// {@template flagMessageButton}
/// Allows a user to flag a message.
///
/// Used by [MessageActionsModal]. Should not be used by itself.
/// {@endtemplate}
class FlagMessageButton extends StatelessWidget {
  /// {@macro flagMessageButton}
  const FlagMessageButton({
    super.key,
    required this.onTap,
  });

  /// The callback to perform when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.iconFlag(
              color: streamChatThemeData.primaryIconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              context.translations.flagMessageLabel,
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }
}
