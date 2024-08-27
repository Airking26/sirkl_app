// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/notification_dto.dart';
import 'package:sirkl/common/model/request_to_join_dto.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/controllers/chats_controller.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/controllers/web3_controller.dart';
import 'package:sirkl/views/chats/detailed_chat_screen.dart';
import 'package:sirkl/views/profile/profile_else_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tiny_avatar/tiny_avatar.dart';

import '../../config/s_colors.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/profile_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  ProfileController get _profileController => Get.find<ProfileController>();
  HomeController get _homeController => Get.find<HomeController>();
  ChatsController get _chatController => Get.find<ChatsController>();
  CommonController get _commonController => Get.find<CommonController>();
  NavigationController get _navigationController =>
      Get.find<NavigationController>();
  Web3Controller get _web3Controller => Get.find<Web3Controller>();
  final PagingController<int, NotificationDto> pagingController =
      PagingController(firstPageKey: 0);
  static var pageKey = 0;
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    if (!_homeController.userMe.value.hasSBT!)
      _profileController.index.value = 1;
    tabController.index = _profileController.index.value;
    tabController.addListener(indexChangingListener);
    pagingController.addPageRequestListener((pageKey) {
      fetchPageNotifications();
    });
    super.initState();
  }

  void indexChangingListener() {
    if (tabController.indexIsChanging) {
      _profileController.index.value = tabController.index;
    }
  }

  Future<void> fetchPageNotifications() async {
    try {
      List<NotificationDto> newItems = await _profileController
          .retrieveNotifications(_homeController.id.value, pageKey);
      final isLastPage = newItems.length < 12;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey++;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? const Color(0xFF102437)
                : const Color.fromARGB(255, 247, 253, 255),
        body: Column(
          children: [
            Stack(
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
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.keyboard_arrow_left_rounded,
                              size: 42,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Text(
                              con.notificationsRes.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: "Gilroy",
                                  fontWeight: FontWeight.w600,
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: Image.asset(
                                "assets/images/more.png",
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.dark
                                        ? Colors.transparent
                                        : Colors.transparent,
                                width: 42,
                                height: 42,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: 110,
                    child: Material(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                          height: 48,
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
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? const Color(0xFF2D465E).withOpacity(1)
                                      : Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 4.0, bottom: 2, left: 4, right: 4),
                            child: TabBar(
                              labelPadding: EdgeInsets.zero,
                              indicatorPadding: EdgeInsets.zero,
                              indicatorColor: Colors.transparent,
                              controller: tabController,
                              padding: EdgeInsets.zero,
                              dividerColor: Colors.transparent,
                              tabs: [
                                Container(
                                  height: 48,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient:
                                        _profileController.index.value == 0
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
                                        "All",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: "Gilroy",
                                            fontWeight: FontWeight.w700,
                                            color: _profileController
                                                        .index.value ==
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
                                  height: 48,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient:
                                        _profileController.index.value == 1
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
                                      child: RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: "SIRKL Club",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: "Gilroy",
                                                fontWeight: FontWeight.w700,
                                                color: _profileController
                                                            .index.value ==
                                                        1
                                                    ? Colors.white
                                                    : MediaQuery.of(context)
                                                                .platformBrightness ==
                                                            Brightness.dark
                                                        ? const Color(
                                                            0xFF9BA0A5)
                                                        : const Color(
                                                            0xFF828282))),
                                        _homeController.userMe.value.hasSBT!
                                            ? const WidgetSpan(
                                                child: SizedBox())
                                            : const WidgetSpan(
                                                child: SizedBox(
                                                width: 4,
                                              )),
                                        _homeController.userMe.value.hasSBT!
                                            ? const WidgetSpan(
                                                child: SizedBox())
                                            : const WidgetSpan(
                                                child: Icon(
                                                Icons.circle_notifications,
                                                size: 18,
                                              ))
                                      ]))),
                                ),
                              ],
                            ),
                          )),
                    ))
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                viewportFraction: 0.99,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: SafeArea(
                      minimum: const EdgeInsets.only(top: 24),
                      child: PagedListView.separated(
                        pagingController: pagingController,
                        builderDelegate:
                            PagedChildBuilderDelegate<NotificationDto>(
                          itemBuilder: (context, item, index) =>
                              buildNotificationTile(context, item, index),
                        ),
                        separatorBuilder: (context, index) {
                          return Divider(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? const Color(0xFF9BA0A5)
                                : const Color(0xFF828282),
                            thickness: 0.2,
                            endIndent: 20,
                            indent: 20,
                            height: 0,
                          );
                        },
                      ),
                    ),
                  ),
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: SafeArea(
                      minimum: const EdgeInsets.only(top: 24),
                      child: ListView.separated(
                        itemCount: _homeController.userMe.value.hasSBT! ? 3 : 1,
                        itemBuilder: (context, index) =>
                            buildNotificationSirklClub(context, index),
                        separatorBuilder: (context, index) {
                          return Divider(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? const Color(0xFF9BA0A5)
                                : const Color(0xFF828282),
                            thickness: 0.2,
                            endIndent: 20,
                            indent: 20,
                            height: 0,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        )));
  }

  Widget buildNotificationSirklClub(BuildContext context, int index) {
    if (_homeController.userMe.value.hasSBT!) {
      if (index == 0) {
        return Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: ListTile(
            onTap: () {
              Navigator.pop(context);
              _navigationController.controller.value.jumpToTab(2);
            },
            titleAlignment: ListTileTitleAlignment.top,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(90),
              child: Image.asset("assets/images/app_icon_rounded.png",
                  width: 55, height: 55, fit: BoxFit.cover),
            ),
            titleTextStyle: TextStyle(
                fontSize: 16,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w500,
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.white
                        : Colors.black.withOpacity(0.7)),
            title:
                const Text("You have been added to the SIRKL Club Community"),
          ),
        );
      } else if (index == 1) {
        return Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: ListTile(
            titleAlignment: ListTileTitleAlignment.top,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(90),
              child: Image.asset("assets/images/app_icon_rounded.png",
                  width: 55, height: 55, fit: BoxFit.cover),
            ),
            titleTextStyle: TextStyle(
                fontSize: 16,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w500,
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.white
                        : Colors.black.withOpacity(0.7)),
            title: const Text("Your SBT will appear in 'My NFT Collection'"),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: ListTile(
            titleAlignment: ListTileTitleAlignment.top,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(90),
              child: Image.asset("assets/images/app_icon_rounded.png",
                  width: 55, height: 55, fit: BoxFit.cover),
            ),
            titleTextStyle: TextStyle(
                fontSize: 16,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w500,
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.white
                        : Colors.black.withOpacity(0.7)),
            title: const Text("You have successfully minted your SBT"),
          ),
        );
      }
    } else {
      return Padding(
        padding: const EdgeInsets.only(right: 8, top: 16, bottom: 8),
        child: ListTile(
          titleAlignment: ListTileTitleAlignment.top,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(90),
            child: Image.asset("assets/images/app_icon_rounded.png",
                width: 55, height: 55, fit: BoxFit.cover),
          ),
          titleTextStyle: TextStyle(
              fontSize: 16,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w500,
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white
                      : Colors.black.withOpacity(0.7)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Get your Free SBT SIRKL Pass to access of the Club Community group. \n \n Powered by SKALE Network with 0 gas fee",
              ),
              Obx(() => TextButton(
                  onPressed: () async {
                    //TODO : Mint through server if needed
                    _web3Controller.isMintingInProgress.value = true;
                    var connector = await _web3Controller.connect();
                    connector.onSessionConnect.subscribe((args) async {
                      await _web3Controller.mintMethod(context, connector, args,
                          _homeController.userMe.value.wallet!);
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: SColors.activeColor,
                    elevation: 5,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2),
                    child: _web3Controller.isMintingInProgress.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: SColors.activeColor))
                        : const Text(
                            "MINT NOW",
                            style: TextStyle(
                                fontFamily: "Gilroy",
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                  )))
            ],
          ),
        ),
      );
    }
  }

  Widget buildNotificationTile(
      BuildContext context, NotificationDto item, int index) {
    return Container(
      color: item.hasBeenRead
          ? Colors.transparent
          : MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xFF9BA0A5).withOpacity(0.1)
              : const Color(0xFF828282).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 8),
        child: ListTile(
          onTap: () async {
            if ((item.type == 5 || item.type == 8) &&
                !item.channelId.isNullOrBlank! &&
                !item.channelPrice.isNullOrBlank!) {
              AlertDialog alert = _web3Controller.blockchainInfo(
                  "Please, wait while the transaction is processed. This may take some time.");
              var connector = await _web3Controller.connect();
              connector.onSessionConnect.subscribe((args) async {
                StreamChat.of(context)
                    .client
                    .queryChannels(
                        filter: Filter.equal("id", item.channelId!),
                        paginationParams: const PaginationParams(limit: 1))
                    .listen((event) async {
                  await _web3Controller.acceptInvitationMethod(
                      connector,
                      args,
                      context,
                      event[0],
                      _homeController.userMe.value.wallet!,
                      alert,
                      item.belongTo,
                      double.parse(item.channelPrice!),
                      item.inviteId!);
                });
              });
            } else if (item.type == 5 && !item.channelId.isNullOrBlank!) {
              StreamChat.of(context)
                  .client
                  .queryChannels(
                      filter: Filter.equal("id", item.channelId!),
                      paginationParams: const PaginationParams(limit: 1))
                  .listen((event) async {
                pushNewScreen(context,
                    screen: DetailedChatScreen(
                      create: false,
                      fromProfile: false,
                      channelId: event[0].id!,
                    ),
                    withNavBar: false);
              });
            } else {
              await _commonController.getUserById(item.idData);
              pushNewScreen(context,
                  screen: const ProfileElseScreen(
                    fromConversation: false,
                    fromNested: true,
                  ));
            }
          },
          trailing: item.type == 7
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () async {
                          if (await _chatController.acceptDeclineRequest(
                              RequestToJoinDto(
                                  receiver: _homeController.id.value,
                                  requester: item.requester,
                                  channelName: item.channelName,
                                  channelId: item.channelId,
                                  accept: true,
                                  paying: item.paying))) {
                            await _profileController
                                .deleteNotification(item.id);
                            pagingController.refresh();
                          }
                        },
                        icon: Icon(
                          Icons.add,
                          color: SColors.activeColor,
                        )),
                    IconButton(
                        onPressed: () async {
                          if (await _chatController.acceptDeclineRequest(
                              RequestToJoinDto(
                                  receiver: _homeController.id.value,
                                  requester: item.requester,
                                  channelName: item.channelName,
                                  channelId: item.channelId,
                                  accept: false,
                                  paying: item.paying))) {
                            await _profileController
                                .deleteNotification(item.id);
                            pagingController.refresh();
                          }
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.grey,
                        ))
                  ],
                )
              : const SizedBox(),
          leading: item.type != 0 &&
                  item.type != 1 &&
                  item.type != 5 &&
                  item.type != 6 &&
                  item.type != 7 &&
                  item.type != 8
              ? Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SColors.activeColor,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/stories.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                )
              : item.picture.isNullOrBlank!
                  ? SizedBox(
                      height: 50,
                      width: 50,
                      child: TinyAvatar(
                          baseString: item.wallet ?? "",
                          dimension: 50,
                          circular: true,
                          colourScheme: TinyAvatarColourScheme.seascape))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(90),
                      child: CachedNetworkImage(
                          imageUrl: item.picture!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                  color: SColors.activeColor)),
                          errorWidget: (context, url, error) => Image.asset(
                              "assets/images/app_icon_rounded.png",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover)),
                    ),
          title: Transform.translate(
            offset: Offset(item.picture.isNullOrBlank! ? 0 : -8, 0),
            child: buildTextNotif(item),
          ),
          //subtitle: Text("Lorem Ipsum is simply...", style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Get.isDarkMode ? Color(0xFF9BA0A5) : Color(0xFF828282))),
        ),
      ),
    );
  }

  Widget? buildTextNotif(NotificationDto item) {
    var nowMilli = DateTime.now().millisecondsSinceEpoch;
    var updatedAtMilli =
        DateTime.parse(item.createdAt.toIso8601String()).millisecondsSinceEpoch;
    var diffMilli = nowMilli - updatedAtMilli;
    var timeSince = DateTime.now().subtract(Duration(milliseconds: diffMilli));
    if (item.type == 0) {
      return RichText(
        text: TextSpan(style: const TextStyle(), children: [
          TextSpan(
              text: item.username ?? item.wallet,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w600,
                  color: SColors.activeColor)),
          TextSpan(
              text: " added you in his SIRKL - ${timeago.format(timeSince)}",
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w500,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black.withOpacity(0.6))),
        ]),
      );
    } else if (item.type == 1) {
      return RichText(
        text: TextSpan(style: const TextStyle(), children: [
          TextSpan(
              text: "You have added ",
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w500,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black.withOpacity(0.6))),
          TextSpan(
              text: item.username ?? item.wallet,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w600,
                  color: SColors.activeColor)),
          TextSpan(
              text: " in your SIRKL - ${timeago.format(timeSince)}",
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w500,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black.withOpacity(0.6))),
        ]),
      );
    } else if (item.type == 4 ||
        item.type == 5 ||
        item.type == 6 ||
        item.type == 7 ||
        item.type == 8) {
      return Text(item.message!,
          style: TextStyle(
              fontSize: 16,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w500,
              color:
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white
                      : Colors.black.withOpacity(0.6)));
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    pageKey = 0;
    pagingController.dispose();
    super.dispose();
  }
}
