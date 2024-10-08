import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/views/global/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/views/global/stream_chat/src/message_widget/bottom_row.dart';
import 'package:sirkl/views/global/stream_chat/src/message_widget/message_card.dart';
import 'package:sirkl/views/global/stream_chat/src/message_widget/pinned_message.dart';
import 'package:sirkl/views/global/stream_chat/src/message_widget/reactions/desktop_reactions_builder.dart';
import 'package:sirkl/views/global/stream_chat/src/message_widget/reactions/message_reactions_modal.dart';
import 'package:sirkl/views/global/stream_chat/src/message_widget/reactions/reaction_bubble.dart';
import 'package:sirkl/views/global/stream_chat/src/message_widget/reactions/reaction_indicator.dart';
import 'package:sirkl/views/global/stream_chat/src/message_widget/user_avatar_transform.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

import '../../../../../views/profile/profile_else_screen.dart';

/// {@template messageWidgetContent}
/// The main content of a [StreamMessageWidget].
///
/// Should not be used outside of [MessageWidget.
/// {@endtemplate}
class MessageWidgetContent extends StatelessWidget {
  /// {@macro messageWidgetContent}
  MessageWidgetContent({
    super.key,
    required this.reverse,
    required this.isPinned,
    required this.showPinHighlight,
    required this.showBottomRow,
    required this.message,
    required this.showUserAvatar,
    required this.avatarWidth,
    required this.showReactions,
    required this.messageTheme,
    required this.shouldShowReactions,
    required this.streamChatTheme,
    required this.isFailedState,
    required this.hasQuotedMessage,
    required this.hasUrlAttachments,
    required this.hasNonUrlAttachments,
    required this.isOnlyEmoji,
    required this.isGiphy,
    required this.attachmentBuilders,
    required this.attachmentPadding,
    required this.textPadding,
    required this.showReactionPickerIndicator,
    required this.translateUserAvatar,
    required this.bottomRowPadding,
    required this.showInChannel,
    required this.streamChat,
    required this.showSendingIndicator,
    required this.showThreadReplyIndicator,
    required this.showTimeStamp,
    required this.showUsername,
    required this.messageWidget,
    this.onUserAvatarTap,
    this.borderRadiusGeometry,
    this.borderSide,
    this.shape,
    this.onQuotedMessageTap,
    this.onMentionTap,
    this.onLinkTap,
    this.textBuilder,
    this.bottomRowBuilder,
    this.onThreadTap,
    this.deletedBottomRowBuilder,
    this.userAvatarBuilder,
    this.usernameBuilder,
  });

  /// {@macro reverse}
  final bool reverse;

  /// {@macro isPinned}
  final bool isPinned;

  /// {@macro showPinHighlight}
  final bool showPinHighlight;

  /// {@macro showBottomRow}
  final bool showBottomRow;

  /// {@macro message}
  final Message message;

  /// {@macro showUserAvatar}
  final DisplayWidget showUserAvatar;

  /// The width of the avatar.
  final double avatarWidth;

  /// {@macro showReactions}
  final bool showReactions;

  /// {@macro messageTheme}
  final StreamMessageThemeData messageTheme;

  /// {@macro shouldShowReactions}
  final bool shouldShowReactions;

  /// {@macro onUserAvatarTap}
  final void Function(User)? onUserAvatarTap;

  /// {@macro streamChatThemeData}
  final StreamChatThemeData streamChatTheme;

  /// {@macro isFailedState}
  final bool isFailedState;

  /// {@macro borderRadiusGeometry}
  final BorderRadiusGeometry? borderRadiusGeometry;

  /// {@macro borderSide}
  final BorderSide? borderSide;

  /// {@macro shape}
  final ShapeBorder? shape;

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

  /// {@macro attachmentBuilders}
  final Map<String, AttachmentBuilder> attachmentBuilders;

  /// {@macro attachmentPadding}
  final EdgeInsetsGeometry attachmentPadding;

  /// {@macro textPadding}
  final EdgeInsets textPadding;

  /// {@macro onQuotedMessageTap}
  final OnQuotedMessageTap? onQuotedMessageTap;

  /// {@macro onMentionTap}
  final void Function(User)? onMentionTap;

  /// {@macro onLinkTap}
  final void Function(String)? onLinkTap;

  /// {@macro textBuilder}
  final Widget Function(BuildContext, Message)? textBuilder;

  /// {@macro showReactionPickerIndicator}
  final bool showReactionPickerIndicator;

  /// {@macro translateUserAvatar}
  final bool translateUserAvatar;

  /// The padding to use for this widget.
  final double bottomRowPadding;

  /// {@macro bottomRowBuilder}
  final Widget Function(BuildContext, Message)? bottomRowBuilder;

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

  /// {@macro onThreadTap}
  final void Function(Message)? onThreadTap;

  /// {@macro deletedBottomRowBuilder}
  final Widget Function(BuildContext, Message)? deletedBottomRowBuilder;

  /// {@macro messageWidget}
  final StreamMessageWidget messageWidget;

  /// {@macro userAvatarBuilder}
  final Widget Function(BuildContext, User)? userAvatarBuilder;

  /// {@macro usernameBuilder}
  final Widget Function(BuildContext, Message)? usernameBuilder;

  CommonController get _commonController => Get.find<CommonController>();
  NavigationController get _navigationController =>
      Get.find<NavigationController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: reverse
              ? AlignmentDirectional.bottomEnd
              : AlignmentDirectional.bottomStart,
          children: [
            if (!showBottomRow)
              Padding(
                padding: EdgeInsets.only(
                  left: !reverse ? bottomRowPadding : 0,
                  right: reverse ? bottomRowPadding : 0,
                  bottom: isPinned && showPinHighlight ? 6.0 : 0.0,
                ),
                child: bottomRowBuilder?.call(
                      context,
                      message,
                    ) ??
                    BottomRow(
                      message: message,
                      reverse: reverse,
                      messageTheme: messageTheme,
                      hasUrlAttachments: hasUrlAttachments,
                      isOnlyEmoji: isOnlyEmoji,
                      isDeleted: message.isDeleted,
                      isGiphy: isGiphy,
                      showInChannel: showInChannel,
                      showSendingIndicator: showSendingIndicator,
                      showThreadReplyIndicator: showThreadReplyIndicator,
                      showTimeStamp: showTimeStamp,
                      showUsername: showUsername,
                      streamChatTheme: streamChatTheme,
                      onThreadTap: onThreadTap,
                      deletedBottomRowBuilder: deletedBottomRowBuilder,
                      streamChat: streamChat,
                      hasNonUrlAttachments: hasNonUrlAttachments,
                      usernameBuilder: usernameBuilder,
                    ),
              ),
            Padding(
              padding: EdgeInsets.only(
                bottom: isPinned && showPinHighlight ? 8.0 : 0.0,
              ),
              child: Column(
                crossAxisAlignment:
                    reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.pinned &&
                      message.pinnedBy != null &&
                      showPinHighlight)
                    PinnedMessage(
                      pinnedBy: message.pinnedBy!,
                      currentUser: streamChat.currentUser!,
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!reverse &&
                          showUserAvatar == DisplayWidget.show &&
                          message.user != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: SizedBox(
                            width: 35,
                            height: 35,
                            child: UserAvatarTransform(
                              onUserAvatarTap: (user) {
                                _commonController.userClicked.value =
                                    userFromJson(
                                        json.encode(user.extraData["userDTO"]));
                                pushNewScreen(context,
                                        screen: const ProfileElseScreen(
                                            fromConversation: true),
                                        withNavBar: true)
                                    .then((value) => _navigationController
                                        .hideNavBar.value = true);
                              },
                              userAvatarBuilder: userAvatarBuilder,
                              translateUserAvatar: translateUserAvatar,
                              messageTheme: messageTheme,
                              message: message,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                      ],
                      if (showUserAvatar == DisplayWidget.hide)
                        SizedBox(width: avatarWidth + 4),
                      Flexible(
                        child: PortalTarget(
                          visible: isMobileDevice && showReactions,
                          portalFollower: isMobileDevice && showReactions
                              ? ReactionIndicator(
                                  message: message,
                                  messageTheme: messageTheme,
                                  ownId: streamChat.currentUser!.id,
                                  reverse: reverse,
                                  shouldShowReactions: shouldShowReactions,
                                  onTap: () => _showMessageReactionsModal(
                                    context,
                                  ),
                                )
                              : null,
                          anchor: Aligned(
                            follower: Alignment(
                              reverse ? 1 : -1,
                              -1,
                            ),
                            target: Alignment(
                              reverse ? -1 : 1,
                              -1,
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Padding(
                                padding: showReactions
                                    ? EdgeInsets.only(
                                        top: message.reactionCounts
                                                    ?.isNotEmpty ==
                                                true
                                            ? 18
                                            : 0,
                                      )
                                    : EdgeInsets.zero,
                                child: (message.isDeleted && !isFailedState)
                                    ? Container(
                                        // ignore: lines_longer_than_80_chars
                                        margin: EdgeInsets.symmetric(
                                          horizontal:
                                              // ignore: lines_longer_than_80_chars
                                              showUserAvatar ==
                                                      // ignore: lines_longer_than_80_chars
                                                      DisplayWidget.gone
                                                  ? 0
                                                  : 4.0,
                                        ),
                                        child: StreamDeletedMessage(
                                          borderRadiusGeometry:
                                              borderRadiusGeometry,
                                          borderSide: borderSide,
                                          shape: shape,
                                          messageTheme: messageTheme,
                                        ),
                                      )
                                    : MessageCard(
                                        message: message,
                                        deletedBottomRowBuilder:
                                            deletedBottomRowBuilder,
                                        usernameBuilder: usernameBuilder,
                                        onThreadTap: onThreadTap,
                                        streamChat: streamChat,
                                        showInChannel: showInChannel,
                                        showSendingIndicator:
                                            showSendingIndicator,
                                        showThreadReplyIndicator:
                                            showThreadReplyIndicator,
                                        showTimeStamp: showTimeStamp,
                                        showUsername: showUsername,
                                        streamChatTheme: streamChatTheme,
                                        isFailedState: isFailedState,
                                        showUserAvatar: showUserAvatar,
                                        messageTheme: messageTheme,
                                        hasQuotedMessage: hasQuotedMessage,
                                        hasUrlAttachments: hasUrlAttachments,
                                        hasNonUrlAttachments:
                                            hasNonUrlAttachments,
                                        isPinned: isPinned,
                                        bottomRowPadding: bottomRowPadding,
                                        bottomRowBuilder: bottomRowBuilder,
                                        showPinHighlight: showPinHighlight,
                                        isOnlyEmoji: isOnlyEmoji,
                                        isGiphy: isGiphy,
                                        attachmentBuilders: attachmentBuilders,
                                        attachmentPadding: attachmentPadding,
                                        textPadding: textPadding,
                                        reverse: reverse,
                                        onQuotedMessageTap: onQuotedMessageTap,
                                        onMentionTap: onMentionTap,
                                        onLinkTap: onLinkTap,
                                        textBuilder: textBuilder,
                                        borderRadiusGeometry:
                                            borderRadiusGeometry,
                                        borderSide: borderSide,
                                        shape: shape,
                                      ),
                              ),
                              if (showReactionPickerIndicator)
                                Positioned(
                                  right: reverse ? null : 4,
                                  left: reverse ? 4 : null,
                                  top: -8,
                                  child: CustomPaint(
                                    painter: ReactionBubblePainter(
                                      streamChatTheme.colorTheme.barsBg,
                                      Colors.transparent,
                                      Colors.transparent,
                                      tailCirclesSpace: 1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (reverse &&
                          showUserAvatar == DisplayWidget.show &&
                          message.user != null) ...[
                        UserAvatarTransform(
                          translateUserAvatar: translateUserAvatar,
                          messageTheme: messageTheme,
                          message: message,
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (showUserAvatar == DisplayWidget.hide)
                        SizedBox(width: avatarWidth + 4),
                    ],
                  ),
                  if (isDesktopDeviceOrWeb && shouldShowReactions) ...[
                    Padding(
                      padding: showUserAvatar != DisplayWidget.gone
                          ? EdgeInsets.only(
                              left: avatarWidth + 4,
                              right: avatarWidth + 4,
                            )
                          : EdgeInsets.zero,
                      child: DesktopReactionsBuilder(
                        message: message,
                        messageTheme: messageTheme,
                        shouldShowReactions: shouldShowReactions,
                        borderSide: borderSide,
                        reverse: reverse,
                      ),
                    ),
                  ],
                  if (showBottomRow)
                    SizedBox(
                      height: 1 * 18.0,
                    ),
                ],
              ),
            ),
            if (isFailedState)
              Positioned(
                right: reverse ? 0 : null,
                left: reverse ? null : 0,
                bottom: showBottomRow ? 18 : -2,
                child: StreamSvgIcon.error(size: 20),
              ),
          ],
        ),
      ],
    );
  }

  void _showMessageReactionsModal(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    showDialog(
      useRootNavigator: false,
      context: context,
      barrierColor: streamChatTheme.colorTheme.overlay,
      builder: (context) => StreamChannel(
        channel: channel,
        child: StreamMessageReactionsModal(
          messageWidget: messageWidget.copyWith(
            key: const Key('MessageWidget'),
            message: message.copyWith(
              text: (message.text?.length ?? 0) > 200
                  ? '${message.text!.substring(0, 200)}...'
                  : message.text,
            ),
            showReactions: false,
            showUsername: false,
            showTimestamp: false,
            translateUserAvatar: false,
            showSendingIndicator: false,
            padding: EdgeInsets.zero,
            showReactionPickerIndicator:
                showReactions && (message.state == MessageState.sent),
            showPinHighlight: false,
            showUserAvatar:
                message.user!.id == channel.client.state.currentUser!.id
                    ? DisplayWidget.gone
                    : DisplayWidget.show,
          ),
          onUserAvatarTap: onUserAvatarTap,
          messageTheme: messageTheme,
          reverse: reverse,
          message: message,
          showReactions: showReactions,
        ),
      ),
    );
  }
}
