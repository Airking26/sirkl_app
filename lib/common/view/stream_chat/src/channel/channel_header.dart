import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/nft_modification_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/dialog/custom_dial.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/groups/controller/groups_controller.dart';
import 'package:sirkl/groups/ui/group_participants_screen.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
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
                          IconButton(
                              onPressed: () {
                                //_chatController.channel.value = null;
                                Navigator.pop(context);
                              },
                              icon: Image.asset(
                                "assets/images/arrow_left.png",
                                color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                              )),
                          InkWell(
                            onTap: () async {
                              if(channel.extraData['isConv'] !=null && channel.extraData['isConv'] as bool) {
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
                                _navigationController.hideNavBar.value = false;
                                pushNewScreen(context,screen: const ProfileElseScreen(fromConversation: true)).then((value) => _navigationController.hideNavBar.value = true);
                              } else if(channel.isGroup){
                                _chatController.channel.value = channel;
                                _navigationController.hideNavBar.value = false;
                                pushNewScreen(context,screen: const GroupParticipantScreen()).then((value) => _navigationController.hideNavBar.value = true).then((value) => _navigationController.hideNavBar.value = true);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(90),
                                  child:
                                  (channel.memberCount == null || channel.memberCount == 0) && !channel.id!.contains('members') ?
                                      Image.asset("assets/images/app_icon_rounded.png") :
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
                              if(channel.extraData['isConv'] !=null && channel.extraData['isConv'] as bool) {
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
                                _navigationController.hideNavBar.value = false;
                                pushNewScreen(context,screen: const ProfileElseScreen(fromConversation: true)).then((value) => _navigationController.hideNavBar.value = true);
                              } else if(channel.isGroup){
                                _navigationController.hideNavBar.value = false;
                                _chatController.channel.value = channel;
                                pushNewScreen(context,screen: const GroupParticipantScreen()).then((value) => _navigationController.hideNavBar.value = true);
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
                                  ):
                                  Text(
                                  (channel.memberCount == null || channel.memberCount == 0) && !channel.id!.contains('members') ?
                                  "${(channel.extraData["wallet"] as String).substring(0, 20)}..." :
                                    channel.memberCount != null && channel.memberCount! > 2 ?
                                        channel.name!.substring(0, channel.name!.length < 25 ? channel.name!.length : 25) :
                                        _homeController.nicknames[userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!] ?? (!userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).userName.isNullOrBlank! ?
                                        userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).userName! : "${userFromJson(json.encode(channel.state?.members.where((element) => element.userId != StreamChat.of(context).currentUser!.id).first.user!.extraData["userDTO"])).wallet!.substring(0,20)}..."),
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
                                  channel.memberCount != null && channel.memberCount! > 2 ? Text(
                                    "${channel.memberCount!} participants",
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
                    channel.isGroup ? Container() :  _chatController.isEditingProfile.value ? Container() : Transform.translate(
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
                                    .wallet!: _profileController
                                    .usernameElseTextEditingController.value
                                    .text
                              }), StreamChat
                              .of(context)
                              .client);
                          _homeController.updateNickname(
                              _commonController.userClicked.value!.wallet!,
                              _profileController
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
                    IconButton(
                        onPressed: () {
                          dialogMenu = channel.memberCount == 2 ? dialogPopMenuConv(context, channel) : channel.extraData["owner"] == null ? dialogPopMenuGroup(context, channel) : dialogPopMenuGroupWithOwner(context, channel);
                        },
                        icon: Image.asset(
                          "assets/images/more.png",

                          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                        )),
                  ],
                ),
              ),
            ),
          ))
        );
      },
    );
  }

  YYDialog dialogPopMenuGroup(BuildContext context, Channel channel) {
    return YYDialog().build(context)
      ..width = 200
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.transparent : Colors.black.withOpacity(0.05)
      ..backgroundColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E3244).withOpacity(0.95) : Colors.white.withOpacity(0.95)
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: () async {
          dialogMenu.dismiss();
          if(channel.extraData["${_homeController.id.value}_favorite"] == null || channel.extraData["${_homeController.id.value}_favorite"] == false ) {
            _homeController.isInFav.add(channel.id!);
            await _profileController.updateNft(NftModificationDto(
                contractAddress: channel.id!,
                id: _homeController.id.value,
                isFav: true), channel.client);
          } else {
            _homeController.isInFav.remove(channel.id);
            await _profileController.updateNft(NftModificationDto(
                contractAddress: channel.id!,
                id: _homeController.id.value,
                isFav: false), channel.client);
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                channel.extraData["${_homeController.id.value}_favorite"] == null || channel.extraData["${_homeController.id.value}_favorite"] == false ? "• Add to favorites" : "• Remove from favorites",
                style: TextStyle(
                    fontSize: 14,
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () async {
          var creator = await _groupController.retrieveCreatorGroup(channel.id!);
          dialogMenu.dismiss();
          if(!creator.isNullOrBlank!) {
            if(creator == _homeController.userMe.value.wallet!){
              await channel.client.updateChannelPartial(channel.id!, 'try', set: {"owner": _homeController.userMe.value.wallet!});
              utils.showToast(context, "You are now the owner of the group");
            } else utils.showToast(context, 'You are not the owner of the group');
          } else utils.showToast(context, 'Error. Try again later');
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.claimOwnershipeRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.reportRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }

  YYDialog dialogPopMenuGroupWithOwner(BuildContext context, Channel channel) {
    return YYDialog().build(context)
      ..width = 200
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.transparent : Colors.black.withOpacity(0.05)
      ..backgroundColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E3244).withOpacity(0.95) : Colors.white.withOpacity(0.95)
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: () async {
          dialogMenu.dismiss();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                channel.extraData["${_homeController.id.value}_favorite"] == null || channel.extraData["${_homeController.id.value}_favorite"] == false ? "• Add to favorites" : "• Remove from favorites",
                style: TextStyle(
                    fontSize: 14,
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282) ,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () async{
          _commonController.userClicked.value = await _profileController.getUserByWallet(channel.extraData["owner"] as String);
          if(_commonController.userClicked.value!.wallet != channel.extraData["owner"] as String) pushNewScreen(context, screen: const DetailedChatScreen(create: true));
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.contactOwnerRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.reportRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }

  YYDialog dialogPopMenuConv(BuildContext context, Channel channel) {
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
    return YYDialog().build(context)
      ..width = 180
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor =
      MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.transparent : Colors.black.withOpacity(0.05)
      ..backgroundColor =
      MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E3244).withOpacity(0.95) : Colors.white.withOpacity(0.95)
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: () async {
          dialogMenu.dismiss();
          if (_commonController.userClickedFollowStatus.value) {
            if (await _commonController
                .removeUserToSirkl(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value)) {
              utils.showToast(
                  context,
                  con.userRemovedofSirklRes.trParams({
                    "user": _commonController.userClicked.value!.userName.isNullOrBlank!?
                    _commonController.userClicked.value!.wallet! : _commonController.userClicked.value!.userName!
                  }));
            }
          } else {
            if (await _commonController
                .addUserToSirkl(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value)) {
              utils.showToast(
                  context,
                  con.userAddedToSirklRes.trParams({
                    "user": _commonController.userClicked.value!.userName.isNullOrBlank! ?
                    _commonController.userClicked.value!.wallet! : _commonController.userClicked.value!.userName!
                  }));
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _commonController.userClickedFollowStatus.value
                    ? con.removeOfMySirklRes.tr
                    : con.addToMySirklRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: _commonController.userClickedFollowStatus.value ? MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282) :const Color(0xff00CB7D),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () {
          _chatController.isEditingProfile.value = true;
          dialogMenu.dismiss();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "• Add a nickname",
                style: TextStyle(
                    fontSize: 14,
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () {
          _navigationController.hideNavBar.value = false;
          pushNewScreen(context, screen: const ProfileElseScreen(fromConversation: true));
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                con.profileMenuTabRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () {
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                con.reportRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () async {
          dialogMenu.dismiss();
          showDialog(context: context,
              barrierDismissible: true,
              builder: (_) => CupertinoAlertDialog(
                title: Text("Delete Conversation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),),
                content: Text("Are you sure? This action is irreversible", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                actions: [
                  CupertinoDialogAction(child: Text("No", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)), onPressed: (){
                    Get.back();},),
                  CupertinoDialogAction(child: Text("Yes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)),
                    onPressed: () async {
                      if(!channel.id!.startsWith("!members")) await _chatController.deleteInbox(channel.id!);
                      await channel.delete();
                      Get.back();
                      Navigator.pop(context);
                    },)
                ],
              )
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "• Delete the chat",
                style: TextStyle(
                    fontSize: 14,
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..show();
  }



}
