import 'package:flutter/material.dart';
import 'package:sirkl/views/global/stream_chat/src/theme/channel_header_theme.dart';
import 'package:sirkl/views/global/stream_chat/src/utils/utils.dart';

/// {@template unreadMessagesSeparator}
/// {@endtemplate}
class UnreadMessagesSeparator extends StatelessWidget {
  /// {@macro unreadMessagesSeparator}
  const UnreadMessagesSeparator({
    super.key,
    required this.unreadCount,
  });

  /// Number of unread messages.
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xFF102437)
              : const Color.fromARGB(255, 247, 253, 255),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            context.translations.unreadMessagesSeparatorText(
              unreadCount,
            ),
            textAlign: TextAlign.center,
            style: StreamChannelHeaderTheme.of(context).subtitleStyle,
          ),
        ),
      ),
    );
  }
}
