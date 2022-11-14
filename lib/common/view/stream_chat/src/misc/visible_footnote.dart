import 'package:flutter/material.dart';
import 'package:sirkl/common/view/stream_chat/src/misc/stream_svg_icon.dart';
import 'package:sirkl/common/view/stream_chat/src/theme/stream_chat_theme.dart';
import 'package:sirkl/common/view/stream_chat/src/utils/extensions.dart';

/// {@template streamVisibleFootnote}
/// Informs the user about a [StreamMessageWidget]'s visibility to the current
/// user.
///
/// Used in [StreamGiphyAttachment].
/// {@endtemplate}
class StreamVisibleFootnote extends StatelessWidget {
  /// {@macro streamVisibleFootnote}
  const StreamVisibleFootnote({super.key});

  @override
  Widget build(BuildContext context) {
    final chatThemeData = StreamChatTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamSvgIcon.eye(
          color: chatThemeData.colorTheme.textLowEmphasis,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          context.translations.onlyVisibleToYouText,
          style: chatThemeData.textTheme.footnote
              .copyWith(color: chatThemeData.colorTheme.textLowEmphasis),
        ),
      ],
    );
  }
}
