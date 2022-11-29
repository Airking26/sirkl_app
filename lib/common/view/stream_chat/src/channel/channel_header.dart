import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/dialog/custom_dial.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:sirkl/common/constants.dart' as con;

/// {@template streamChannelHeader}
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/channel_header.png)
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/channel_header_paint.png)
///
/// Shows information about the current [Channel].
///
/// ```dart
/// class MyApp extends StatelessWidget {
///   final StreamChatClient client;
///   final Channel channel;
///
///   MyApp(this.client, this.channel);
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: StreamChat(
///         client: client,
///         child: StreamChannel(
///           channel: channel,
///           child: Scaffold(
///             appBar: ChannelHeader(),
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// Usually you would use this widget as an [AppBar] inside a [Scaffold].
/// However, you can also use it as a normal widget.
///
/// Make sure to have a [StreamChannel] ancestor in order to provide the
/// information about the channel.
///
/// Every part of the widget uses a [StreamBuilder] to render the channel
/// information as soon as it updates.
///
/// By default the widget shows a backButton that calls [Navigator.pop].
/// You can disable this button using the [showBackButton] property.
/// Alternatively, you can override this behaviour via the [onBackPressed]
/// callback.
///
/// The UI is rendered based on the first ancestor of type [StreamChatTheme]
/// and the [StreamChatThemeData.channelHeaderTheme] property. Modify it to
/// change the widget's appearance.
/// {@endtemplate}
class StreamChannelHeader extends StatelessWidget
    implements PreferredSizeWidget {
  /// {@macro streamChannelHeader}
  StreamChannelHeader({
    super.key,
    this.showBackButton = true,
    this.onBackPressed,
    this.onTitleTap,
    this.showTypingIndicator = true,
    this.onImageTap,
    this.showConnectionStateTile = false,
    this.title,
    this.subtitle,
    this.centerTitle,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.elevation = 1,
    required this.commonController,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  final CommonController commonController;

  /// Whether to show the leading back button
  ///
  /// Defaults to `true`
  final bool showBackButton;

  /// The action to perform when the back button is pressed.
  ///
  /// By default it calls [Navigator.pop]
  final VoidCallback? onBackPressed;

  /// The action to perform when the header is tapped.
  final VoidCallback? onTitleTap;

  /// The action to perform when the image is tapped.
  final VoidCallback? onImageTap;

  /// Whether to show the typing indicator
  ///
  /// Defaults to `true`
  final bool showTypingIndicator;

  /// Whether to show the connection state tile
  final bool showConnectionStateTile;

  /// Title widget
  final Widget? title;

  /// Subtitle widget
  final Widget? subtitle;

  /// Whether the title should be centered
  final bool? centerTitle;

  /// Leading widget
  final Widget? leading;

  /// {@macro flutter.material.appbar.actions}
  ///
  /// The [StreamChannelAvatar] is shown by default
  final List<Widget>? actions;

  /// The background color for this [StreamChannelHeader].
  final Color? backgroundColor;

  /// The elevation for this [StreamChannelHeader].
  final double elevation;

  @override
  final Size preferredSize;

  YYDialog dialogMenu = YYDialog();

  @override
  Widget build(BuildContext context) {
    final effectiveCenterTitle = getEffectiveCenterTitle(
      Theme.of(context),
      actions: actions,
      centerTitle: centerTitle,
    );
    final channel = StreamChannel.of(context).channel;
    final channelHeaderTheme = StreamChannelHeaderTheme.of(context);

    final leadingWidget = leading ??
        (showBackButton
            ? StreamBackButton(
                onPressed: onBackPressed,
                showUnreadCount: true,
              )
            : const SizedBox());

    return StreamConnectionStatusBuilder(
      statusBuilder: (context, status) {
        var statusString = '';
        var showStatus = true;

        switch (status) {
          case ConnectionStatus.connected:
            statusString = context.translations.connectedLabel;
            showStatus = false;
            break;
          case ConnectionStatus.connecting:
            statusString = context.translations.reconnectingLabel;
            break;
          case ConnectionStatus.disconnected:
            statusString = context.translations.disconnectedLabel;
            break;
        }

        final theme = Theme.of(context);

        return StreamInfoTile(
          showMessage: showConnectionStateTile && showStatus,
          message: statusString,
          child: Container(
            height: 115,
            margin: const EdgeInsets.only(bottom: 0.25),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 0.01), //(x,y)
                  blurRadius: 0.01,
                ),
              ],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Get.isDarkMode ? const Color(0xFF113751) : Colors.white,
                    Get.isDarkMode ? const Color(0xFF1E2032) : Colors.white
                  ]),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 44.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: Image.asset(
                                "assets/images/arrow_left.png",
                                color: Get.isDarkMode ? Colors.white : Colors.black,
                              )),
                          InkWell(
                            onTap: () async {
                              if(channel.memberCount == 2) {
                                commonController.userClicked.value =
                                    userFromJson(
                                        json.encode(channel.state?.members
                                            .where((element) =>
                                        element.userId != StreamChat
                                            .of(context)
                                            .currentUser!
                                            .id)
                                            .first
                                            .user!
                                            .extraData["userDTO"]));
                                Get.to(() => const ProfileElseScreen());
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(90),
                                  child:
                                  channel.memberCount != null && channel.memberCount! <= 2 ?
                                  userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).picture == null ?
                                  TinyAvatar(baseString: userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!, dimension: 40, circular: true,
                                      colourScheme: TinyAvatarColourScheme.seascape) :
                                  CachedNetworkImage(
                                    imageUrl: userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).picture!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ) :
                                      channel.image == null ?
                                      TinyAvatar(baseString: channel.name!, dimension: 40, circular: true,
                                          colourScheme: TinyAvatarColourScheme.seascape)
                                          :
                                  CachedNetworkImage(
                                    imageUrl: channel.image!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  )
                              )
                              ,
                            ),
                          ),
                          InkWell(
                            onTap: () async{
                              if(channel.memberCount == 2) {
                                commonController.userClicked.value =
                                    userFromJson(
                                        json.encode(channel.state?.members
                                            .where((element) =>
                                        element.userId != StreamChat
                                            .of(context)
                                            .currentUser!
                                            .id)
                                            .first
                                            .user!
                                            .extraData["userDTO"]));
                                Get.to(() => const ProfileElseScreen());
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    channel.memberCount != null && channel.memberCount! > 2 ?
                                        channel.name!.substring(0, channel.name!.length < 25 ? channel.name!.length : 25) :
                                    userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).userName ??
                                        userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Gilroy",
                                        color: Get.isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                  channel.memberCount != null && channel.memberCount! > 2 ? Text(
                                    "${channel.memberCount!} participants",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Gilroy",
                                        color: Get.isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                  ) : Container(),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          dialogMenu = channel.memberCount == 2 ? dialogPopMenuConv(context, channel) :dialogPopMenuGroup(context);
                        },
                        icon: Image.asset(
                          "assets/images/more.png",
                          color: Get.isDarkMode ? Colors.white : Colors.black,
                        )),
                  ],
                ),
              ),
            ),
          )
        );
      },
    );
  }

  YYDialog dialogPopMenuGroup(BuildContext context) {
    return YYDialog().build(context)
      ..width = 180
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor = Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05)
      ..backgroundColor = Get.isDarkMode ? const Color(0xFF1E3244).withOpacity(0.95) : Colors.white
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.notificationsOffRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.contactOwnerRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.claimOwnershipeRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.reportRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }

  YYDialog dialogPopMenuConv(BuildContext context, Channel channel) {
    return YYDialog().build(context)
      ..width = 180
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor = Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05)
      ..backgroundColor = Get.isDarkMode ? const Color(0xFF1E3244).withOpacity(0.95) : Colors.white
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(userFromJson(
              json.encode(channel.state?.members
                  .where((element) =>
              element.userId != StreamChat
                  .of(context)
                  .currentUser!
                  .id)
                  .first
                  .user!
                  .extraData["userDTO"])).isInFollowing! ? con.addToMySirklRes.tr : con.removeOfMySirklRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){
          commonController.userClicked.value = userFromJson(
              json.encode(channel.state?.members
                  .where((element) =>
              element.userId != StreamChat
                  .of(context)
                  .currentUser!
                  .id)
                  .first
                  .user!
                  .extraData["userDTO"]));
          Get.to(() => const ProfileElseScreen());
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.profileMenuTabRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.reportRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }

}
