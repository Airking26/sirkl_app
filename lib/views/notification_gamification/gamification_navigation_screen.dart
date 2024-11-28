import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/views/global/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/views/notification_gamification/gamification_leaderboard_screen.dart';
import 'package:sirkl/views/notification_gamification/gamification_task_screen.dart';

class GamificationNavigationScreen extends StatefulWidget {
  const GamificationNavigationScreen({super.key});

  @override
  State<GamificationNavigationScreen> createState() =>
      _GamificationNavigationScreenState();
}

class _GamificationNavigationScreenState
    extends State<GamificationNavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true,
      decoration: NavBarDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF111D28), const Color(0xFF1E2032)]),
      ),
      resizeToAvoidBottomInset: true,
      hideNavigationBarWhenKeyboardShows: true,
      popAllScreensOnTapOfSelectedTab: true,
      navBarStyle: NavBarStyle.simple,
      screens: [GamificationTaskScreen(), GamificationLeaderboardScreen()],
    );
  }

  Container buildAppbar(BuildContext context) {
    return Container(
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
            colors: [const Color(0xFF113751), const Color(0xFF1E2032)]),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  color: Colors.white,
                ),
              ),
              Text(
                "Gamification",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              IconButton(
                  onPressed: () async {},
                  icon: Icon(Icons.more_vert_outlined,
                      size: 32, color: Colors.transparent))
            ],
          ),
        ),
      ),
    );
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      /*PersistentBottomNavBarItem(
          icon: Icon(
            CupertinoIcons.home,
            size: 24,
          ),
          title: ('Main'),
          activeColorPrimary: SColors.activeColor,
          inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(
              fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)),*/
      PersistentBottomNavBarItem(
          icon: Icon(
            CupertinoIcons.doc_on_doc_fill,
            size: 24,
          ),
          title: ('Tasks'),
          activeColorPrimary: SColors.activeColor,
          inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(
              fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)),
      /*PersistentBottomNavBarItem(
          icon: Icon(
            CupertinoIcons.gift,
            size: 24,
          ),
          title: ('Rewards'),
          activeColorPrimary: SColors.activeColor,
          inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(
              fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)),*/
      PersistentBottomNavBarItem(
          icon: Icon(
            Icons.leaderboard_rounded,
            size: 24,
          ),
          title: ("Leaderboard"),
          activeColorPrimary: SColors.activeColor,
          inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(
              fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)),
      /*PersistentBottomNavBarItem(
          icon: Icon(
            CupertinoIcons.person_fill,
            size: 24,
          ),
          title: (profileTabRes.tr),
          activeColorPrimary: SColors.activeColor,
          inactiveColorPrimary: const Color(0xFF9BA0A5),
          textStyle: const TextStyle(
              fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 10)),*/
    ];
  }
}
