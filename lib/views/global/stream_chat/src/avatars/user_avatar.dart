import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

import '../../../../../config/s_colors.dart';
import '../../../../../controllers/home_controller.dart';

/// {@template streamUserAvatar}
/// Displays a user's avatar.
/// {@endtemplate}
class StreamUserAvatar extends StatelessWidget {
  /// {@macro streamUserAvatar}
  StreamUserAvatar({
    super.key,
    required this.user,
    this.constraints,
    this.onlineIndicatorConstraints,
    this.onTap,
    this.onLongPress,
    this.memberPage = false,
    this.showOnlineStatus = true,
    this.borderRadius,
    this.onlineIndicatorAlignment = Alignment.topRight,
    this.selected = false,
    this.selectionColor,
    this.selectionThickness = 4,
    this.placeholder,
    this.channel,
  });

  HomeController get _homeController => Get.find<HomeController>();

  final bool memberPage;

  /// User whose avatar is to be displayed
  final User user;

  final Channel? channel;

  /// Alignment of the online indicator
  ///
  /// Defaults to `Alignment.topRight`
  final Alignment onlineIndicatorAlignment;

  /// Sizing constraints of the avatar
  final BoxConstraints? constraints;

  /// [BorderRadius] of the image
  final BorderRadius? borderRadius;

  /// Sizing constraints of the online indicator
  final BoxConstraints? onlineIndicatorConstraints;

  /// {@macro onUserAvatarTap}
  final OnUserAvatarPress? onTap;

  /// {@macro onUserAvatarTap}
  final OnUserAvatarPress? onLongPress;

  /// Flag for showing online status
  ///
  /// Defaults to `true`
  final bool showOnlineStatus;

  /// Flag for if avatar is selected
  ///
  /// Defaults to `false`
  final bool selected;

  /// Color of selection
  final Color? selectionColor;

  /// Selection thickness around the avatar
  ///
  /// Defaults to `4`
  final double selectionThickness;

  /// {@macro placeholderUserImage}
  final PlaceholderUserImage? placeholder;

  @override
  Widget build(BuildContext context) {
    var userDTO = userFromJson(json.encode(user.extraData["userDTO"]));
    final userHavePicture = !userDTO.picture.isNullOrBlank!;
    final notYetUser = userDTO.id == _homeController.id.value;
    final isGroup = channel?.extraData["isConv"];
    final picOfGroup = channel?.extraData["picOfGroup"];
    final streamChatTheme = StreamChatTheme.of(context);
    final streamChatConfig = StreamChatConfiguration.of(context);

    final backupGradientAvatar = ClipRRect(
      borderRadius: BorderRadius.circular(90),
      child: streamChatConfig.defaultUserImage(context, user),
    );

    // Removed memberPage with userHavePicture to display picture of user
    Widget avatar = FittedBox(
      fit: BoxFit.cover,
      child: Container(
        constraints: const BoxConstraints(
            minWidth: 56, maxHeight: 56, maxWidth: 56, minHeight: 56),
        child: notYetUser && isGroup != null && isGroup as bool
            ? Image.asset(
                "assets/images/app_icon_rounded.png",
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              )
            : (userHavePicture && isGroup != null && (isGroup as bool)) ||
                    (isGroup != null &&
                        picOfGroup != null &&
                        !(isGroup as bool)) ||
                    userHavePicture
                ? CachedNetworkImage(
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    imageUrl: picOfGroup != null
                        ? picOfGroup as String
                        : userDTO.picture!,
                    errorWidget: (context, __, ___) => backupGradientAvatar,
                    placeholder: (context, _) => Center(
                        child: CircularProgressIndicator(
                            color: SColors.activeColor)),
                    imageBuilder: (context, imageProvider) => DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : TinyAvatar(
                    baseString: isGroup != null &&
                            picOfGroup != null &&
                            !(isGroup as bool)
                        ? picOfGroup as String
                        : (channel?.extraData["isGroupPaying"] != null &&
                                    (channel?.extraData["isGroupPaying"])
                                        as bool) ||
                                (channel?.extraData["isConv"] != null &&
                                    channel?.extraData["isConv"] == false)
                            ? channel?.extraData["nameOfGroup"] as String
                            : userFromJson(
                                    json.encode(user.extraData["userDTO"]))
                                .wallet!,
                    dimension: 52,
                    circular: true,
                    colourScheme: TinyAvatarColourScheme.seascape,
                  ),
      ),
    );

    if (selected) {
      avatar = ClipRRect(
        borderRadius: (borderRadius ??
                streamChatTheme.ownMessageTheme.avatarTheme?.borderRadius ??
                BorderRadius.zero) +
            BorderRadius.circular(selectionThickness),
        child: Container(
          constraints: constraints ??
              streamChatTheme.ownMessageTheme.avatarTheme?.constraints,
          color: selectionColor ?? streamChatTheme.colorTheme.accentPrimary,
          child: Padding(
            padding: EdgeInsets.all(selectionThickness),
            child: avatar,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(user) : null,
      onLongPress: onLongPress != null ? () => onLongPress!(user) : null,
      child: Stack(
        children: <Widget>[
          avatar,
          if (false && user.online)
            Positioned.fill(
              child: Align(
                alignment: onlineIndicatorAlignment,
                child: Material(
                  type: MaterialType.circle,
                  color: streamChatTheme.colorTheme.barsBg,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    constraints: onlineIndicatorConstraints ??
                        const BoxConstraints.tightFor(
                          width: 8,
                          height: 8,
                        ),
                    child: Material(
                      shape: const CircleBorder(),
                      color: streamChatTheme.colorTheme.accentInfo,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
