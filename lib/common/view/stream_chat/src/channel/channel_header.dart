import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/chats/ui/settings_group_screen.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/nft_modification_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/dialog/custom_dial.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/groups/controller/groups_controller.dart';
import 'package:sirkl/groups/ui/community_settings_screen.dart';
import 'package:sirkl/groups/ui/group_participants_screen.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:sirkl/profile/ui/settings_profile_else_screen.dart';
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

  YYDialog dialogMenu = YYDialog();
  final _commonController = Get.put(CommonController());
  final _navigationController = Get.put(NavigationController());
  final _homeController = Get.put(HomeController());
  final _chatController = Get.put(ChatsController());
  final _groupController = Get.put(GroupsController());
  final _profileController = Get.put(ProfileController());
  final _callController = Get.put(CallsController());
  final utils = Utils();


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
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
                    MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E2032) : Colors.white
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
                      width: channel.isGroup ? 300 : 280,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: (){Navigator.pop(context);},
                            child: Icon(Icons.keyboard_arrow_left_rounded,size: 42,color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if(fromProfile){
                              } else {
                                if (channel.extraData['isConv'] != null &&
                                    channel.extraData['isConv'] as bool) {
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
                                  pushNewScreen(context,
                                      screen: const SettingsProfileElseScreen(
                                          fromConversation: true,
                                          fromProfile: false));
                                }
                                else if (channel.isGroup || (channel.extraData['isGroupPaying'] != null &&
                                    channel.extraData['isGroupPaying'] as bool)) {
                                  _chatController.channel.value = channel;
                                  if (channel.extraData['isConv'] != null &&
                                      !(channel.extraData['isConv'] as bool)) {
                                    pushNewScreen(context,
                                        screen: const SettingsGroupScreen());
                                  } else {
                                    pushNewScreen(context,
                                        screen: const CommunitySettingScreen());
                                  }
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(90),
                                  child:
                                  (channel.memberCount == null || channel.memberCount == 0) && !channel.id!.contains('members') ?
                                      Image.asset("assets/images/app_icon_rounded.png") :
                                  channel.extraData['isConv'] !=null && !(channel.extraData['isConv'] as bool) ?
                                      _chatController.channel.value!.extraData["picOfGroup"] == null ?
                                  TinyAvatar(baseString: (channel.extraData["isGroupPaying"] != null && (channel.extraData["isGroupPaying"]) as bool) ?
                                  channel.extraData["nameOfGroup"] as String : userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!, dimension: 40, circular: true,
                                      colourScheme: TinyAvatarColourScheme.seascape) :
                                  CachedNetworkImage(
                                      imageUrl: _chatController.channel.value!.extraData["picOfGroup"] as String,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                                      errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")
                                  ) :
                                  channel.extraData['isConv'] !=null && channel.extraData['isConv'] as bool ?
                                  userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).picture == null ?
                                  TinyAvatar(baseString: userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!, dimension: 40, circular: true,
                                      colourScheme: TinyAvatarColourScheme.seascape) :
                                  CachedNetworkImage(
                                    imageUrl: userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).picture!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                                      errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")
                                  ) :
                                      channel.image == null ?
                                      TinyAvatar(baseString: channel.name!, dimension: 40, circular: true,
                                          colourScheme: TinyAvatarColourScheme.seascape) :
                                  CachedNetworkImage(
                                    imageUrl: channel.image!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                                      errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")
                                  )
                              )
                              ,
                            ),
                          ),
                          InkWell(
                            onTap: () async{
                              if(fromProfile){
                              } else {
                                if (channel.extraData['isConv'] != null &&
                                    channel.extraData['isConv'] as bool) {
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
                                  pushNewScreen(context,
                                      screen: const SettingsProfileElseScreen(
                                          fromConversation: true,
                                          fromProfile: false));
                                } else if (channel.isGroup|| (channel.extraData['isGroupPaying'] != null &&
                                    channel.extraData['isGroupPaying'] as bool)) {
                                  _chatController.channel.value = channel;
                                  if (channel.extraData['isConv'] != null &&
                                      !(channel.extraData['isConv'] as bool)) {
                                    pushNewScreen(context,
                                        screen: const SettingsGroupScreen());
                                  } else {
                                    pushNewScreen(context,
                                        screen: const CommunitySettingScreen());
                                  }
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _chatController.isEditingProfile.value ?
                                  SizedBox(
                                    width: 150,
                                    child: TextField(
                                      autofocus: true,
                                      maxLines: 1,
                                      controller: _chatController.usernameElseTextEditingController.value,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isCollapsed: true,
                                          hintText: ""
                                      ),
                                    ),
                                  ):SizedBox(
                                    width: MediaQuery.of(context).size.width / 2.5,
                                    child: Text(
                                    (channel.memberCount == null || channel.memberCount == 0) && !channel.id!.contains('members') ?
                                        (channel.extraData['ens'] == null || channel.extraData['ens'] == "0") ?
                                        (channel.extraData['isGroupPaying'] != null && channel.extraData["isGroupPaying"] == true) ?
                                        channel.extraData["nameOfGroup"] :
                                    "${(channel.extraData["wallet"] as String).substring(0, 6)}...${(channel.extraData["wallet"] as String).substring((channel.extraData["wallet"] as String).length - 4)}":
                                        channel.extraData['ens']:
                                      channel.memberCount != null && channel.memberCount! > 2 ?
                                          channel.extraData['nameOfGroup'] == null ?
                                          channel.name!.substring(0, channel.name!.length < 25 ? channel.name!.length : 25) :
                                          channel.extraData["nameOfGroup"]
                                              :
                                      (channel.extraData['isGroupPaying'] != null && channel.extraData["isGroupPaying"] == true) ?
                                      channel.extraData["nameOfGroup"] :
                                      _homeController.nicknames[userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!] != null ?
                                      _homeController.nicknames[userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!] + " (" + (!userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).userName.isNullOrBlank! ?
                                            userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).userName! : "${userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!.substring(0,6)}...${userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!.substring(userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!.length - 4)}") + ")"
                                              : (!userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).userName.isNullOrBlank! ?
                                          userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).userName! : "${userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!.substring(0,6)}...${userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!.substring(userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!.length - 4)}"),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Gilroy",
                                          color: MediaQuery.of(context).platformBrightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                  (channel.memberCount != null && channel.memberCount! > 2) || (channel.extraData["isGroupPaying"] != null && channel.extraData["isGroupPaying"] == true)  ? Text(
                                    "${channel.extraData['isConv'] == null ? _chatController.channel.value!.memberCount! - 2 : _chatController.channel.value!.memberCount!} participants",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Gilroy",
                                        color: MediaQuery.of(context).platformBrightness == Brightness.dark
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
                    channel.isGroup || (channel.extraData['isGroupPaying'] != null &&
                        channel.extraData['isGroupPaying'] as bool) ? Container() :  _chatController.isEditingProfile.value ? Container() : Transform.translate(
                      offset: const Offset(16, 1),
                      child: IconButton(onPressed: () async {
                        _callController.userCalled.value = userFromJson(
                            json.encode(channel.state?.members
                                .where((element) =>
                            element.userId != StreamChat
                                .of(context)
                                .currentUser!
                                .id)
                                .first
                                .user!
                                .extraData["userDTO"]));
                        _callController.isFromConv.value = true;
                        //var t = await StreamChat.of(context).client.createCall(callId: DateTime.now().toString(), callType: 'video', channelType: channel.type, channelId: channel.id!, );
                        await _callController.inviteCall(_callController.userCalled.value, DateTime.now().toString(), _homeController.id.value);
                      }, icon: Image.asset(
                        "assets/images/call_tab.png",
                        width: 24,
                        height: 24,
                        color:
                        MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                      )),
                    ),
                    (channel.memberCount == null || channel.memberCount == 0) && !channel.id!.contains('members') ? Container() :
                    _chatController.isEditingProfile.value ? InkWell(
                      onTap: () async {
                        if(_chatController.usernameElseTextEditingController.value.text.isNotEmpty) {
                          await _profileController.updateMe(UpdateMeDto(
                              nicknames: {
                                _commonController.userClicked.value!
                                    .wallet!: _chatController
                                    .usernameElseTextEditingController.value
                                    .text
                              }), StreamChat
                              .of(context)
                              .client);
                          _homeController.updateNickname(
                              _commonController.userClicked.value!.wallet!,
                              _chatController
                                  .usernameElseTextEditingController.value
                                  .text);
                          _chatController.isEditingProfile.value = false;
                        } else {
                          Fluttertoast.showToast(
                              msg: "Field can not be empty",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 16.0, right: 16),
                        child: Text("DONE", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Gilroy', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF00CB7D))),
                      ),
                    ) :
                        InkWell(
                          onTap: ()async{
                          },
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
          ))
        );
      },
    );
  }

}
