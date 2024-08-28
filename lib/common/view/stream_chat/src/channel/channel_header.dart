import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/controllers/call_controller.dart';
import 'package:sirkl/controllers/chats_controller.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

import '../../../../../config/s_colors.dart';
import '../../../../../controllers/home_controller.dart';
import '../../../../../controllers/profile_controller.dart';
import '../../../../../views/chats/settings_group_screen.dart';
import '../../../../../views/group/community_settings_screen.dart';
import '../../../../../views/profile/settings_profile_else_screen.dart';

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
    this.fromProfile = false,
    required this.commonController,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  final bool fromProfile;
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

  CommonController get _commonController => Get.find<CommonController>();
  HomeController get _homeController => Get.find<HomeController>();
  ChatsController get _chatController => Get.find<ChatsController>();
  ProfileController get _profileController => Get.find<ProfileController>();
  CallController get _callController => Get.find<CallController>();

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

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

        return StreamInfoTile(
            showMessage: showConnectionStateTile && showStatus,
            message: statusString,
            child: Obx(() => Container(
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
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(35)),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? const Color(0xFF113751)
                              : Colors.white,
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? const Color(0xFF1E2032)
                              : Colors.white
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
                            width:
                                channel.extraData["isConv"] == null ? 300 : 280,
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    //TODO : Check if not break
                                    Navigator.pop(context);
                                    _chatController.resetChannel();
                                  },
                                  child: Icon(
                                    Icons.keyboard_arrow_left_rounded,
                                    size: 42,
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    if (fromProfile) {
                                    } else {
                                      if (channel.extraData['isConv'] != null &&
                                          channel.extraData['isConv'] as bool) {
                                        commonController.userClicked.value =
                                            userFromJson(json.encode(channel
                                                .state?.members
                                                .where((element) =>
                                                    element.userId !=
                                                    StreamChat.of(context)
                                                        .currentUser!
                                                        .id)
                                                .first
                                                .user!
                                                .extraData["userDTO"]));
                                        pushNewScreen(context,
                                            screen:
                                                const SettingsProfileElseScreen(
                                                    fromConversation: true,
                                                    fromProfile: false));
                                      } else if (channel.extraData["isConv"] ==
                                              null ||
                                          (channel.extraData["isConv"] !=
                                                  null &&
                                              channel.extraData["isConv"] ==
                                                  false)) {
                                        _chatController.channel.value = channel;
                                        if (channel.extraData['isConv'] !=
                                                null &&
                                            !(channel.extraData['isConv']
                                                as bool)) {
                                          pushNewScreen(context,
                                              screen:
                                                  const SettingsGroupScreen());
                                        } else {
                                          pushNewScreen(context,
                                              screen:
                                                  const CommunitySettingScreen());
                                        }
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(90),
                                        child: getImageForChannel(
                                            channel, context)),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    if (fromProfile) {
                                    } else {
                                      if (channel.extraData['isConv'] != null &&
                                          channel.extraData['isConv'] as bool) {
                                        commonController.userClicked.value =
                                            userFromJson(json.encode(channel
                                                .state?.members
                                                .where((element) =>
                                                    element.userId !=
                                                    StreamChat.of(context)
                                                        .currentUser!
                                                        .id)
                                                .first
                                                .user!
                                                .extraData["userDTO"]));
                                        pushNewScreen(context,
                                            screen:
                                                const SettingsProfileElseScreen(
                                                    fromConversation: true,
                                                    fromProfile: false));
                                      } else if (channel.extraData["isConv"] ==
                                              null ||
                                          (channel.extraData["isConv"] !=
                                                  null &&
                                              channel.extraData["isConv"] ==
                                                  false)) {
                                        _chatController.channel.value = channel;
                                        if (channel.extraData['isConv'] !=
                                                null &&
                                            !(channel.extraData['isConv']
                                                as bool)) {
                                          pushNewScreen(context,
                                              screen:
                                                  const SettingsGroupScreen());
                                        } else {
                                          pushNewScreen(context,
                                              screen:
                                                  const CommunitySettingScreen());
                                        }
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _chatController.isEditingProfile.value
                                            ? SizedBox(
                                                width: 150,
                                                child: TextField(
                                                  autofocus: true,
                                                  maxLines: 1,
                                                  controller: _chatController
                                                      .usernameElseTextEditingController
                                                      .value,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontFamily: "Gilroy",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: MediaQuery.of(
                                                                      context)
                                                                  .platformBrightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black),
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          isCollapsed: true,
                                                          hintText: ""),
                                                ),
                                              )
                                            : SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.5,
                                                child: Text(
                                                  getDisplayName(
                                                      channel, context),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: "Gilroy",
                                                      color: MediaQuery.of(
                                                                      context)
                                                                  .platformBrightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black),
                                                ),
                                              ),
                                        //TODO : check -3
                                        (channel.extraData['isConv'] == null) ||
                                                (channel.extraData["isConv"] !=
                                                        null &&
                                                    channel.extraData[
                                                            "isConv"] ==
                                                        false) ||
                                                (channel.extraData[
                                                            "isGroupPaying"] !=
                                                        null &&
                                                    channel.extraData[
                                                            "isGroupPaying"] ==
                                                        true)
                                            ? Text(
                                                "${channel.extraData['isConv'] == null ? _chatController.channel.value!.memberCount! - 3 : _chatController.channel.value!.memberCount!} ${_chatController.channel.value!.memberCount! == 1 ? "participant" : "participants"}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: "Gilroy",
                                                    color: MediaQuery.of(
                                                                    context)
                                                                .platformBrightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          channel.extraData["isConv"] == null ||
                                  (channel.extraData["isConv"] != null &&
                                      channel.extraData["isConv"] == false) ||
                                  (channel.extraData['isGroupPaying'] != null &&
                                          channel.extraData['isGroupPaying']
                                              as bool ||
                                      (channel.memberCount == null ||
                                          channel.memberCount == 0 &&
                                              !channel.id!.contains('members')))
                              ? Container()
                              : _chatController.isEditingProfile.value
                                  ? Container()
                                  : Transform.translate(
                                      offset: const Offset(16, 1),
                                      child: IconButton(
                                          onPressed: () async {
                                            _callController.userCalled.value =
                                                userFromJson(json.encode(channel
                                                    .state?.members
                                                    .where((element) =>
                                                        element.userId !=
                                                        StreamChat.of(context)
                                                            .currentUser!
                                                            .id)
                                                    .first
                                                    .user!
                                                    .extraData["userDTO"]));
                                            _callController.isFromConv.value =
                                                true;
                                            await _callController
                                                .inviteToJoinCall(
                                                    _callController
                                                        .userCalled.value,
                                                    DateTime.now().toString(),
                                                    _homeController.id.value);
                                          },
                                          icon: Image.asset(
                                            "assets/images/call_tab.png",
                                            width: 24,
                                            height: 24,
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                    ),
                          (channel.memberCount == null ||
                                      channel.memberCount == 0) &&
                                  !channel.id!.contains('members')
                              ? Container()
                              : _chatController.isEditingProfile.value
                                  ? InkWell(
                                      onTap: () async {
                                        if (_chatController
                                            .usernameElseTextEditingController
                                            .value
                                            .text
                                            .isNotEmpty) {
                                          await _profileController.updateMe(
                                              UpdateMeDto(nicknames: {
                                                _commonController.userClicked
                                                        .value!.wallet!:
                                                    _chatController
                                                        .usernameElseTextEditingController
                                                        .value
                                                        .text
                                              }),
                                              StreamChat.of(context).client);
                                          _homeController.updateNickname(
                                              _commonController
                                                  .userClicked.value!.wallet!,
                                              _chatController
                                                  .usernameElseTextEditingController
                                                  .value
                                                  .text);
                                          _chatController
                                              .isEditingProfile.value = false;
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "Field can not be empty",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 16.0, right: 16),
                                        child: Text("DONE",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Gilroy',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: SColors.activeColor)),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {},
                                      child: Container(
                                        width: 0,
                                        height: 0,
                                        color: Colors.transparent,
                                      ),
                                    )
                        ],
                      ),
                    ),
                  ),
                )));
      },
    );
  }

  String getDisplayName(Channel channel, BuildContext context) {
    // Condition 1: memberCount is null or zero, and channel id does not contain 'members'
    if ((channel.memberCount == null || channel.memberCount == 0) &&
        !channel.id!.contains('members')) {
      return handleMemberCountNull(channel);
    }

    // Condition 2: isConv is null
    if (channel.extraData["isConv"] == null) {
      return handleIsConvNull(channel);
    }

    // Condition 3: Other cases (this is just a placeholder, you can customize)
    return handleOtherCases(channel, context);
  }

// Helper function for handling null memberCount
  String handleMemberCountNull(Channel channel) {
    if (channel.extraData['ens'] == null || channel.extraData['ens'] == "0") {
      return handleWalletOrGroupPaying(channel);
    } else {
      return channel.extraData['ens'] as String;
    }
  }

// Helper function for handling null isConv
  String handleIsConvNull(Channel channel) {
    return channel.extraData['nameOfGroup'] as String? ??
        truncateName(channel.name!);
  }

// Helper function for handling wallet or group paying condition
  String handleWalletOrGroupPaying(Channel channel) {
    if (channel.extraData['isGroupPaying'] != null &&
        channel.extraData["isGroupPaying"] == true) {
      return channel.extraData["nameOfGroup"] as String;
    } else {
      return "${(channel.extraData["wallet"] as String).substring(0, 6)}...${(channel.extraData["wallet"] as String).substring((channel.extraData["wallet"] as String).length - 4)}";
    }
  }

// Helper function to truncate name
  String truncateName(String name) {
    return name.substring(0, name.length < 25 ? name.length : 25);
  }

// Helper function for other cases (this is just a placeholder, you can customize)
  String handleOtherCases(Channel channel, dynamic context) {
    if (channel.extraData['isConv'] != null &&
        channel.extraData["isConv"] == false) {
      return channel.extraData["nameOfGroup"] as String;
    } else {
      var memberData = channel.state?.members
          .where((element) =>
              element.userId != StreamChat.of(context).currentUser!.id)
          .first
          .user!
          .extraData["userDTO"];
      var user = userFromJson(json.encode(memberData));
      return displayName(user, _homeController);
    }
  }

  Widget getImageForChannel(Channel channel, BuildContext context) {
    if (channel.memberCount == null ||
        channel.memberCount == 0 && !channel.id!.contains('members')) {
      return Image.asset("assets/images/app_icon_rounded.png");
    }

    if (channel.extraData['isConv'] != null) {
      if (!(channel.extraData['isConv'] as bool)) {
        return handleGroupChatCase(channel, context);
      } else {
        return handlePersonalChatCase(channel, context);
      }
    }

    return handleDefaultCase(channel);
  }

  Widget handleGroupChatCase(Channel channel, BuildContext context) {
    String? picOfGroup =
        _chatController.channel.value!.extraData["picOfGroup"] as String?;

    if (picOfGroup == null) {
      return TinyAvatar(
          baseString: channel.extraData["nameOfGroup"] as String,
          dimension: 40,
          circular: true,
          colourScheme: TinyAvatarColourScheme.seascape);
    } else {
      return buildCachedNetworkImage(picOfGroup);
    }
  }

  Widget handlePersonalChatCase(Channel channel, BuildContext context) {
    String? userPicture = userFromJson(json.encode(channel.state?.members
            .where((element) =>
                element.userId != StreamChat.of(context).currentUser!.id)
            .first
            .user!
            .extraData["userDTO"]))
        .picture;

    if (userPicture == null) {
      String userWallet = userFromJson(json.encode(channel.state?.members
              .where((element) =>
                  element.userId != StreamChat.of(context).currentUser!.id)
              .first
              .user!
              .extraData["userDTO"]))
          .wallet!;
      return TinyAvatar(
          baseString: userWallet,
          dimension: 40,
          circular: true,
          colourScheme: TinyAvatarColourScheme.seascape);
    } else {
      return buildCachedNetworkImage(userPicture);
    }
  }

  Widget handleDefaultCase(Channel channel) {
    return channel.image == null
        ? TinyAvatar(
            baseString: channel.name!,
            dimension: 40,
            circular: true,
            colourScheme: TinyAvatarColourScheme.seascape)
        : buildCachedNetworkImage(channel.image!);
  }

  Widget buildCachedNetworkImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          Center(child: CircularProgressIndicator(color: SColors.activeColor)),
      errorWidget: (context, url, error) =>
          Image.asset("assets/images/app_icon_rounded.png"),
    );
  }
}
