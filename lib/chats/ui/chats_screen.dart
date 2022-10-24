import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/new_message_screen.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/inbox_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../common/view/detailed_message/detailed_message_screen_other.dart';


class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with TickerProviderStateMixin {
  final chatController = Get.put(ChatsController());
  final homeController = Get.put(HomeController());
  final PagingController<int, InboxDto> pagingFriendController = PagingController(firstPageKey: 0);
  final PagingController<int, InboxDto> pagingOtherController = PagingController(firstPageKey: 0);
  static var pageKey = 0;

  @override
  void initState() {
    pagingFriendController.addPageRequestListener((pageKey) {
      fetchPage();
    });
    super.initState();
  }

  Future<void> fetchPage() async {
    try {
      List<InboxDto> newItems = await chatController.retrieveInboxes(pageKey);
      List<InboxDto> newItemsFriends = newItems.where((owned) => owned.ownedBy.firstWhere((element) => element.id != homeController.userMe.value.id!).isInFollowing!).toList();
      List<InboxDto> newItemsOthers = newItems.where((owned) => !owned.ownedBy.firstWhere((element) => element.id != homeController.userMe.value.id!).isInFollowing!).toList();
      final isLastPage = newItems.length < 12;
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

    TabController _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        chatController.index.value = _tabController.index;
      }
    });

    return Scaffold(
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Column(children: [
          buildAppbar(context, _tabController),
          buildListConv(context, _tabController)
        ]));
  }

  Stack buildAppbar(BuildContext context, TabController _tabController) {
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
                      Get.isDarkMode ? const Color(0xFF111D28) : Colors.white,
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
                            chatController.searchIsActive.value = !chatController.searchIsActive.value;
                          },
                          icon: Image.asset(
                            chatController.searchIsActive.value ? "assets/images/close_big.png" : "assets/images/search.png",
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
                            Get.to(() => const NewMessageScreen());
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
                top: chatController.searchIsActive.value ? Platform.isAndroid ? 80 : 60 : 110,
                child: chatController.searchIsActive.value ? Container(
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
                          controller: _tabController,
                          padding: EdgeInsets.zero,
                          tabs: [
                            Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: chatController.index.value == 0
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
                                        color: chatController.index.value == 0
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
                                gradient: chatController.index.value == 1
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
                                        color: chatController.index.value == 1
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

  MediaQuery buildListConv(BuildContext context, TabController _tabController) {
    return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Expanded(
            child: SafeArea(
              minimum: const EdgeInsets.only(top: 28),
              child: TabBarView(
                controller: _tabController,
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
                      color: Color(0xFF828282),
                      thickness: 0.2,
                      endIndent: 20,
                      indent: 86,
                    );
                  },),
                ],
              ),
            ),
          ),
        );
  }

  Widget inboxTile(BuildContext context, int index, InboxDto item) {
    item.ownedBy.removeWhere((element) => element.id == homeController.userMe.value.id);
    var nowMilli = DateTime.now().millisecondsSinceEpoch;
    var updatedAtMilli =  DateTime.parse(item.updatedAt.toIso8601String()).millisecondsSinceEpoch;
    var diffMilli = nowMilli - updatedAtMilli;
    var timeSince = DateTime.now().subtract(Duration(milliseconds: diffMilli));
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 12),
      child: ListTile(
        onTap: (){Get.to(() => const DetailedMessageScreenOther());},
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(90.0),
            child: CachedNetworkImage(
                imageUrl: item.ownedBy.first.picture ?? "https://ik.imagekit.io/bayc/assets/bayc-footer.png", height: 60, width: 60, fit: BoxFit.cover,),
          ),
        trailing: Column(
          mainAxisAlignment: item.unreadMessages == 0 ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(timeago.format(timeSince), style: TextStyle(fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282))),
            item.unreadMessages == 0 ? Container(height: 0, width: 0,) : Container(height: 24, width: 24, decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: const Color(0xFF00CB7D)), child: Padding(padding: const EdgeInsets.all(0), child: Align(alignment: Alignment.center, child: Text(textAlign: TextAlign.center,"2", style: TextStyle(color: Get.isDarkMode ? const Color(0xFF232323) : Colors.white, fontFamily: 'Gilroy', fontSize: 12, fontWeight: FontWeight.w600),)),),)
          ],
        ),
        title: Transform.translate(
          offset: const Offset(-2, 0),
          child: Text(item.ownedBy.first.userName ?? item.ownedBy.first.wallet!,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600,
                    color: Get.isDarkMode ? Colors.white : Colors.black)),
        ),
        subtitle: Transform.translate(offset: const Offset(0, 0), child: Text(item.lastMessage, style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: item.unreadMessages == 0 ? FontWeight.w500 : FontWeight.w700, color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282)))),
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
      transitionDuration: const Duration(milliseconds: 800),
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
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
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

  @override
  void dispose() {
    pagingFriendController.dispose();
    pagingOtherController.dispose();
    super.dispose();
  }
}
