import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';

/// A widget that displays a user.
///
/// This widget is intended to be used as a Tile in [StreamUserListView]
///
/// It shows the user's avatar, name and last message.
///
/// See also:
/// * [StreamUserListView]
/// * [StreamUserAvatar]
class StreamUserListTile extends StatelessWidget {
  /// Creates a new instance of [StreamUserListTile].
  StreamUserListTile({
    super.key,
    required this.user,
    this.memberPage = false,
    this.leading,
    this.title,
    this.slidableEnabled,
    this.onDeletePressed,
    this.onAdminPressed,
    this.subtitle,
    this.selected = false,
    this.selectedWidget,
    this.onTap,
    this.onLongPress,
    this.tileColor,
    this.visualDensity = VisualDensity.compact,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 8), this.channelRole,
  });

  final void Function(BuildContext context)? onDeletePressed;
  final void Function(BuildContext context)? onAdminPressed;
  final String? channelRole;
  final bool memberPage;
  final bool? slidableEnabled;

  /// The user to display.
  final User user;

  /// A widget to display before the title.
  final Widget? leading;

  /// The primary content of the list tile.
  final Widget? title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// A widget to display at the end of tile.
  final Widget? selectedWidget;

  /// If this tile is also [enabled] then icons and text are rendered with the
  /// same color.
  ///
  /// By default the selected color is the theme's primary color. The selected
  /// color can be overridden with a [ListTileTheme].
  ///
  /// {@tool dartpad}
  /// Here is an example of using a [StatefulWidget] to keep track of the
  /// selected index, and using that to set the `selected` property on the
  /// corresponding [ListTile].
  ///
  /// ** See code in examples/api/lib/material/list_tile/list_tile.selected.0.dart **
  /// {@end-tool}
  final bool selected;

  /// Called when the user taps this list tile.
  final GestureTapCallback? onTap;

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

  final _homeController = Get.put(HomeController());

  /// Creates a copy of this tile but with the given fields replaced with
  /// the new values.
  StreamUserListTile copyWith({
    Key? key,
    User? user,
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? selectedWidget,
    bool? selected,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    Color? tileColor,
    VisualDensity? visualDensity,
    EdgeInsetsGeometry? contentPadding,
  }) =>
      StreamUserListTile(
        key: key ?? this.key,
        user: user ?? this.user,
        leading: leading ?? this.leading,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        selectedWidget: selectedWidget ?? this.selectedWidget,
        selected: selected ?? this.selected,
        onTap: onTap ?? this.onTap,
        onLongPress: onLongPress ?? this.onLongPress,
        tileColor: tileColor ?? this.tileColor,
        visualDensity: visualDensity ?? this.visualDensity,
        contentPadding: contentPadding ?? this.contentPadding,
      );

  @override
  Widget build(BuildContext context) {
    final chatThemeData = StreamChatTheme.of(context);

    final leading = this.leading ??
        StreamUserAvatar(
          user: user,
          memberPage: memberPage,
          constraints: const BoxConstraints.tightFor(
            height: 30,
            width: 30,
          ),
        );

    final title = Row(
      children: [
        this.title ??
            Text(
                (_homeController.nicknames[userFromJson(json.encode(user.extraData["userDTO"])).wallet!] != null ?
              _homeController.nicknames[userFromJson(json.encode(user.extraData["userDTO"])).wallet!] + " (" + (userFromJson(json.encode(user.extraData["userDTO"])).userName.isNullOrBlank! ? "${userFromJson(json.encode(user.extraData["userDTO"])).wallet!.substring(0,6)}...${userFromJson(json.encode(user.extraData["userDTO"])).wallet!.substring(userFromJson(json.encode(user.extraData["userDTO"])).wallet!.length -4)}": userFromJson(json.encode(user.extraData["userDTO"])).userName!) + ")"
                  : (userFromJson(json.encode(user.extraData["userDTO"])).userName.isNullOrBlank! ? "${userFromJson(json.encode(user.extraData["userDTO"])).wallet!.substring(0,10)}...${userFromJson(json.encode(user.extraData["userDTO"])).wallet!.substring(userFromJson(json.encode(user.extraData["userDTO"])).wallet!.length - 4)}": userFromJson(json.encode(user.extraData["userDTO"])).userName!)),
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: "Gilroy",color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),
            ),
        SizedBox(width: channelRole == "channel_moderator" ? 4 : 0,),
        channelRole == "channel_moderator" ? const Icon(Icons.diamond_outlined, color: Color(0xFF00CB7D), size: 16,) : const SizedBox(height: 0, width: 0,)
      ],
    );

    final subtitle = this.subtitle ??
        UserLastActive(
          user: user,
        );

    final selectedWidget = this.selectedWidget ??
        StreamSvgIcon.checkSend(
          color: chatThemeData.colorTheme.accentPrimary,
        );

    return Slidable(
      enabled: slidableEnabled ?? false,
      endActionPane: ActionPane(
        extentRatio: 0.33,
        motion: const ScrollMotion(), children: [
          SlidableAction(
        spacing: 0,
        padding: EdgeInsets.zero,
        onPressed: onDeletePressed,
        backgroundColor: Colors.white,
        foregroundColor: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282),
        icon: Icons.person_remove_rounded,
      ),
        SlidableAction(
          spacing: 0,
          padding: EdgeInsets.zero,
          onPressed: onAdminPressed,
          backgroundColor: Colors.white,
          foregroundColor: channelRole == "channel_moderator" ?  Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282) : const Color(0xFF00CB7D),
          icon: Icons.diamond_outlined,
        )
      ],),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: leading,
        trailing: selected ? selectedWidget : null,
        title: title,
        subtitle: subtitle,
        dense: false,
      ),
    );
  }
}

/// A widget that displays a user's last active time.
class UserLastActive extends StatelessWidget {
  /// Creates a new instance of the [UserLastActive] widget.
  const UserLastActive({
    super.key,
    required this.user,
  });

  /// The user whose last active time is displayed.
  final User user;

  @override
  Widget build(BuildContext context) {
    final chatTheme = StreamChatTheme.of(context);
    return Text(
      user.online
          ? context.translations.userOnlineText
          : '${context.translations.userLastOnlineText} '
              '${Jiffy(user.lastActive).fromNow()}',
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, fontFamily: "Gilroy",color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5)),
    );
  }
}
