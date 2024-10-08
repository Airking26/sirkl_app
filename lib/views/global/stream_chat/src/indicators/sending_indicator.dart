import 'package:flutter/material.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

/// {@template streamSendingIndicator}
/// Shows the sending status of a message.
/// {@endtemplate}
class StreamSendingIndicator extends StatelessWidget {
  /// {@macro streamSendingIndicator}
  const StreamSendingIndicator({
    super.key,
    required this.message,
    this.isMessageRead = false,
    this.size = 12,
  });

  /// Message for sending indicator
  final Message message;

  /// Flag if message is read
  final bool isMessageRead;

  /// Size for message
  final double? size;

  @override
  Widget build(BuildContext context) {
    if (isMessageRead) {
      return StreamSvgIcon.checkAll(
        size: size,
        color: StreamChatTheme.of(context).colorTheme.accentPrimary,
      );
    }
    if (message.state == MessageState.sent) {
      return StreamSvgIcon.check(
        size: size,
        color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
      );
    }
    if (message.state == MessageState.sending ||
        message.state == MessageState.updating) {
      return Icon(
        Icons.access_time,
        size: size,
      );
    }
    return const SizedBox();
  }
}
