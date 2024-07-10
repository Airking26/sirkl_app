import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../config/s_colors.dart';
import '../../../../../../controllers/home_controller.dart';

/// A widget that displays a channel preview.
///
/// This widget is intended to be used as a Tile in [StreamChannelListView]
///
/// It shows the last message of the channel, the last message time, the unread
/// message count, the typing indicator, the sending indicator and the channel
/// avatar.
///
/// See also:
/// * [StreamChannelAvatar]
/// * [StreamChannelName]
class StreamChannelListTile extends StatelessWidget {
  /// Creates a new instance of [StreamChannelListTile] widget.
  StreamChannelListTile({
    super.key,
    required this.channel,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.slidableEnabled,
    this.isFav,
    this.isConv,
    this.isFriends,
    this.onFavPressed,
    this.onDeletePressed,
    this.onAddPressed,
    this.onLongPress,
    this.tileColor,
    this.visualDensity = VisualDensity.compact,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.unreadIndicatorBuilder,
    this.sendingIndicatorBuilder,
    this.selected = false,
    this.selectedTileColor,
  }) : assert(
          channel.state != null,
          'Channel ${channel.id} is not initialized',
        );

  /// The channel to display.
  final Channel channel;

  /// A widget to display before the title.
  final Widget? leading;

  /// The primary content of the list tile.
  final Widget? title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// A widget to display at the end of tile.
  final Widget? trailing;

  /// Called when the user taps this list tile.
  final GestureTapCallback? onTap;

  final void Function(BuildContext context)? onFavPressed;
  final void Function(BuildContext context)? onDeletePressed;
  final void Function(BuildContext context)? onAddPressed;

  final bool? slidableEnabled;
  final bool? isFav;
  final bool? isConv;
  final bool? isFriends;

  /// Called when the user long-presses on this list tile.
  final GestureLongPressCallback? onLongPress;

  /// {@template flutter.material.ListTile.tileColor}
  /// Defines the background color of `ListTile`.
  ///
  /// When the value is null,
  /// the `tileColor` is set to [ListTileTheme.tileColor]
  /// if it's not null and to [Colors.transparent] if it's null.
  /// {@endtemplate}
  final Color? tileColor;

  /// Defines how compact the list tile's layout will be.
  ///
  /// {@macro flutter.material.themedata.visualDensity}
  ///
  /// See also:
  ///
  ///  * [ThemeData.visualDensity], which specifies the [visualDensity] for all
  ///    widgets within a [Theme].
  final VisualDensity visualDensity;

  /// The tile's internal padding.
  ///
  /// Insets a [ListTile]'s contents: its [leading], [title], [subtitle],
  /// and [trailing] widgets.
  ///
  /// If null, `EdgeInsets.symmetric(horizontal: 16.0)` is used.
  final EdgeInsetsGeometry contentPadding;

  /// The widget builder for the unread indicator.
  final WidgetBuilder? unreadIndicatorBuilder;

  /// The widget builder for the sending indicator.
  ///
  /// `Message` is the last message in the channel, Use it to determine the
  /// status using [Message.status].
  final Widget Function(BuildContext, Message)? sendingIndicatorBuilder;

  /// True if the tile is in a selected state.
  final bool selected;

  /// The color of the tile in selected state.
  final Color? selectedTileColor;

  /// Creates a copy of this tile but with the given fields replaced with
  /// the new values.
  StreamChannelListTile copyWith({
    Key? key,
    Channel? channel,
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    VoidCallback? onTap,
    void Function(BuildContext context, [Channel channel])? onFavPressed,
    VoidCallback? onLongPress,
    bool? slidableEnabled,
    bool? isFav,
    VisualDensity? visualDensity,
    EdgeInsetsGeometry? contentPadding,
    bool? selected,
    Widget Function(BuildContext, Message)? sendingIndicatorBuilder,
    Color? tileColor,
    Color? selectedTileColor,
    WidgetBuilder? unreadIndicatorBuilder,
    Widget? trailing,
  }) {
    return StreamChannelListTile(
      key: key ?? this.key,
      channel: channel ?? this.channel,
      leading: leading ?? this.leading,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      slidableEnabled: slidableEnabled ?? this.slidableEnabled,
      isFav: isFav ?? this.isFav,
      onTap: onTap ?? this.onTap,
      onFavPressed: onFavPressed ?? this.onFavPressed ,
      onLongPress: onLongPress ?? this.onLongPress,
      visualDensity: visualDensity ?? this.visualDensity,
      contentPadding: contentPadding ?? this.contentPadding,
      sendingIndicatorBuilder:
          sendingIndicatorBuilder ?? this.sendingIndicatorBuilder,
      tileColor: tileColor ?? this.tileColor,
      trailing: trailing ?? this.trailing,
      unreadIndicatorBuilder:
          unreadIndicatorBuilder ?? this.unreadIndicatorBuilder,
      selected: selected ?? this.selected,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
    );
  }
   HomeController get _homeController => Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    final channelState = channel.state!;
    final currentUser = channel.client.state.currentUser!;


    final channelPreviewTheme = StreamChannelPreviewTheme.of(context);

    final leading = this.leading ??
        StreamChannelAvatar(
          channel: channel,
        );

    final title = this.title ??
        StreamChannelName(
          channel: channel,
          textStyle: channelPreviewTheme.titleStyle,
        );

    final subtitle = this.subtitle ??
        ChannelListTileSubtitle(
          channel: channel,
          textStyle: channelPreviewTheme.subtitleStyle,
        );

    final trailing = this.trailing ??
        ChannelLastMessageDate(
          channel: channel,
          textStyle: channelPreviewTheme.lastMessageAtStyle,
        );

    return BetterStreamBuilder<bool>(
      stream: channel.isMutedStream,
      initialData: channel.isMuted,
      builder: (context, isMuted) => AnimatedOpacity(
        opacity: isMuted ? 0.5 : 1,
        duration: const Duration(milliseconds: 300),
        child: Slidable(
          enabled: slidableEnabled ?? false,
          endActionPane: ActionPane(
            extentRatio: isConv! && !isFriends! ? 0.33 : 0.25,
            motion: const ScrollMotion(),
            children:
            !isConv! ?
            [SlidableAction(
              spacing: 0,
              padding: EdgeInsets.zero,
              onPressed: onFavPressed,
              backgroundColor: Colors.white,
              foregroundColor: isFav! ? SColors.activeColor : Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282),
              icon: isFav! ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            )] :
            isFriends! ?
            [SlidableAction(
                spacing: 0,
                padding: EdgeInsets.zero,
                onPressed: onDeletePressed,
                backgroundColor: Colors.white,
                foregroundColor: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282),
                icon: (channel.membership != null && channel.membership != null && channel.membership!.channelRole == "channel_moderator" || channel.createdBy?.id == _homeController.id.value) || channel.extraData['isConv'] == true ? Icons.delete_rounded : Icons.close_rounded,
              )] :
            [SlidableAction(
                spacing: 0,
                padding: EdgeInsets.zero,
                onPressed: onDeletePressed,
                backgroundColor: Colors.white,
                foregroundColor: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282),
                icon: Icons.delete_rounded,
              ), CustomSlidableAction(
                padding: EdgeInsets.zero,
                onPressed: onAddPressed,
                backgroundColor: Colors.white,
                foregroundColor: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282),
                child: Image.asset("assets/images/add_user.png", color: SColors.activeColor, width: 20, height: 20,),
              )],
          ),
          child: ListTile(
            onTap: onTap,
            onLongPress: onLongPress,
            contentPadding: EdgeInsets.symmetric(horizontal: 24),
            leading: leading,
            tileColor: tileColor,
            selected: selected,
            selectedTileColor: selectedTileColor ?? StreamChatTheme.of(context).colorTheme.borders,
            title: Row(
              children: [
                Expanded(child: title),
                BetterStreamBuilder<List<Member>>(
                  stream: channelState.membersStream,
                  initialData: channelState.members,
                  comparator: const ListEquality().equals,
                  builder: (context, members) {
                    if (members.isEmpty || !members.any((it) => it.user!.id == currentUser.id)) {
                      return const Offstage();
                    }
                    return unreadIndicatorBuilder?.call(context) ??
                        StreamUnreadIndicator(cid: channel.cid);
                  },
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: subtitle,
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget that displays the channel last message date.
class ChannelLastMessageDate extends StatelessWidget {
  /// Creates a new instance of the [ChannelLastMessageDate] widget.
  ChannelLastMessageDate({
    super.key,
    required this.channel,
    this.textStyle,
  }) : assert(
          channel.state != null,
          'Channel ${channel.id} is not initialized',
        );

  /// The channel to display the last message date for.
  final Channel channel;

  /// The style of the text displayed
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => BetterStreamBuilder<DateTime>(
        stream: channel.lastMessageAtStream,
        initialData: channel.lastMessageAt,
        builder: (context, data) {
          final lastMessageAt = data.toLocal();

          final now = DateTime.now();

          final startOfDay = DateTime(now.year, now.month, now.day);
          var nowMilli = DateTime.now().millisecondsSinceEpoch;
          var lastMessageMilli = lastMessageAt.millisecondsSinceEpoch;
          var diffMilli = nowMilli - lastMessageMilli;
          var timeSince = DateTime.now().subtract(Duration(milliseconds: diffMilli));

          if (lastMessageAt.millisecondsSinceEpoch >=
              startOfDay.millisecondsSinceEpoch) {
          } else if (lastMessageAt.millisecondsSinceEpoch >=
              startOfDay
                  .subtract(const Duration(days: 1))
                  .millisecondsSinceEpoch) {
          } else if (startOfDay.difference(lastMessageAt).inDays < 7) {
          } else {
          }

          return Text(
            timeago.format(timeSince),
            style: textStyle!.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
          );
        },
      );
}

/// A widget that displays the subtitle for [StreamChannelListTile].
class ChannelListTileSubtitle extends StatelessWidget {
  /// Creates a new instance of [StreamChannelListTileSubtitle] widget.
  ChannelListTileSubtitle({
    super.key,
    required this.channel,
    this.textStyle,
  }) : assert(
          channel.state != null,
          'Channel ${channel.id} is not initialized',
        );

  /// The channel to create the subtitle from.
  final Channel channel;

  /// The style of the text displayed
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (channel.isMuted) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          StreamSvgIcon.mute(size: 16),
          Text(
            '  ${context.translations.channelIsMutedText}',
            style: textStyle,
          ),
        ],
      );
    }
    return Transform.translate(
      offset: const Offset(1, 0),
      child: StreamTypingIndicator(
        channel: channel,
        style: textStyle,
        alternativeWidget: ChannelLastMessageText(
          channel: channel,
          textStyle: textStyle,
        ),
      ),
    );
  }
}

/// A widget that displays the last message of a channel.
class ChannelLastMessageText extends StatefulWidget {
  /// Creates a new instance of [ChannelLastMessageText] widget.
  ChannelLastMessageText({
    super.key,
    required this.channel,
    this.textStyle,
  }) : assert(
          channel.state != null,
          'Channel ${channel.id} is not initialized',
        );

  /// The channel to display the last message of.
  final Channel channel;

  /// The style of the text displayed
  final TextStyle? textStyle;

  @override
  State<ChannelLastMessageText> createState() => _ChannelLastMessageTextState();
}

class _ChannelLastMessageTextState extends State<ChannelLastMessageText> {
  Message? _lastMessage;

  @override
  Widget build(BuildContext context) => BetterStreamBuilder<List<Message>>(
        stream: widget.channel.state!.messagesStream,
        initialData: widget.channel.state!.messages,
        builder: (context, messages) {
          final lastMessage = messages.lastWhereOrNull(
            (m) => !m.shadowed && !m.isDeleted,
          );

          if (widget.channel.state?.isUpToDate == true) {
            _lastMessage = lastMessage;
          }

          //if (_lastMessage == null) return const Offstage();

          return StreamMessagePreviewText(
            message: widget.channel.extraData["isConv"] == null ? _lastMessage ?? Message(text: "Only for holders") : _lastMessage  ?? Message(text: "No Message Yet"),
            textStyle: widget.textStyle,
            language: widget.channel.client.state.currentUser?.language,
          );
        },
      );
}
