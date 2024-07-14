import 'package:flutter/material.dart';
import 'package:sirkl/common/view/stream_chat/src/misc/stream_svg_icon.dart';
import 'package:sirkl/common/view/stream_chat/src/theme/stream_chat_theme.dart';

/// {@template attachmentButton}
/// A button for adding attachments to a chat on mobile.
/// {@endtemplate}
class AttachmentButton extends StatelessWidget {
  /// {@macro attachmentButton}
  const AttachmentButton({
    super.key,
    required this.color,
    required this.onPressed,
  });

  /// The color of the button.
  final Color color;

  /// The callback to perform when the button is tapped or clicked.
  final VoidCallback onPressed;

  /// Returns a copy of this object with the given fields updated.
  AttachmentButton copyWith({
    Key? key,
    Color? color,
    VoidCallback? onPressed,
  }) {
    return AttachmentButton(
      key: key ?? this.key,
      color: color ?? this.color,
      onPressed: onPressed ?? this.onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(12, 0),
      child: IconButton(
        icon: StreamSvgIcon.attach(
          color: StreamChatTheme.of(context).primaryIconTheme.color,
        ),
        padding: EdgeInsets.only(top: 0),
        constraints: const BoxConstraints.tightFor(
          height: 20,
          width: 20,
        ),
        splashRadius: 24,
        onPressed: onPressed,
      ),
    );
  }
}
