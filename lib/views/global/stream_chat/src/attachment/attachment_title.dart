import 'package:flutter/material.dart';
import 'package:sirkl/views/global/stream_chat/src/theme/message_theme.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

/// {@template attachmentTitle}
/// Title for attachments
/// {@endtemplate}
class StreamAttachmentTitle extends StatelessWidget {
  /// {@macro attachmentTitle}
  const StreamAttachmentTitle({
    super.key,
    required this.attachment,
    required this.messageTheme,
  });

  /// Theme to apply to text
  final StreamMessageThemeData messageTheme;

  /// Attachment data to display
  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    final ogScrapeUrl = attachment.ogScrapeUrl;
    return GestureDetector(
      onTap: () {
        final ogScrapeUrl = attachment.ogScrapeUrl;
        if (ogScrapeUrl != null) launchURL(context, ogScrapeUrl);
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (attachment.title != null)
              Text(
                attachment.title!,
                overflow: TextOverflow.ellipsis,
                style: messageTheme.messageTextStyle?.copyWith(
                  color: StreamChatTheme.of(context).colorTheme.accentPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (ogScrapeUrl != null)
              Text(ogScrapeUrl, style: messageTheme.messageTextStyle),
          ],
        ),
      ),
    );
  }
}
