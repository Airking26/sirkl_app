import 'package:flutter/material.dart';
import 'package:sirkl/views/global/stream_chat/src/message_input/countdown_button.dart';
import 'package:sirkl/views/global/stream_chat/src/theme/message_input_theme.dart';
import 'package:sirkl/views/global/stream_chat/src/theme/stream_chat_theme.dart';

/// A widget that displays a sending button.
class StreamMessageSendButton extends StatelessWidget {
  /// Returns a [StreamMessageSendButton] with the given [timeOut], [isIdle],
  /// [isCommandEnabled], [isEditEnabled], [idleSendButton], [activeSendButton],
  /// [onSendMessage].
  const StreamMessageSendButton({
    super.key,
    this.timeOut = 0,
    this.isIdle = true,
    this.isCommandEnabled = false,
    this.isEditEnabled = false,
    this.idleSendButton,
    this.activeSendButton,
    required this.onSendMessage,
  });

  /// Time out related to slow mode.
  final int timeOut;

  /// If true the button will be disabled.
  final bool isIdle;

  /// True if a command is being sent.
  final bool isCommandEnabled;

  /// True if in editing mode.
  final bool isEditEnabled;

  /// The widget to display when the button is disabled.
  final Widget? idleSendButton;

  /// The widget to display when the button is enabled.
  final Widget? activeSendButton;

  /// The callback to call when the button is pressed.
  final VoidCallback onSendMessage;

  @override
  Widget build(BuildContext context) {
    final _streamChatTheme = StreamChatTheme.of(context);

    late Widget sendButton;
    if (timeOut > 0) {
      sendButton = StreamCountdownButton(count: timeOut);
    } else if (isIdle) {
      sendButton = idleSendButton ?? _buildIdleSendButton(context);
    } else {
      sendButton = activeSendButton != null
          ? InkWell(
              onTap: onSendMessage,
              child: activeSendButton,
            )
          : _buildSendButton(context);
    }

    return AnimatedSwitcher(
      duration: _streamChatTheme.messageInputTheme.sendAnimationDuration!,
      child: sendButton,
    );
  }

  Widget _buildIdleSendButton(BuildContext context) {
    final _messageInputTheme = StreamMessageInputTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () async {},
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF1DE99B), Color(0xFF0063FB)])),
          child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/send.png",
                height: 32,
                width: 32,
              )),
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    final _messageInputTheme = StreamMessageInputTheme.of(context);

    return Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: onSendMessage,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF1DE99B), Color(0xFF0063FB)])),
            child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/images/send.png",
                  height: 32,
                  width: 32,
                )),
          ),
        ));
  }

  String _getIdleSendIcon() {
    if (isCommandEnabled) {
      return 'Icon_search.svg';
    } else {
      return 'Icon_circle_right.svg';
    }
  }

  String _getSendIcon() {
    if (isEditEnabled) {
      return 'Icon_circle_up.svg';
    } else if (isCommandEnabled) {
      return 'Icon_search.svg';
    } else {
      return 'Icon_circle_up.svg';
    }
  }
}
