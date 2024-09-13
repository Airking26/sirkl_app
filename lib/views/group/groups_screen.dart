// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/controllers/groups_controller.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:sirkl/controllers/inbox_controller.dart';
import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/models/nft_modification_dto.dart';
import 'package:sirkl/views/global/material_floating_search_bar/floating_search_bar.dart';
import 'package:sirkl/views/global/material_floating_search_bar/floating_search_bar_actions.dart';
import 'package:sirkl/views/global/material_floating_search_bar/floating_search_bar_transition.dart';
import 'package:sirkl/views/global/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/views/global/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

import '../../controllers/profile_controller.dart';
import '../chats/detailed_chat_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  GroupsController get _groupController => Get.find<GroupsController>();
  HomeController get _homeController => Get.find<HomeController>();
  InboxController get _chatController => Get.find<InboxController>();
  NavigationController get _navigationController =>
      Get.find<NavigationController>();
  final _floatingSearchBarController = FloatingSearchBarController();
  ProfileController get _profileController => Get.find<ProfileController>();

  late final _controllerCommunitiesFav = StreamChannelListController(
    client: StreamChat.of(context).client,
    filter: Filter.or([
      Filter.and([
        Filter.notExists('isConv'),
        if (_homeController.contractAddresses.isNotEmpty)
          Filter.in_("contractAddress", _homeController.contractAddresses)
        else
          Filter.equal("contractAddress", ""),
        Filter.exists("${_homeController.id.value}_favorite"),
        Filter.equal("${_homeController.id.value}_favorite", true),
      ]),
      Filter.equal(
          "contractAddress",
          _homeController.userMe.value.hasSBT!
              ? "0x2B2535Ba07Cd144e143129DcE2dA4f21145a5011".toLowerCase()
              : ""),
    ]),
    limit: 10,
  );

  late final _controllerCommunitiesOther = StreamChannelListController(
    client: StreamChat.of(context).client,
    filter: Filter.and([
      Filter.notExists('isConv'),
      if (_homeController.contractAddresses.isNotEmpty)
        Filter.in_(
            "contractAddress",
            _homeController.contractAddresses
                .where((p0) =>
                    p0 !=
                    "0x2B2535Ba07Cd144e143129DcE2dA4f21145a5011".toLowerCase())
                .toList())
      else
        Filter.equal("contractAddress", ""),
      Filter.or([
        Filter.notExists("${_homeController.id.value}_favorite"),
        Filter.equal("${_homeController.id.value}_favorite", false)
      ]),
      Filter.greater('member_count', 2),
    ]),
    limit: 10,
  );

  @override
  void initState() {
    _groupController.indexCommunity.value = _homeController.userMe.value.hasSBT!
        ? 0
        : _homeController.isInFav.isEmpty
            ? 1
            : 0;
    tabController = TabController(length: 2, vsync: this);
    tabController.index = _groupController.indexCommunity.value;
    tabController.addListener(indexChangingListener);
    super.initState();
  }

  void indexChangingListener() {
    if (tabController.indexIsChanging) {
      _groupController.indexCommunity.value = tabController.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? const Color(0xFF102437)
                : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() {
          if (_groupController.refreshCommunity.value) {
            _controllerCommunitiesFav.refresh();
            _controllerCommunitiesOther.refresh();
            _groupController.refreshCommunity.value = false;
          }
          return Column(children: [
            buildAppbar(context, tabController),
            _groupController.assetAvailableToCreateCommunity.isNotEmpty &&
                    _groupController.isAddingCommunity.value
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Add a community from your collectibles and tokens",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF9BA0A5),
                          fontSize: 16,
                          fontFamily: "Gilroy",
                          fontWeight: FontWeight.w500),
                    ),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            _groupController.isAddingCommunity.value
                ? buildSelectNFT()
                : MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Expanded(
                      child: TabBarView(
                        viewportFraction: 0.99,
                        physics: const NeverScrollableScrollPhysics(),
                        controller: tabController,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 28.0),
                            child: SafeArea(
                              child: StreamChannelListView(
                                errorBuilder: (context, error) {
                                  return noGroupRetry(true);
                                },
                                channelSlidableEnabled: true,
                                onChannelFavPressed: (context, channel) async {
                                  await StreamChat.of(context)
                                      .client
                                      .updateChannelPartial(channel.id!, 'try',
                                          unset: [
                                        "${_homeController.id.value}_favorite"
                                      ]);
                                  await _profileController.updateNft(
                                      NftModificationDto(
                                          contractAddress: channel.id!,
                                          id: _homeController.id.value,
                                          isFav: false));
                                  _groupController.refreshCommunity.value =
                                      true;
                                  _homeController.isInFav.remove(channel.id);
                                  _homeController.isInFav.refresh();
                                },
                                channelConv: false,
                                channelFriends: false,
                                channelFav: true,
                                emptyBuilder: (context) {
                                  return _groupController
                                              .isSearchActiveInCommunity
                                              .value &&
                                          _groupController
                                              .queryCommunity.value.isNotEmpty
                                      ? SingleChildScrollView(
                                          child: noGroupFoundUI())
                                      : noGroupUI();
                                },
                                controller: _groupController
                                            .isSearchActiveInCommunity.value &&
                                        _groupController
                                            .queryCommunity.value.isNotEmpty
                                    ? StreamChannelListController(
                                        client: StreamChat.of(context).client,
                                        filter: Filter.and([
                                          Filter.autoComplete(
                                              'name',
                                              _groupController
                                                  .queryCommunity.value),
                                          Filter.notExists('isConv'),
                                        ]),
                                        limit: 10,
                                      )
                                    : _controllerCommunitiesFav,
                                onChannelTap: (channel) {
                                  if (_homeController.contractAddresses
                                          .contains(channel.id) ||
                                      (channel.id!.toLowerCase() ==
                                              "0x2B2535Ba07Cd144e143129DcE2dA4f21145a5011"
                                                  .toLowerCase() &&
                                          _homeController
                                              .userMe.value.hasSBT!)) {
                                    _chatController.channel.value = channel;
                                    channel
                                        .queryMembers(
                                            filter: Filter.equal(
                                                "id", _homeController.id.value))
                                        .then((value) {
                                      if (value.members.isEmpty) {
                                        channel.addMembers(
                                            [_homeController.id.value]);
                                      }
                                    });
                                    pushNewScreen(context,
                                            screen: StreamChannel(
                                                channel: channel,
                                                child: const ChannelPage()),
                                            withNavBar: false)
                                        .then((value) {
                                      _navigationController.hideNavBar.value =
                                          false;
                                    });
                                  } else {
                                    showToast(context,
                                        "This is a private chat for holders of ${channel.name}");
                                  }

                                  if (_groupController
                                      .isSearchActiveInCommunity.value) {
                                    _groupController
                                            .isSearchActiveInCommunity.value =
                                        !_groupController
                                            .isSearchActiveInCommunity.value;
                                    _groupController.queryCommunity.value = "";
                                    _floatingSearchBarController.clear();
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 28.0),
                            child: SafeArea(
                              child: StreamChannelListView(
                                errorBuilder: (context, error) {
                                  return noGroupRetry(false);
                                },
                                channelConv: false,
                                channelFriends: false,
                                channelSlidableEnabled: true,
                                channelFav: false,
                                onChannelFavPressed: (context, channel) async {
                                  await StreamChat.of(context)
                                      .client
                                      .updateChannelPartial(
                                          channel.id!, 'try', set: {
                                    "${_homeController.id.value}_favorite": true
                                  });
                                  await _profileController.updateNft(
                                      NftModificationDto(
                                          contractAddress: channel.id!,
                                          id: _homeController.id.value,
                                          isFav: true));
                                  _groupController.refreshCommunity.value =
                                      true;
                                  _homeController.isInFav.add(channel.id!);
                                  _homeController.isInFav.refresh();
                                },
                                emptyBuilder: (context) {
                                  return _groupController
                                              .isSearchActiveInCommunity
                                              .value &&
                                          _groupController
                                              .queryCommunity.value.isNotEmpty
                                      ? SingleChildScrollView(
                                          child: noGroupFoundUI())
                                      : noGroupUI();
                                },
                                controller: _groupController
                                            .isSearchActiveInCommunity.value &&
                                        _groupController
                                            .queryCommunity.value.isNotEmpty
                                    ? StreamChannelListController(
                                        client: StreamChat.of(context).client,
                                        filter: Filter.and([
                                          Filter.autoComplete(
                                              'name',
                                              _groupController
                                                  .queryCommunity.value),
                                          Filter.notExists("isConv"),
                                        ]),
                                        limit: 10,
                                      )
                                    : _controllerCommunitiesOther,
                                onChannelTap: (channel) {
                                  if (_homeController.contractAddresses
                                          .contains(channel.id) ||
                                      (channel.id!.toLowerCase() ==
                                              "0x2B2535Ba07Cd144e143129DcE2dA4f21145a5011"
                                                  .toLowerCase() &&
                                          _homeController
                                              .userMe.value.hasSBT!)) {
                                    _chatController.channel.value = channel;
                                    channel
                                        .queryMembers(
                                            filter: Filter.equal(
                                                "id", _homeController.id.value))
                                        .then((value) {
                                      if (value.members.isEmpty) {
                                        channel.addMembers(
                                            [_homeController.id.value]);
                                      }
                                    });
                                    pushNewScreen(context,
                                            screen: StreamChannel(
                                                channel: channel,
                                                child: const ChannelPage()),
                                            withNavBar: false)
                                        .then((value) {
                                      _navigationController.hideNavBar.value =
                                          false;
                                    });
                                  } else {
                                    showToast(context,
                                        "This is a private chat for holders of ${channel.name}");
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
          ]);
        }));
  }

  Widget buildAppbar(BuildContext context, TabController tabController) {
    return DeferredPointerHandler(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.topCenter,
        fit: StackFit.loose,
        children: [
          Container(
            height: _groupController.isAddingCommunity.value ? 115 : 140,
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
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xFF113751)
                        : Colors.white,
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xFF1E2032)
                        : Colors.white
                  ]),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 52.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => IconButton(
                        onPressed: () async {
                          if (!_groupController.isAddingCommunity.value) {
                            _groupController.isSearchActiveInCommunity.value =
                                !_groupController
                                    .isSearchActiveInCommunity.value;
                            if (_groupController
                                .isSearchActiveInCommunity.value) {
                              _groupController.queryCommunity.value = "";
                              _floatingSearchBarController.clear();
                            }
                          }
                        },
                        icon: Image.asset(
                          _groupController.isSearchActiveInCommunity.value
                              ? "assets/images/close_big.png"
                              : "assets/images/search.png",
                          color: _groupController.isAddingCommunity.value
                              ? Colors.transparent
                              : MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          width: 32,
                          height: 32,
                        ))),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Obx(() => Text(
                            _groupController.isAddingCommunity.value
                                ? "Add a community"
                                : _groupController
                                        .isSearchActiveInCommunity.value
                                    ? _groupController.indexCommunity.value == 0
                                        ? "Favorites"
                                        : "Others"
                                    : con.groupsTabRes.tr,
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
                          if (_groupController.isAddingCommunity.value ==
                              false) {
                            _groupController.isSearchActiveInCommunity.value =
                                false;
                          }
                          if (!_groupController.isAddingCommunity.value &&
                              _groupController
                                  .assetAvailableToCreateCommunity.isEmpty) {
                            _groupController
                                .retrieveAssetsAvailableToCreateCommunity();
                          }
                          _groupController.isAddingCommunity.value =
                              !_groupController.isAddingCommunity.value;
                        },
                        icon: Image.asset(
                          _groupController.isAddingCommunity.value
                              ? "assets/images/close_big.png"
                              : "assets/images/plus.png",
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 32,
                          height: 32,
                        )),
                  ],
                ),
              ),
            ),
          ),
          Obx(() => Positioned(
              top: 110,
              child: _groupController.isSearchActiveInCommunity.value
                  ? DeferPointer(
                      child: SizedBox(
                          height: 48,
                          width: MediaQuery.of(context).size.width,
                          child: buildFloatingSearchBar()),
                    )
                  : _groupController.isAddingCommunity.value
                      ? Container()
                      : Material(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Container(
                              height: 48,
                              width: 350,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
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
                                    dividerColor: Colors.transparent,
                                    tabs: [
                                      Container(
                                        height: 48,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gradient: _groupController
                                                      .indexCommunity.value ==
                                                  0
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
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                      colors: [
                                                          Color(0xFF2D465E),
                                                          Color(0xFF2D465E)
                                                        ])
                                                  : const LinearGradient(
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                      colors: [
                                                          Colors.white,
                                                          Colors.white
                                                        ]),
                                        ),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Favorites",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: "Gilroy",
                                                  fontWeight: FontWeight.w700,
                                                  color: _groupController
                                                              .indexCommunity
                                                              .value ==
                                                          0
                                                      ? Colors.white
                                                      : MediaQuery.of(context)
                                                                  .platformBrightness ==
                                                              Brightness.dark
                                                          ? const Color(
                                                              0xFF9BA0A5)
                                                          : const Color(
                                                              0xFF828282)),
                                            )),
                                      ),
                                      Container(
                                        height: 48,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gradient: _groupController
                                                      .indexCommunity.value ==
                                                  1
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
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                      colors: [
                                                          Color(0xFF2D465E),
                                                          Color(0xFF2D465E)
                                                        ])
                                                  : const LinearGradient(
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
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
                                                  color: _groupController
                                                              .indexCommunity
                                                              .value ==
                                                          1
                                                      ? Colors.white
                                                      : MediaQuery.of(context)
                                                                  .platformBrightness ==
                                                              Brightness.dark
                                                          ? const Color(
                                                              0xFF9BA0A5)
                                                          : const Color(
                                                              0xFF828282)),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                        )))
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
      accentColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      borderRadius: BorderRadius.circular(10),
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xFF2D465E).withOpacity(1)
              : Colors.white,
      debounceDelay: const Duration(milliseconds: 200),
      onQueryChanged: (query) async {
        if (query.isNotEmpty) _groupController.queryCommunity.value = query;
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
            _floatingSearchBarController.open();
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
            con.noGroupYetRes.tr,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Text(
            con.errorGroupCollection.tr,
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

  Column noNFTFound() {
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
            "No NFT Found",
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Text(
            con.errorGroupCollection.tr,
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

  Column noGroupFoundUI() {
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
            "No Group Found",
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Text(
            con.errorFindingCollection.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xFF9BA0A5),
                fontSize: 16,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        NiceButtons(
            stretch: false,
            width: 350,
            borderThickness: 5,
            progress: false,
            borderColor: const Color(0xff0063FB).withOpacity(0.5),
            startColor: const Color(0xff1DE99B),
            endColor: const Color(0xff0063FB),
            gradientOrientation: GradientOrientation.Horizontal,
            onTap: (finish) {
              _groupController.isAddingCommunity.value = true;
            },
            child: Text(
              con.addGroupRes.tr,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w700),
            )),
      ],
    );
  }

  Widget buildSelectNFT() {
    return _groupController.isLoadingAvailableAssets.value
        ? Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 24, right: 24),
            child: Column(
              children: [
                CircularProgressIndicator(color: SColors.activeColor),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "Please wait while we are loading your NFTs and Tokens available. This may take some time.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Gilroy",
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black),
                )
              ],
            ),
          )
        : _groupController.assetAvailableToCreateCommunity.isEmpty
            ? noNFTFound()
            : MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SafeArea(
                      child: ListView.builder(
                        itemCount: _groupController
                            .assetAvailableToCreateCommunity.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 6),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.dark
                                        ? const Color(0xFF1A2E40)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 0.01),
                                    blurRadius: 0.01,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                onTap: () async {
                                  await _groupController.createCommunity(
                                      StreamChat.of(context).client,
                                      _groupController
                                              .assetAvailableToCreateCommunity[
                                          index]);
                                  pushNewScreen(context,
                                          screen: const DetailedChatScreen(
                                            create: false,
                                            resetChannel: false,
                                          ),
                                          withNavBar: false)
                                      .then((value) {
                                    _navigationController.hideNavBar.value =
                                        false;
                                    _groupController.isAddingCommunity.value =
                                        false;
                                  });
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(90),
                                  child: CachedNetworkImage(
                                      imageUrl: _groupController
                                          .assetAvailableToCreateCommunity[
                                              index]
                                          .picture,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                              color: SColors.activeColor)),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                            "assets/images/app_icon_rounded.png",
                                            fit: BoxFit.cover,
                                          )),
                                ),
                                title: Text(
                                    _groupController
                                        .assetAvailableToCreateCommunity[index]
                                        .name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Gilroy",
                                        fontWeight: FontWeight.w600,
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
  }

  Column noGroupRetry(bool isFav) {
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
        NiceButtons(
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
              _groupController.retryProgress.value = true;
              isFav
                  ? await _controllerCommunitiesFav.doInitialLoad()
                  : await _controllerCommunitiesOther.doInitialLoad();
              _groupController.retryProgress.value = false;
            },
            child: _groupController.retryProgress.value
                ? const Center(
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white)),
                  )
                : const Text(
                    "RETRY",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: "Gilroy",
                        fontWeight: FontWeight.w700),
                  )),
      ],
    );
  }

  @override
  void dispose() {
    _controllerCommunitiesOther.dispose();
    _controllerCommunitiesFav.dispose();
    _groupController.indexCommunity.value = 0;
    tabController.removeListener(indexChangingListener);
    super.dispose();
  }
}
