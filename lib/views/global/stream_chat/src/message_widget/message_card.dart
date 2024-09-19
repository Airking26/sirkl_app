import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide GetStringUtils;
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/views/global/stream_chat/src/message_widget/bottom_row.dart';
import 'package:sirkl/views/global/stream_chat/src/message_widget/parse_attachments.dart';
import 'package:sirkl/views/global/stream_chat/src/message_widget/quoted_message.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

import '../../../../../config/s_colors.dart';
import '../../../../../controllers/home_controller.dart';

/// {@template messageCard}
/// The widget containing a quoted message.
///
/// Used in [MessageWidgetContent]. Should not be used elsewhere.
/// {@endtemplate}
class MessageCard extends StatefulWidget {
  /// {@macro messageCard}
  const MessageCard({
    super.key,
    required this.message,
    required this.isFailedState,
    required this.showUserAvatar,
    required this.messageTheme,
    required this.hasQuotedMessage,
    required this.hasUrlAttachments,
    required this.hasNonUrlAttachments,
    required this.isOnlyEmoji,
    required this.isGiphy,
    required this.attachmentBuilders,
    required this.attachmentPadding,
    required this.textPadding,
    required this.reverse,
    required this.bottomRowPadding,
    required this.isPinned,
    required this.bottomRowBuilder,
    required this.showPinHighlight,
    required this.deletedBottomRowBuilder,
    required this.usernameBuilder,
    required this.onThreadTap,
    required this.streamChatTheme,
    required this.showInChannel,
    required this.streamChat,
    required this.showSendingIndicator,
    required this.showThreadReplyIndicator,
    required this.showTimeStamp,
    required this.showUsername,
    this.shape,
    this.borderSide,
    this.borderRadiusGeometry,
    this.textBuilder,
    this.onLinkTap,
    this.onMentionTap,
    this.onQuotedMessageTap,
  });

  /// {@macro deletedBottomRowBuilder}
  final Widget Function(BuildContext, Message)? deletedBottomRowBuilder;

  /// {@macro usernameBuilder}
  final Widget Function(BuildContext, Message)? usernameBuilder;

  /// {@macro onThreadTap}
  final void Function(Message)? onThreadTap;

  /// {@macro streamChatThemeData}
  final StreamChatThemeData streamChatTheme;

  /// {@macro showInChannelIndicator}
  final bool showInChannel;

  /// {@macro streamChat}
  final StreamChatState streamChat;

  /// {@macro showSendingIndicator}
  final bool showSendingIndicator;

  /// {@macro showThreadReplyIndicator}
  final bool showThreadReplyIndicator;

  /// {@macro showTimestamp}
  final bool showTimeStamp;

  /// {@macro showUsername}
  final bool showUsername;

  /// {@macro showPinHighlight}
  final bool showPinHighlight;

  /// {@macro bottomRowBuilder}
  final Widget Function(BuildContext, Message)? bottomRowBuilder;

  /// {@macro isPinned}
  final bool isPinned;

  /// The padding to use for this widget.
  final double bottomRowPadding;

  /// {@macro isFailedState}
  final bool isFailedState;

  /// {@macro showUserAvatar}
  final DisplayWidget showUserAvatar;

  /// {@macro shape}
  final ShapeBorder? shape;

  /// {@macro borderSide}
  final BorderSide? borderSide;

  /// {@macro messageTheme}
  final StreamMessageThemeData messageTheme;

  /// {@macro borderRadiusGeometry}
  final BorderRadiusGeometry? borderRadiusGeometry;

  /// {@macro hasQuotedMessage}
  final bool hasQuotedMessage;

  /// {@macro hasUrlAttachments}
  final bool hasUrlAttachments;

  /// {@macro hasNonUrlAttachments}
  final bool hasNonUrlAttachments;

  /// {@macro isOnlyEmoji}
  final bool isOnlyEmoji;

  /// {@macro isGiphy}
  final bool isGiphy;

  /// {@macro message}
  final Message message;

  /// {@macro attachmentBuilders}
  final Map<String, AttachmentBuilder> attachmentBuilders;

  /// {@macro attachmentPadding}
  final EdgeInsetsGeometry attachmentPadding;

  /// {@macro textPadding}
  final EdgeInsets textPadding;

  /// {@macro textBuilder}
  final Widget Function(BuildContext, Message)? textBuilder;

  /// {@macro onLinkTap}
  final void Function(String)? onLinkTap;

  /// {@macro onMentionTap}
  final void Function(User)? onMentionTap;

  /// {@macro onQuotedMessageTap}
  final OnQuotedMessageTap? onQuotedMessageTap;

  /// {@macro reverse}
  final bool reverse;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  final GlobalKey attachmentsKey = GlobalKey();
  final GlobalKey linksKey = GlobalKey();
  double? widthLimit;

  HomeController get _homeController => Get.find<HomeController>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final attachmentsRenderBox =
          attachmentsKey.currentContext?.findRenderObject() as RenderBox?;
      final attachmentsWidth = attachmentsRenderBox?.size.width;

      final linkRenderBox =
          linksKey.currentContext?.findRenderObject() as RenderBox?;
      final linkWidth = linkRenderBox?.size.width;

      if (mounted) {
        setState(() {
          if (attachmentsWidth != null && linkWidth != null) {
            widthLimit = max(attachmentsWidth, linkWidth);
          } else {
            widthLimit = attachmentsWidth ?? linkWidth;
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userDTO =
        userFromJson(json.encode(widget.message.user?.extraData["userDTO"]));
    return Material(
      elevation: 1,
      shadowColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.transparent
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              width: widget.reverse
                  ? MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? 0
                      : 1
                  : MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? 2
                      : 0.1,
              color: widget.reverse
                  ? MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.transparent
                      : SColors.activeColor.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.35)),
          borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(10),
              bottomRight: widget.reverse && widget.showTimeStamp
                  ? const Radius.circular(0)
                  : const Radius.circular(10),
              topLeft: widget.reverse
                  ? const Radius.circular(10)
                  : widget.showTimeStamp
                      ? const Radius.circular(0)
                      : const Radius.circular(10),
              topRight: const Radius.circular(10)),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.reverse
                    ? MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.white.withOpacity(0.1)
                        : SColors.activeColor.withOpacity(0.05)
                    : MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.transparent
                        : Colors.white,
                widget.reverse
                    ? MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : SColors.activeColor.withOpacity(0.05)
                    : MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.transparent
                        : Colors.white
              ]),
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.only(
              top: (widget.isFailedState ? 15.0 : 0.0) +
                  (widget.showUserAvatar == DisplayWidget.gone ? 0 : 2.0),
              left: (widget.isFailedState ? 15.0 : 0.0) +
                  (widget.showUserAvatar == DisplayWidget.gone ? 0 : 4.0),
              right: (widget.isFailedState ? 15.0 : 0.0) +
                  (widget.showUserAvatar == DisplayWidget.gone ? 0 : 4.0)),
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: widthLimit ?? double.infinity),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !widget.showTimeStamp ||
                          widget.showUserAvatar == DisplayWidget.gone
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 12, top: 12),
                          child: Text(
                            displayName(userDTO, _homeController),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: "Gilroy",
                                fontWeight: FontWeight.w600,
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.dark
                                        ? SColors.activeColor
                                        : Colors.blueGrey),
                          ),
                        ),
                  if (widget.hasQuotedMessage)
                    QuotedMessage(
                      reverse: widget.reverse,
                      message: widget.message,
                      hasNonUrlAttachments: widget.hasNonUrlAttachments,
                      onQuotedMessageTap: widget.onQuotedMessageTap,
                    ),
                  if (widget.hasNonUrlAttachments)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ParseAttachments(
                        key: attachmentsKey,
                        message: widget.message,
                        attachmentBuilders: widget.attachmentBuilders,
                        attachmentPadding: widget.attachmentPadding,
                      ),
                    ),
                  if (!widget.isGiphy)
                    ConstrainedBox(
                      constraints:
                          BoxConstraints.loose(const Size.fromWidth(500)),
                      child: TextBubble(
                        messageTheme: widget.messageTheme,
                        message: widget.message,
                        reverse: widget.reverse,
                        textPadding: widget.textPadding,
                        textBuilder: widget.textBuilder,
                        isOnlyEmoji: widget.isOnlyEmoji,
                        hasQuotedMessage: widget.hasQuotedMessage,
                        hasUrlAttachments: widget.hasUrlAttachments,
                        onLinkTap: widget.onLinkTap,
                        onMentionTap: widget.onMentionTap,
                      ),
                    ),
                  if (widget.hasUrlAttachments && !widget.hasQuotedMessage)
                    _buildUrlAttachment(),
                  widget.showTimeStamp
                      ? Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  bottom: widget.message.attachments
                                          .map((e) => e.type)
                                          .contains("voicenote")
                                      ? 0
                                      : 12,
                                  top: 0),
                              child: Transform.translate(
                                offset: Offset(
                                    0,
                                    widget.message.attachments
                                            .map((e) => e.type)
                                            .contains("voicenote")
                                        ? -12
                                        : 0),
                                child: widget.bottomRowBuilder?.call(
                                      context,
                                      widget.message,
                                    ) ??
                                    BottomRow(
                                      message: widget.message,
                                      reverse: widget.reverse,
                                      messageTheme: widget.messageTheme,
                                      hasUrlAttachments:
                                          widget.hasUrlAttachments,
                                      isOnlyEmoji: widget.isOnlyEmoji,
                                      isDeleted: widget.message.isDeleted,
                                      isGiphy: widget.isGiphy,
                                      showInChannel: widget.showInChannel,
                                      showSendingIndicator:
                                          widget.showSendingIndicator,
                                      showThreadReplyIndicator:
                                          widget.showThreadReplyIndicator,
                                      showTimeStamp: widget.showTimeStamp,
                                      showUsername: false,
                                      streamChatTheme: StreamChatThemeData(
                                          colorTheme: StreamColorTheme.dark(
                                              appBg: Colors.red,
                                              accentPrimary:
                                                  SColors.activeColor)),
                                      onThreadTap: widget.onThreadTap,
                                      deletedBottomRowBuilder:
                                          widget.deletedBottomRowBuilder,
                                      streamChat: widget.streamChat,
                                      hasNonUrlAttachments:
                                          widget.hasNonUrlAttachments,
                                      usernameBuilder: widget.usernameBuilder,
                                    ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: widget.message.attachments
                                      .map((e) => e.type)
                                      .contains('voicenote') &&
                                  !widget.showTimeStamp
                              ? 12
                              : 12,
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrlAttachment() {
    final urlAttachment = widget.message.attachments
        .firstWhere((element) => element.titleLink != null);

    final host = Uri.parse(urlAttachment.titleLink!).host;
    final splitList = host.split('.');
    final hostName = splitList.length == 3 ? splitList[1] : splitList[0];
    final hostDisplayName = urlAttachment.authorName?.capitalize() ??
        getWebsiteName(hostName.toLowerCase()) ??
        hostName.capitalize();

    return StreamUrlAttachment(
      key: linksKey,
      urlAttachment: urlAttachment,
      hostDisplayName: hostDisplayName,
      textPadding: widget.textPadding,
      messageTheme: widget.messageTheme,
    );
  }

  Color? _getBackgroundColor() {
    if (widget.hasQuotedMessage) {
      return widget.messageTheme.messageBackgroundColor;
    }

    if (widget.hasUrlAttachments) {
      return widget.messageTheme.linkBackgroundColor;
    }

    if (widget.isOnlyEmoji) {
      return Colors.transparent;
    }

    if (widget.isGiphy) {
      return Colors.transparent;
    }

    return widget.messageTheme.messageBackgroundColor;
  }
}
