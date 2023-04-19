import 'dart:io';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/new_message_screen.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/view/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

  final _chatController = Get.put(ChatsController());
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  final _navigationController = Get.put(NavigationController());
  StreamChannelListController? streamChannelListControllerFriends;
  StreamChannelListController? streamChannelListControllerOthers;
  final _floatingSearchBarController = FloatingSearchBarController();
  late TabController tabController;

  @override
  void initState() {
      streamChannelListControllerFriends =
          buildStreamChannelListController(true);
      streamChannelListControllerOthers =
          buildStreamChannelListController(false);
    super.initState();
  }

  StreamChannelListController buildStreamChannelListController(bool searchFriends){
    return StreamChannelListController(
      client: StreamChat.of(context).client,
      filter:
      _chatController.searchIsActive.value && _chatController.query.value.isNotEmpty ?
      Filter.and([
        Filter.autoComplete('nameOfGroup', _chatController.query.value),
        Filter.equal('isConv', false),
        Filter.equal('isGroupVisible', true)
      ])
        :
          Filter.and([
            if(searchFriends)
              Filter.and([
                Filter.in_("members", [_homeController.id.value]),
                Filter.or([
                  Filter.and([
                    Filter.greater("last_message_at", "2020-11-23T12:00:18.54912Z"),
                    Filter.exists("${_homeController.id.value}_follow_channel"),
                    Filter.equal("${_homeController.id.value}_follow_channel", true),
                    Filter.equal('isConv', true),
                  ]),
                  Filter.equal('isConv', false),
                ]),
              ])
            else
              Filter.and([
                Filter.greater("last_message_at", "2020-11-23T12:00:18.54912Z"),
                Filter.equal('isConv', true),
                Filter.or([
                  Filter.equal("created_by_id", _homeController.id.value),
                  Filter.in_("members", [_homeController.id.value]),
                ]),
                Filter.or([
                  Filter.notExists("${_homeController.id.value}_follow_channel"),
                  Filter.equal("${_homeController.id.value}_follow_channel", false)
                ])
              ])
          ]),
      channelStateSort: const [SortOption('last_message_at')],
      limit: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    tabController = TabController(length: 2, vsync: this);
    tabController.index = _chatController.index.value;
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        _chatController.index.value = tabController.index;
      }
    });

    return Obx(() {
      if(_commonController.refreshInboxes.value){
        streamChannelListControllerFriends?.refresh();
        streamChannelListControllerOthers?.refresh();
        _commonController.refreshInboxes.value = false;
      }
      return Scaffold(
          backgroundColor: MediaQuery
              .of(context)
              .platformBrightness == Brightness.dark
              ? const Color(0xFF102437)
              : const Color.fromARGB(255, 247, 253, 255),
          body: Column(children: [
            buildAppbar(context, tabController),
            buildListConv(context, tabController)
          ]));
    }
    );
  }

  Widget buildListConv(BuildContext context, TabController tabController) {
    return
    MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Expanded(
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 28),
          child: !_homeController.controllerConnected.value ? const Center(child: SizedBox(width: 40, height:40, child: CircularProgressIndicator(color:  Color(0xff00CB7D)))) : TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: tabController,
            children: [
              Obx(() =>StreamChannelListView(
                channelSlidableEnabled: true,
                channelConv : true,
                channelFriends: true,
                channelFav: false,
                onChannelDeletePressed: (context, channel) async{
                  showDialog(context: context,
                      barrierDismissible: true,
                      builder: (_) => CupertinoAlertDialog(
                        title: Text("Delete Conversation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),),
                        content: Text("Are you sure? This action is irreversible", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                        actions: [
                          CupertinoDialogAction(child: Text("No", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)), onPressed: (){ Get.back();},),
                          CupertinoDialogAction(child: Text("Yes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)),
                            onPressed: () async {
                              await channel.delete();
                              _commonController.refreshInboxes.value = true;
                              Get.back();
                            },)
                        ],
                      ));
                },
                emptyBuilder: (context){
                  return noGroupUI();
                },
                controller: _chatController.searchIsActive.value && _chatController.query.value.isNotEmpty ? buildStreamChannelListController(true) : streamChannelListControllerFriends!, onChannelTap: (channel) async{
                  _chatController.channel.value = channel;
                  _navigationController.hideNavBar.value = true;
                  if(channel.extraData["isConv"] != null && channel.extraData["isConv"] == false && channel.extraData["isGroupPrivate"] != null && channel.extraData["isGroupPrivate"] == false){
                    await channel.addMembers([ _homeController.id.value ]);
                    pushNewScreen(context, screen: StreamChannel(channel: channel, child: const ChannelPage())).then((value) {_navigationController.hideNavBar.value = false;});
                  } else if(channel.extraData["isConv"] != null && channel.extraData["isConv"] == false && channel.extraData["isGroupPrivate"] != null && channel.extraData["isGroupPrivate"] == true){
                    //await channel.a
                  } else {
                    pushNewScreen(context, screen: StreamChannel(channel: channel, child: const ChannelPage())).then((value) {_navigationController.hideNavBar.value = false;});
                  }
                },
              ),
              ),
              Obx(() =>StreamChannelListView(
                channelSlidableEnabled: true,
                onChannelDeletePressed: (context, channel) async {
                  showDialog(context: context,
                      barrierDismissible: true,
                      builder: (_) => CupertinoAlertDialog(
                        title: Text("Delete Conversation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),),
                        content: Text("Are you sure? This action is irreversible", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                        actions: [
                          CupertinoDialogAction(child: Text("No", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)), onPressed: (){ Get.back();},),
                          CupertinoDialogAction(child: Text("Yes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black)),
                            onPressed: () async {
                              if(!channel.id!.startsWith("!members")) await _chatController.deleteInbox(channel.id!);
                              await channel.delete();
                              _commonController.refreshInboxes.value = true;
                              Get.back();
                            },)
                        ],
                      ));
                },
                onChannelAddPressed: (context, id, client) async{
                  await _commonController.addUserToSirkl(id, client, _homeController.id.value);
                  _commonController.refreshInboxes.value = true;
                },
                channelConv : true,
                channelFriends: false,
                channelFav: false,
                emptyBuilder: (context){
                  return noGroupUI();
                },
                controller:_chatController.searchIsActive.value && _chatController.query.value.isNotEmpty ? buildStreamChannelListController(false) : streamChannelListControllerOthers!, onChannelTap: (channel){
                _chatController.channel.value = channel;
                _navigationController.hideNavBar.value = true;
                pushNewScreen(context, screen: StreamChannel(channel: channel, child: const ChannelPage())).then((value) {
                  _navigationController.hideNavBar.value = false;
                  //streamChannelListControllerFriends?.refresh();
                  //streamChannelListControllerOthers?.refresh();
                });
              },),
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
            con.noChatsRes.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                fontSize: 25,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
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
                        Obx(()=>IconButton(
                            onPressed: () {
                              _chatController.searchIsActive.value = !_chatController.searchIsActive.value;
                              if(_chatController.searchIsActive.value) {
                                _chatController.query.value = "";
                                _floatingSearchBarController.clear();
                                _floatingSearchBarController.close();
                              }
                            },
                            icon: Image.asset(
                              _chatController.searchIsActive.value ? "assets/images/close_big.png" : "assets/images/search.png",
                              color:
                              MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                            ))),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Obx(() =>Text(
                            _chatController.searchIsActive.value ? _chatController.index.value == 0 ? "Friends" : "Others" :
                            con.chatsTabRes.tr,
                            style: TextStyle(
                                color: MediaQuery.of(context).platformBrightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Gilroy",
                                fontSize: 20),
                          )),
                        ),
                        IconButton(
                            onPressed: () {
                              _navigationController.hideNavBar.value = true;
                              pushNewScreen(context, screen: const NewMessageScreen()).then((value) {
                                _navigationController.hideNavBar.value = _chatController.fromGroupCreation.value;
                                _chatController.fromGroupCreation.value = false;
                                if(_chatController.messageHasBeenSent.value) {
                                  _chatController.index.value = 1;
                                  tabController.index = 1;
                                  _chatController.messageHasBeenSent.value = false;
                                }
                              });
                            },
                            icon: Image.asset(
                              "assets/images/edit.png",
                              color:
                              MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              Obx(()=>Positioned(
                  top: _chatController.searchIsActive.value ? Platform.isAndroid ? 80 : 60 : 110,
                  child: _chatController.searchIsActive.value ? DeferPointer(
                    child: SizedBox(
                        height: 110,
                        width: MediaQuery.of(context).size.width,
                        child:buildFloatingSearchBar()),
                  ): Container(
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
                          color: MediaQuery.of(context).platformBrightness == Brightness.dark
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
                                      : MediaQuery.of(context).platformBrightness == Brightness.dark
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
                                          color: _chatController.index.value == 0
                                              ? Colors.white
                                              : MediaQuery.of(context).platformBrightness == Brightness.dark
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
                                      : MediaQuery.of(context).platformBrightness == Brightness.dark
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
                                          color: _chatController.index.value == 1
                                              ? Colors.white
                                              : MediaQuery.of(context).platformBrightness == Brightness.dark
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
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
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
      onQueryChanged: (query) async{
        if(query.isNotEmpty) _chatController.query.value = query;
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
          onTap: () {
          },
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

  @override
  void dispose() {
    _chatController.index.value = 0;
    super.dispose();
  }

}

