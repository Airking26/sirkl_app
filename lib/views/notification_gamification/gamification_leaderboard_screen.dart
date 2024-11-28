import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/gamification_controller.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/views/global/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/views/profile/profile_else_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

class GamificationLeaderboardScreen extends StatefulWidget {
  const GamificationLeaderboardScreen({super.key});

  @override
  State<GamificationLeaderboardScreen> createState() =>
      _GamificationLeaderboardScreenState();
}

class _GamificationLeaderboardScreenState
    extends State<GamificationLeaderboardScreen> with TickerProviderStateMixin {
  HomeController get _homeController => Get.find<HomeController>();
  CommonController get _commonController => Get.find<CommonController>();
  GamificationController get _gamificationController =>
      Get.find<GamificationController>();

  // Separate PagingControllers for each tab
  final PagingController<int, UserDTO> dailyController =
      PagingController(firstPageKey: 0);
  final PagingController<int, UserDTO> weeklyController =
      PagingController(firstPageKey: 0);
  final PagingController<int, UserDTO> allTimeController =
      PagingController(firstPageKey: 0);

  late TabController tabLeaderboardController;

  @override
  void initState() {
    tabLeaderboardController = TabController(length: 3, vsync: this);

    // Add listeners for each PagingController
    dailyController.addPageRequestListener((pageKey) {
      fetchLeaderboardPage(pageKey, 0, dailyController, (podium) {
        _gamificationController.podium.value = podium;
      });
    });

    weeklyController.addPageRequestListener((pageKey) {
      fetchLeaderboardPage(pageKey, 1, weeklyController, (podium) {
        _gamificationController.podium.value = podium;
      });
    });

    allTimeController.addPageRequestListener((pageKey) {
      fetchLeaderboardPage(pageKey, 2, allTimeController, (podium) {
        _gamificationController.podium.value = podium;
      });
    });

    // Load data for the initial tab
    _loadInitialTab();

    super.initState();
  }

  @override
  void dispose() {
    tabLeaderboardController.dispose();
    dailyController.dispose();
    weeklyController.dispose();
    allTimeController.dispose();
    super.dispose();
  }

  void _loadInitialTab() {
    final currentIndex = tabLeaderboardController.index;
    if (currentIndex == 0) {
      dailyController.refresh();
    } else if (currentIndex == 1) {
      weeklyController.refresh();
    } else {
      allTimeController.refresh();
    }
  }

  void onTabTapped(int index) {
    // Set the active tab index
    _gamificationController.indexLeaderboard.value = index;

    // Trigger data loading for the selected tab and podium
    if (index == 0) {
      dailyController.refresh();
    } else if (index == 1) {
      weeklyController.refresh();
    } else {
      allTimeController.refresh();
    }
  }

  Future<void> fetchLeaderboardPage(
    int pageKey,
    int index,
    PagingController<int, UserDTO> controller,
    Function(List<UserDTO>) updatePodium,
  ) async {
    try {
      List<UserDTO> allUsers = await _fetchLeaderboard(index, pageKey);

      // Separate top 3 podium users
      if (pageKey == 0) {
        final podiumUsers = allUsers.take(3).toList();
        updatePodium(podiumUsers);
        allUsers = allUsers.skip(3).toList();
      }

      // Check if this is the last page
      final isLastPage = allUsers.length < 9;
      if (isLastPage) {
        controller.appendLastPage(allUsers);
      } else {
        controller.appendPage(allUsers, pageKey + 1);
      }
    } catch (error) {
      controller.error = error;
    }
  }

  Future<List<UserDTO>> _fetchLeaderboard(int index, int pageKey) async {
    switch (index) {
      case 0:
        return await _gamificationController.retrieveLeaderboardDaily(pageKey);
      case 1:
        return await _gamificationController.retrieveLeaderboardWeekly(pageKey);
      case 2:
        return await _gamificationController
            .retrieveLeaderboardAllTime(pageKey);
      default:
        throw Exception("Invalid tab index");
    }
  }

  List<UserDTO>? getCurrentPodium() {
    final currentIndex = tabLeaderboardController.index;
    if (currentIndex == 0) {
      return _gamificationController.podium.value;
    } else if (currentIndex == 1) {
      return _gamificationController.podium.value;
    } else {
      return _gamificationController.podium.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          color: const Color(0xFF102437),
          child: Column(
            children: [
              SizedBox(
                height: 4,
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Second-ranked user or placeholder
                    _buildPodiumUserOrPlaceholder(2),
                    // First-ranked user or placeholder
                    _buildPodiumUserOrPlaceholder(1),
                    // Third-ranked user or placeholder
                    _buildPodiumUserOrPlaceholder(3),
                  ],
                ),
              ),
              /*SizedBox(
                height: 16,
              ),
              TabBar(
                  onTap: onTabTapped,
                  controller: tabLeaderboardController,
                  indicatorColor: SColors.activeColor,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white,
                  dividerColor: Colors.grey.withOpacity(0.25),
                  indicatorWeight: 1,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.only(bottom: 8),
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Text(
                      "Daily",
                    ),
                    Text(
                      "Weekly",
                    ),
                    Text(
                      "All Time",
                    )
                  ]),*/
              SizedBox(
                height: 8,
              ),
              Container(
                  height: 32,
                  width: MediaQuery.of(context).size.width - 32,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.01), //(x,y)
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
                    child: TabBar(
                      onTap: onTabTapped,
                      labelPadding: EdgeInsets.zero,
                      indicatorPadding: EdgeInsets.zero,
                      indicatorColor: Colors.transparent,
                      controller: tabLeaderboardController,
                      padding: EdgeInsets.zero,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Daily",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "Gilroy",
                                  fontWeight: FontWeight.w600,
                                  color: _gamificationController
                                              .indexLeaderboard.value ==
                                          0
                                      ? SColors.activeColor
                                      : Colors.white),
                            )),
                        Align(
                            alignment: Alignment.center,
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: "Weekly",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Gilroy",
                                      fontWeight: FontWeight.w600,
                                      color: _gamificationController
                                                  .indexLeaderboard.value ==
                                              1
                                          ? SColors.activeColor
                                          : Colors.white)),
                            ]))),
                        Align(
                            alignment: Alignment.center,
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: "All time",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Gilroy",
                                      fontWeight: FontWeight.w600,
                                      color: _gamificationController
                                                  .indexLeaderboard.value ==
                                              2
                                          ? SColors.activeColor
                                          : Colors.white)),
                            ]))),
                      ],
                    ),
                  )),
              SizedBox(
                height: 16,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(
                            0.05), // Adjust shadow color and opacity
                        offset: Offset(0,
                            -4), // Negative dy for shadow above the container
                        blurRadius: 8, // Smoothness of the shadow
                      ),
                    ],
                    color: const Color(
                        0xFF102437), // Slightly lighter background for leaderboard
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: TabBarView(
                    controller: tabLeaderboardController,
                    children: [
                      buildLeaderboardView(dailyController),
                      buildLeaderboardView(weeklyController),
                      buildLeaderboardView(allTimeController),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // Helper method to build Podium User
  Widget _buildPodiumUser(
      {required int rank,
      required String name,
      required int score,
      required wallet,
      String? imageUrl}) {
    return Column(
      children: [
        Icon(Icons.emoji_events,
            color: rank == 1
                ? Colors.yellow
                : rank == 2
                    ? Colors.grey
                    : Colors.brown,
            size: rank == 1
                ? 24
                : rank == 2
                    ? 22
                    : 20),
        SizedBox(
          height: 8,
        ),
        CircleAvatar(
          radius: rank == 1 ? 44 : 39,
          backgroundColor: rank == 1
              ? Colors.yellow
              : rank == 2
                  ? Colors.grey
                  : Colors.brown,
          child: imageUrl.isNullOrBlank!
              ? SizedBox(
                  width: rank == 1 ? 80 : 70,
                  height: rank == 1 ? 80 : 70,
                  child: TinyAvatar(
                    baseString: wallet,
                    dimension: rank == 1 ? 80 : 70,
                    circular: true,
                    colourScheme: TinyAvatarColourScheme.seascape,
                  ))
              : CircleAvatar(
                  radius: rank == 1 ? 40 : 35,
                  backgroundImage: CachedNetworkImageProvider(imageUrl!),
                ),
        ),
        SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Gilroy',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "$score",
          style: TextStyle(
            fontFamily: 'Gilroy',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumUserOrPlaceholder(int rank) {
    final podium = getCurrentPodium();
    if (podium != null && podium.length >= rank) {
      final user = podium[rank - 1];
      return InkWell(
        onTap: () async {
          if (user.id != _homeController.id.value) {
            _commonController.userClicked.value = user;
            pushNewScreen(context,
                screen: ProfileElseScreen(fromConversation: false),
                withNavBar: false);
          }
        },
        child: _buildPodiumUser(
          rank: rank,
          name: displayName(user, _homeController),
          score: user.octoPoints ?? 0,
          imageUrl: user.picture,
          wallet: user.wallet!,
        ),
      );
    } else {
      return _buildPodiumUser(
        rank: rank,
        name: "N/A",
        score: 0,
        imageUrl: null,
        wallet: "",
      );
    }
  }

  Widget buildLeaderboardView(PagingController<int, UserDTO> controller) {
    return PagedListView.separated(
      pagingController: controller,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      builderDelegate: PagedChildBuilderDelegate<UserDTO>(
          noItemsFoundIndicatorBuilder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 96),
            Icon(
              Icons.person_off_rounded,
              color: Colors.grey,
              size: 96,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              textAlign: TextAlign.center,
              "No user ranked yet!",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gilroy',
                  color: Colors.grey,
                  fontSize: 24),
            ),
          ],
        );
      }, itemBuilder: (context, item, index) {
        return InkWell(
          onTap: () {
            if (item.id != _homeController.id.value) {
              _commonController.userClicked.value = item;
              pushNewScreen(context,
                  screen: ProfileElseScreen(fromConversation: false),
                  withNavBar: false);
            }
          },
          child: _buildLeaderboardItem(
              rank: index + 4,
              name: displayName(item, _homeController),
              score: item.octoPoints ?? 0,
              username: item.userName,
              imageUrl: item.picture,
              wallet: item.wallet!),
        );
      }),
      separatorBuilder: (context, index) {
        return Divider(
          thickness: 0.2,
        );
      },
    );
  }

  // Helper method to build Leaderboard List Item
  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int score,
    String? username,
    required String wallet,
    String? imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      child: Row(
        children: [
          Text(
            "$rank",
            style: TextStyle(
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          imageUrl.isNullOrBlank!
              ? SizedBox(
                  width: 50,
                  height: 50,
                  child: TinyAvatar(
                    baseString: wallet,
                    dimension: 50,
                    circular: true,
                    colourScheme: TinyAvatarColourScheme.seascape,
                  ))
              : CircleAvatar(
                  radius: 25,
                  backgroundImage: CachedNetworkImageProvider(imageUrl!),
                ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                username.isNullOrBlank!
                    ? SizedBox()
                    : Text(
                        "${wallet.substring(0, 6)}...${wallet.substring(wallet.length - 4)}",
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
              ],
            ),
          ),
          Text(
            "$score",
            style: TextStyle(
              fontFamily: 'Gilroy',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
