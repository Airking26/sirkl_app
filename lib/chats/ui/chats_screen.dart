import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/new_message_screen.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/inbox_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:zego_zim/zego_zim.dart';

import '../../common/view/detailed_message/detailed_message_screen.dart';


class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with TickerProviderStateMixin {

  final _chatController = Get.put(ChatsController());
  final _commonController = Get.put(CommonController());
  final _homeController = Get.put(HomeController());
  final PagingController<int, InboxDto> pagingFriendController = PagingController(firstPageKey: 0);
  final PagingController<int, InboxDto> pagingOtherController = PagingController(firstPageKey: 0);
  static var pageKey = 0;

  @override
  void initState() {
    _chatController.lastConv.value = null;
    pagingFriendController.addPageRequestListener((pageKey) {fetchPageConversations();});
    pagingOtherController.addPageRequestListener((pageKey) {fetchPageConversations();});
    super.initState();
  }

  Future<void> fetchPageConversations() async {
    try {
      List<InboxDto> newItems = await _chatController.retrieveInboxes(pageKey);
      List<InboxDto> newItemsFriends = newItems.where((owned) => owned.ownedBy!.firstWhere((element) => element.id != _homeController.userMe.value.id!).isInFollowing!).toList();
      List<InboxDto> newItemsOthers = newItems.where((owned) => !owned.ownedBy!.firstWhere((element) => element.id != _homeController.userMe.value.id!).isInFollowing!).toList();
      final isLastPage = newItems.length < 9;
      if (isLastPage) {
        pagingFriendController.appendLastPage(newItemsFriends);
        pagingOtherController.appendLastPage(newItemsOthers);
      } else {
        final nextPageKey = pageKey++;
        pagingFriendController.appendPage(newItemsFriends, nextPageKey);
        pagingOtherController.appendPage(newItemsOthers, nextPageKey);
      }
    } catch (error) {
      pagingFriendController.error = error;
    }
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
                            if(!_chatController.searchIsActive.value){
                                pagingFriendController.refresh();
                                pagingOtherController.refresh();
                            }
                          },
                          icon: Image.asset(
                            _chatController.searchIsActive.value ? "assets/images/close_big.png" : "assets/images/search.png",
                            color:
                                Get.isDarkMode ? Colors.white : Colors.black,
                          ))),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          con.chatsTabRes.tr,
                          style: TextStyle(
                              color: Get.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Gilroy",
                              fontSize: 20),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Get.to(() => const NewMessageScreen())!.then((value) {
                              _chatController.lastConv.value = null;
                              pagingFriendController.refresh();
                              pagingOtherController.refresh();
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
                  PagedListView.separated(
                      pagingController: pagingFriendController,
                      builderDelegate: PagedChildBuilderDelegate<InboxDto>(
                        itemBuilder: (context, item, index) => inboxTile(context, index, item)
                      ),separatorBuilder: (context, index) {
                    return const Divider(
                      color: Color(0xFF828282),
                      thickness: 0.2,
                      endIndent: 20,
                      indent: 86,
                    );
                  },),
                  PagedListView.separated(
                      pagingController: pagingOtherController,
                      builderDelegate: PagedChildBuilderDelegate<InboxDto>(
                        itemBuilder: (context, item, index) => inboxTile(context, index, item)
                      ),separatorBuilder: (context, index) {
                    return const Divider(
                      color: Color(0xFF828285),
                      thickness: 0.2,
                      endIndent: 20,
                      indent: 92,
                    );
                  },),
                ],
              ),
            ),
          ),
        );
  }

  Widget inboxTile(BuildContext context, int index, InboxDto item) {
    item.ownedBy!.removeWhere((element) => element.id == _homeController.userMe.value.id);
    var nowMilli = DateTime.now().millisecondsSinceEpoch;
    var updatedAtMilli =  DateTime.parse(item.updatedAt!.toIso8601String()).millisecondsSinceEpoch;
    var diffMilli = nowMilli - updatedAtMilli;
    var timeSince = DateTime.now().subtract(Duration(milliseconds: diffMilli));
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 12),
      child: ListTile(
        onTap: (){
          _commonController.userClicked.value = null;
          _commonController.inboxClicked.value = item;
          Get.to(() => const DetailedMessageScreenOther())!.then((value) {
          _chatController.lastConv.value = null;
              pagingFriendController.refresh();
              pagingOtherController.refresh();
          });
          },
          leading:
          ClipRRect(
            borderRadius: BorderRadius.circular(90.0),
            child:
            item.ownedBy!.first.picture == null ?
            SizedBox(width: 60, height: 60, child: TinyAvatar(baseString: item.ownedBy!.first.wallet!, dimension: 56, circular: true, colourScheme: item.ownedBy!.first.wallet![item.ownedBy!.first.wallet!.length - 1].isAz() ? TinyAvatarColourScheme.seascape : TinyAvatarColourScheme.heated,)) :
            CachedNetworkImage(
                imageUrl: item.ownedBy!.first.picture!, height: 56, width: 56, fit: BoxFit.cover,),
          ),
        trailing: Column(
          mainAxisAlignment: item.unreadMessages == 0 || item.lastSender! == _homeController.id.value ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(timeago.format(timeSince),
                style: TextStyle(fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282))),
            item.unreadMessages == 0 || item.lastSender! == _homeController.id.value  ? Container(height: 0, width: 0,) : Container(height: 24, width: 24, decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: const Color(0xFF00CB7D)), child: Padding(padding: const EdgeInsets.all(0), child: Align(alignment: Alignment.center, child: Text(textAlign: TextAlign.center, item.unreadMessages.toString() , style: TextStyle(color: Get.isDarkMode ? const Color(0xFF232323) : Colors.white, fontFamily: 'Gilroy', fontSize: 12, fontWeight: FontWeight.w600),)),),)
          ],
        ),
        title: Transform.translate(
          offset: const Offset(-4, 0),
          child: Text(item.ownedBy!.first.userName.isNullOrBlank! ? item.ownedBy!.first.wallet! : item.ownedBy!.first.userName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600,
                    color: Get.isDarkMode ? Colors.white : Colors.black)),
        ),
        subtitle: Transform.translate(offset: const Offset(-2, 0), child: Text(item.lastMessage!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: item.unreadMessages == 0 || item.lastSender! == _homeController.id.value  ? FontWeight.w500 : FontWeight.w700, color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282)))),
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      clearQueryOnClose: false,
      closeOnBackdropTap: false,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      hint: 'Search here...',
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
        if(query.isNotEmpty) {
          var newItems = await _chatController.searchInInboxes(query);
          if (_chatController.index.value == 0) {
            List<InboxDto> newItemsFriends = newItems.where((owned) => owned.ownedBy!.firstWhere((element) => element.id != _homeController.userMe.value.id!).isInFollowing!).toList();
            pagingFriendController.itemList = [];
            pagingFriendController.itemList = newItemsFriends;
          } else {
            List<InboxDto> newItemsOthers = newItems.where((owned) =>
            !owned.ownedBy!.firstWhere((element) =>
            element.id != _homeController.userMe.value.id!).isInFollowing!)
                .toList();
            pagingOtherController.itemList = [];
            pagingOtherController.itemList = newItemsOthers;
          }
        } else {
            pagingFriendController.refresh();
            pagingOtherController.refresh();
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
    pagingFriendController.dispose();
    pagingOtherController.dispose();
    super.dispose();
  }
}
