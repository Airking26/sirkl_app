import 'dart:io';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nice_buttons/nice_buttons.dart';

import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/global_getx/chats/chats_controller.dart';

import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/global_getx/common/common_controller.dart';
import 'package:sirkl/common/view/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/global_getx/navigation/navigation_controller.dart';
import 'package:sirkl/views/chats/settings_group_screen.dart';

import '../../global_getx/home/home_controller.dart';
import 'new_message_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

  ChatsController get _chatController => Get.find<ChatsController>();
  HomeController get _homeController => Get.find<HomeController>();
  CommonController get _commonController => Get.find<CommonController>();
  NavigationController get _navigationController => Get.find<NavigationController>();

  final _floatingSearchBarController = FloatingSearchBarController();
  late TabController tabController;

  late final _controllerFriend = StreamChannelListController(
    client: StreamChat.of(context).client,
    filter: Filter.and([
      Filter.equal("type", "try"),
      Filter.or([
        Filter.in_("members", [_homeController.id.value]),
        Filter.equal("created_by_id", _homeController.id.value),
      ]),
      Filter.or([
        Filter.and([
          Filter.greater("last_message_at", "2022-11-23T12:00:18.54912Z"),
          Filter.exists("${_homeController.id.value}_follow_channel"),
          Filter.equal("${_homeController.id.value}_follow_channel", true),
          Filter.equal('isConv', true),
        ]),
        Filter.equal('isConv', false),
      ]),
    ]),
    channelStateSort: const [SortOption('last_message_at')],
    limit: 10,
    presence: true,
  );
  late final _controllerOther = StreamChannelListController(
    client: StreamChat.of(context).client,
    filter:
    Filter.and([
      Filter.equal("type", "try"),
      Filter.greater("last_message_at", "2022-11-23T12:00:18.54912Z"),
      Filter.equal('isConv', true),
      Filter.or([
        Filter.equal("created_by_id", _homeController.id.value),
        Filter.in_("members", [_homeController.id.value]),
      ]),
      Filter.or([
        Filter.notExists(
            "${_homeController.id.value}_follow_channel"),
        Filter.equal(
            "${_homeController.id.value}_follow_channel", false)
      ])
    ]),
    channelStateSort: const [SortOption('last_message_at')],
    presence: true,
    limit: 10,
  );

  @override
  void initState() {
    _controllerFriend.doInitialLoad();
    _controllerOther.doInitialLoad();
    _commonController.controllerFriend = _controllerFriend;
    _commonController.controllerOthers = _controllerOther;
        tabController = TabController(length: 2, vsync: this);
    tabController.index = _chatController.index.value;
    tabController.addListener(indexChangeListener);

    super.initState();
  }

  void indexChangeListener() {
       if (tabController.indexIsChanging) {
        _chatController.index.value = tabController.index;
      }
  }

  @override
  void dispose() {
	super.dispose();
  tabController.removeListener(indexChangeListener);
      _controllerOther.dispose();
    _controllerFriend.dispose();
    _chatController.index.value = 0;
    super.dispose();
}


  @override
  Widget build(BuildContext context) {


    return Obx(() {
      return Scaffold(
          backgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF102437)
                  : const Color.fromARGB(255, 247, 253, 255),
          body: Column(children: [
            buildAppbar(context, tabController),
            buildListConv(context, tabController)
          ]));
    });
  }

  Widget buildListConv(BuildContext context, TabController tabController) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Expanded(
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 28),
          child: TabBarView(
            viewportFraction: 0.99,
                  physics: const NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: [
                    StreamChannelListView(
                      errorBuilder: (context, error){
                        return noGroupRetry(true);
                      },
                          channelSlidableEnabled:
                              !_chatController.searchIsActive.value,
                          channelConv: true,
                          channelFriends: true,
                          channelFav: false,
                          onChannelDeletePressed: (context, channel) async {
                            showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (_) => CupertinoAlertDialog(
                                      title: Text(
                                        (channel.membership != null &&
                                                        channel.membership!
                                                                .channelRole ==
                                                            "channel_moderator" ||
                                                    channel.createdBy?.id ==
                                                        _homeController
                                                            .id.value) ||
                                                channel.extraData['isConv'] ==
                                                    true
                                            ? "Delete"
                                            : "Leave",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Gilroy",
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      content: Text(
                                          "Are you sure? This action is irreversible",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Gilroy",
                                              color: MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                      .withOpacity(0.5)
                                                  : Colors.black
                                                      .withOpacity(0.5))),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: Text("No",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: "Gilroy",
                                                  color: MediaQuery.of(context)
                                                              .platformBrightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black)),
                                          onPressed: () {
                                            Get.back();
                                          },
                                        ),
                                        CupertinoDialogAction(
                                          child: Text("Yes",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: "Gilroy",
                                                  color: MediaQuery.of(context)
                                                              .platformBrightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black)),
                                          onPressed: () async {
                                            if ((channel.membership != null &&
                                                        channel.membership!
                                                                .channelRole ==
                                                            "channel_moderator" ||
                                                    channel.createdBy?.id ==
                                                        _homeController
                                                            .id.value) ||
                                                channel.extraData['isConv'] ==
                                                    true) {
                                              channel.extraData['isConv'] == true ? await channel.truncate(skipPush: false) : await channel.delete();
                                              _commonController.refreshAllInbox();
                                              Get.back();
                                            } else {
                                              await channel.removeMembers(
                                                  [_homeController.id.value]);
                                                _commonController.refreshAllInbox();
                                              Get.back();
                                            }
                                          },
                                        )
                                      ],
                                    ));
                          },
                          emptyBuilder: (context) {
                            return noGroupUI();
                          },
                          controller: _chatController.searchIsActive.value &&
                              _chatController.query.value.isNotEmpty
                              ? StreamChannelListController(
                            client: StreamChat.of(context).client,
                            filter: Filter.or([
                              Filter.and([
                                Filter.equal("type", "try"),
                                Filter.in_("members", [_homeController.id.value]),
                                Filter.autoComplete(
                                    'member.user.name', _chatController.query.value),
                                Filter.exists("${_homeController.id.value}_follow_channel"),
                                Filter.equal(
                                    "${_homeController.id.value}_follow_channel", true),
                                Filter.equal('isConv', true),
                              ]),
                              Filter.and([
                                Filter.equal("type", "try"),
                                Filter.autoComplete(
                                    'nameOfGroup', _chatController.query.value),
                                Filter.equal('isConv', false),
                                Filter.equal('isGroupVisible', true)
                              ])
                            ]),
                            channelStateSort: const [SortOption('last_message_at')],
                            limit: 10,
                          ) : _controllerFriend,
                          onChannelTap: (channel) async {
                            _chatController.channel.value = channel;
                            if ((channel.membership == null &&
                                    !channel.state!.members
                                        .map((e) => e.userId!)
                                        .contains(_homeController.id.value)) &&
                                channel.extraData["isConv"] != null &&
                                channel.extraData["isConv"] == false && (channel.extraData["isGroupPaying"] == null || channel.extraData["isGroupPaying"] == false)) {
                              pushNewScreen(context,
                                   withNavBar: false,
                                      screen: const SettingsGroupScreen())
                                  .then((value) {
                                _controllerFriend.refresh();
                                _navigationController.hideNavBar.value =
                                    _chatController.fromGroupJoin.value;
                                _chatController.fromGroupJoin.value = false;
                              });
                            } else {
                              pushNewScreen(context,
                              withNavBar: false,
                                      screen: StreamChannel(
                                          channel: channel,
                                          
                                          child: const ChannelPage()))
                                  .then((value) async{
                                _navigationController.hideNavBar.value = false;
                                if(_chatController.needToRefresh.value) await _controllerFriend.refresh();
                                _chatController.needToRefresh.value = false;
                              });
                            }
                          },
                        ),
                    StreamChannelListView(
                      errorBuilder: (context, error){
                        return noGroupRetry(false);
                      },
                          channelSlidableEnabled:
                              !_chatController.searchIsActive.value,
                          onChannelDeletePressed: (context, channel) async {
                            showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (_) => CupertinoAlertDialog(
                                      title: Text(
                                        "Delete",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Gilroy",
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      content: Text(
                                          "Are you sure? This action is irreversible",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Gilroy",
                                              color: MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                      .withOpacity(0.5)
                                                  : Colors.black
                                                      .withOpacity(0.5))),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: Text("No",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: "Gilroy",
                                                  color: MediaQuery.of(context)
                                                              .platformBrightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black)),
                                          onPressed: () {
                                            Get.back();
                                          },
                                        ),
                                        CupertinoDialogAction(
                                          child: Text("Yes",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: "Gilroy",
                                                  color: MediaQuery.of(context)
                                                              .platformBrightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black)),
                                          onPressed: () async {
                                            await channel.truncate(skipPush: false);
                                            if (!channel.id!
                                                .startsWith("!members")) {
                                              await _chatController
                                                  .deleteInbox(channel.id!);
                                            }
                                                   _commonController.refreshAllInbox();
                                            Get.back();
                                          },
                                        )
                                      ],
                                    ));
                          },
                          onChannelAddPressed: (context, id, client) async {
                            await _commonController.addUserToSirkl(
                                id, client, _homeController.id.value);
                                       _commonController.refreshAllInbox();
                          },
                          channelConv: true,
                          channelFriends: false,
                          channelFav: false,
                          emptyBuilder: (context) {
                            return noGroupUI();
                          },
                          controller: _chatController.searchIsActive.value &&
                              _chatController.query.value.isNotEmpty ? StreamChannelListController(
                            client: StreamChat.of(context).client, filter: Filter.and([
                            Filter.equal("type", "try"),
                            Filter.autoComplete(
                                'member.user.name', _chatController.query.value),
                            Filter.greater(
                                "last_message_at", "2020-11-23T12:00:18.54912Z"),
                            Filter.equal('isConv', true),
                            Filter.or([
                              Filter.equal("created_by_id", _homeController.id.value),
                              Filter.in_("members", [_homeController.id.value]),
                            ]),
                            Filter.or([
                              Filter.notExists(
                                  "${_homeController.id.value}_follow_channel"),
                              Filter.equal(
                                  "${_homeController.id.value}_follow_channel", false)
                            ]),
                          ]),
                          channelStateSort: const [SortOption('last_message_at')],
                            limit: 10,): _controllerOther,
                          onChannelTap: (channel) {
                            _chatController.channel.value = channel;
                            pushNewScreen(context,
                            withNavBar: false,
                                    screen: StreamChannel(
                                        channel: channel,
                                        child: const ChannelPage()))
                                .then((value) {
                              _navigationController.hideNavBar.value = false;
                            });
                          },
                        )
                  ],
                ),
        ),
      ),
    );
  }

  Column noGroupUI() {
    return Column(
      children: [
        const SizedBox(
          height: 100,
        ),
        Image.asset(
          "assets/images/people.png",
          width: 150,
          height: 150,
        ),
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Text(
            _chatController.searchIsActive.value
                ? "No Chat Found"
                : con.noChatsRes.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                fontSize: 25,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        _chatController.searchIsActive.value
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 54.0),
                child: Text(
                  con.noFriendsSentenceRes.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF9BA0A5),
                      fontSize: 16,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w500),
                ),
              ),
      ],
    );
  }

  Column noGroupRetry(bool isMySirkl) {
    return Column(
      children: [
        const SizedBox(
          height: 100,
        ),
        Image.asset(
          "assets/images/people.png",
          width: 150,
          height: 150,
        ),
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Text(
                 "No Chat Found",
            textAlign: TextAlign.center,
            style: TextStyle(
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                fontSize: 25,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Obx(()=>NiceButtons(
            stretch: false,
            borderThickness: 5,
            width: 150,
            height: 45,
            progress: false,
            borderColor: const Color(0xff0063FB).withOpacity(0.5),
            startColor: const Color(0xff1DE99B),
            endColor: const Color(0xff0063FB),
            gradientOrientation: GradientOrientation.Horizontal,
            onTap: (finish) async {
              _chatController.retryProgress.value = true;
              isMySirkl ? await _controllerFriend.doInitialLoad() : await _controllerOther.doInitialLoad();
              _chatController.retryProgress.value = false;
            },
            child:
            _chatController.retryProgress.value ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white)),) : const Text("RETRY", style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w700),)
        )),
      ],
    );
  }

  Widget buildAppbar(BuildContext context, TabController tabController) {
    return DeferredPointerHandler(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.topCenter,
        fit: StackFit.loose,
        children: [
          Container(
            height: 140,
            margin: const EdgeInsets.only(bottom: 0.25),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 0.01),
                  blurRadius: 0.01,
                ),
              ],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(35)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xFF113751)
                        : Colors.white,
                    MediaQuery.of(context).platformBrightness == Brightness.dark
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
                    Obx(() => IconButton(
                        onPressed: () {
                          _chatController.searchIsActive.value =
                              !_chatController.searchIsActive.value;
                          if (_chatController.searchIsActive.value) {
                            _chatController.query.value = "";
                            _floatingSearchBarController.clear();
                            _floatingSearchBarController.close();
                          }
                        },
                        icon: Image.asset(
                          _chatController.searchIsActive.value
                              ? "assets/images/close_big.png"
                              : "assets/images/search.png",
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ))),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Obx(() => Text(
                            _chatController.searchIsActive.value
                                ? _chatController.index.value == 0
                                    ? "Inbox"
                                    : "Others"
                                : con.chatsTabRes.tr,
                            style: TextStyle(
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Gilroy",
                                fontSize: 20),
                          )),
                    ),
                    IconButton(
                        onPressed: () {
                          pushNewScreen(context,
                          withNavBar: false,
                                  screen: const NewMessageScreen())
                              .then((value) {
                            _navigationController.hideNavBar.value =
                                _chatController.fromGroupCreation.value;
                            _chatController.fromGroupCreation.value = false;
                          });
                        },
                        icon: Image.asset(
                          "assets/images/edit.png",
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )),
                  ],
                ),
              ),
            ),
          ),
          Obx(() => Positioned(
              top: _chatController.searchIsActive.value ? Platform.isAndroid ? 80 : 60 : 110,
              child: _chatController.searchIsActive.value
                  ? DeferPointer(
                      child: SizedBox(
                          height: 110,
                          width: MediaQuery.of(context).size.width,
                          child: buildFloatingSearchBar()),
                    )
                  : Container(
                      height: 50,
                      width: 350,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 0.01),
                              blurRadius: 0.01,
                            ),
                          ],
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? const Color(0xFF2D465E).withOpacity(1)
                              : Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 4.0, bottom: 2, left: 4, right: 4),
                        child: Obx(
                          () => TabBar(
                            labelPadding: EdgeInsets.zero,
                            indicatorPadding: EdgeInsets.zero,
                            indicatorColor: Colors.transparent,
                            controller: tabController,
                            padding: EdgeInsets.zero,
                            tabs: [
                              Container(
                                height: 50,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: _chatController.index.value == 0
                                      ? const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                              Color(0xFF1DE99B),
                                              Color(0xFF0063FB)
                                            ])
                                      : MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? const LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                  Color(0xFF2D465E),
                                                  Color(0xFF2D465E)
                                                ])
                                          : const LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                  Colors.white,
                                                  Colors.white
                                                ]),
                                ),
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "My SIRKL",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: "Gilroy",
                                          fontWeight: FontWeight.w700,
                                          color: _chatController.index.value ==
                                                  0
                                              ? Colors.white
                                              : MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFF9BA0A5)
                                                  : const Color(0xFF828282)),
                                    )),
                              ),
                              Container(
                                height: 50,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: _chatController.index.value == 1
                                      ? const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                              Color(0xFF1DE99B),
                                              Color(0xFF0063FB)
                                            ])
                                      : MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? const LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                  Color(0xFF2D465E),
                                                  Color(0xFF2D465E)
                                                ])
                                          : const LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                  Colors.white,
                                                  Colors.white
                                                ]),
                                ),
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Others",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: "Gilroy",
                                          fontWeight: FontWeight.w700,
                                          color: _chatController.index.value ==
                                                  1
                                              ? Colors.white
                                              : MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFF9BA0A5)
                                                  : const Color(0xFF828282)),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ))))
        ],
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      automaticallyImplyBackButton: false,
      clearQueryOnClose: false,
      closeOnBackdropTap: false,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      hint: 'Search here...',
      controller: _floatingSearchBarController,
      backdropColor: Colors.transparent,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 0),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      queryStyle: TextStyle(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      hintStyle: TextStyle(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xff9BA0A5)
              : const Color(0xFF828282),
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      elevation: 5,
      showCursor: true,
      width: 350,
      accentColor: Get.isDarkMode ? Colors.white : Colors.black,
      borderRadius: BorderRadius.circular(10),
      backgroundColor: Get.isDarkMode
          ? const Color(0xFF2D465E).withOpacity(1)
          : Colors.white,
      debounceDelay: const Duration(milliseconds: 200),
      onQueryChanged: (query) async {
        if (query.isNotEmpty){
          _chatController.query.value = query;
        }
      },
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction.icon(
          icon: Image.asset(
            "assets/images/search.png",
            width: 24,
            height: 24,
          ),
          showIfClosed: true,
          showIfOpened: true,
          onTap: () {},
        ),
      ],
      actions: const [],
      builder: (context, transition) {
        return const SizedBox(
          height: 0,
        );
      },
    );
  }

}
