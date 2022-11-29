import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/new_message_screen.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/view/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

  final _chatController = Get.put(ChatsController());
  final _homeController = Get.put(HomeController());
  StreamChannelListController? streamChannelListControllerFriends;
  StreamChannelListController? streamChannelListControllerOthers;
  final _floatingSearchBarController = FloatingSearchBarController();

  @override
  void initState() {
    streamChannelListControllerFriends = buildStreamChannelListController(true);
    streamChannelListControllerOthers = buildStreamChannelListController(false);
    super.initState();
  }

  @override
  void dispose() {
    streamChannelListControllerFriends?.dispose();
    streamChannelListControllerOthers?.dispose();
    super.dispose();
  }

  StreamChannelListController buildStreamChannelListController(bool searchFriends){
    return StreamChannelListController(
      client: StreamChat.of(context).client,
      filter:
      _chatController.searchIsActive.value && _chatController.query.value.isNotEmpty ?
      Filter.and([
        Filter.autoComplete('member.user.name', _chatController.query.value),
        Filter.in_("members", [_homeController.id.value]),
        //Filter.equal("member_count", 2),
        if(searchFriends)
          Filter.or([
            Filter.greaterOrEqual("followCount", 2),
            Filter.and([
              Filter.equal("followCount", 1),
              Filter.notIn("isInFollowing", [_homeController.id.value])
            ])
          ])
        else
          Filter.or([
            Filter.notExists("isInFollowing"),
            Filter.equal("isInFollowing", []),
            Filter.notExists('followCount'),
            Filter.equal("followCount", 0),
            Filter.and([
              Filter.equal("followCount", 1),
              Filter.in_("isInFollowing", [_homeController.id.value])
            ])
          ]),
      ]) :
          Filter.and([
            Filter.in_("members", [_homeController.id.value]),
            //Filter.equal("member_count", 2),
            Filter.greater("last_message_at", "2020-11-23T12:00:18.54912Z"),
            if(searchFriends) 
              Filter.or([
                Filter.greaterOrEqual("followCount", 2),
                Filter.and([
                  Filter.equal("followCount", 1),
                  Filter.notIn("isInFollowing", [_homeController.id.value])
                ])
              ]) 
            else
              Filter.or([
                Filter.notExists("isInFollowing"),
                Filter.equal("isInFollowing", []),
                Filter.notExists('followCount'),
                Filter.equal("followCount", 0),
                Filter.and([
                  Filter.equal("followCount", 1),
                  Filter.in_("isInFollowing", [_homeController.id.value])
                ])
              ]),
          ]),
      channelStateSort: const [SortOption('last_message_at')],
      limit: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);
    tabController.index = _chatController.index.value;
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        _chatController.index.value = tabController.index;
      }
    });

    return Scaffold(
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Column(children: [
          buildAppbar(context, tabController),
          buildListConv(context, tabController)
        ]));
  }

  MediaQuery buildListConv(BuildContext context, TabController tabController) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Expanded(
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 28),
          child: TabBarView(
            controller: tabController,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Obx(() =>StreamChannelListView(
                  emptyBuilder: (context){
                    return noGroupUI();
                  },
                  controller: _chatController.searchIsActive.value && _chatController.query.value.isNotEmpty ? buildStreamChannelListController(true) : streamChannelListControllerFriends!, onChannelTap: (channel){
                  Get.to(() => StreamChannel(channel: channel, child: const ChannelPage()))!.then((value) {
                    streamChannelListControllerFriends!.refresh();
                    streamChannelListControllerOthers!.refresh();
                  });
                  },
                ),
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Obx(() =>StreamChannelListView(
                  emptyBuilder: (context){
                    return noGroupUI();
                  },
                  controller:_chatController.searchIsActive.value && _chatController.query.value.isNotEmpty ? buildStreamChannelListController(false) : streamChannelListControllerOthers!, onChannelTap: (channel){
                  Get.to(() => StreamChannel(channel: channel, child: const ChannelPage()))!.then((value){
                    streamChannelListControllerOthers!.refresh();
                    streamChannelListControllerFriends!.refresh();
                  });
                },),
              ))
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
            con.noFriendsRes.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Get.isDarkMode ? Colors.white : Colors.black,
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


  Stack buildAppbar(BuildContext context, TabController tabController) {
    return Stack(
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
                    offset: Offset(0.0, 0.01), //(x,y)
                    blurRadius: 0.01,
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(35)),
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
                                Get.isDarkMode ? Colors.white : Colors.black,
                          ))),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Obx(() =>Text(
                          _chatController.searchIsActive.value ? _chatController.index.value == 0 ? "Friends" : "Others" :
                          con.chatsTabRes.tr,
                          style: TextStyle(
                              color: Get.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Gilroy",
                              fontSize: 20),
                        )),
                      ),
                      IconButton(
                          onPressed: () {
                            Get.to(() => const NewMessageScreen())!.then((value) {
                              streamChannelListControllerFriends!.refresh();
                              streamChannelListControllerOthers!.refresh();
                            });
                          },
                          icon: Image.asset(
                            "assets/images/plus.png",
                            color:
                                Get.isDarkMode ? Colors.white : Colors.black,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Obx(()=>Positioned(
                top: _chatController.searchIsActive.value ? Platform.isAndroid ? 80 : 60 : 110,
                child: _chatController.searchIsActive.value ? Container(
                    height: 110,
                    width: MediaQuery.of(context).size.width,
                    child:buildFloatingSearchBar()): Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.01), //(x,y)
                            blurRadius: 0.01,
                          ),
                        ],
                        color: Get.isDarkMode
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
                                    : Get.isDarkMode
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
                                    "Friends",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "Gilroy",
                                        fontWeight: FontWeight.w700,
                                        color: _chatController.index.value == 0
                                            ? Colors.white
                                            : Get.isDarkMode
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
                                    : Get.isDarkMode
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
                                            : Get.isDarkMode
                                                ? const Color(0xFF9BA0A5)
                                                : const Color(0xFF828282)),
                                  )),
                            )
                          ],
                        ),
                      ),
                    ))))
          ],
        );
  }

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
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
          color: Get.isDarkMode ? Colors.white : Colors.black,
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      hintStyle: TextStyle(
          color: Get.isDarkMode
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

}

