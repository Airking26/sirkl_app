import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/enums/gamification_enums.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/controllers/gamification_controller.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

class GamificationTaskScreen extends StatefulWidget {
  const GamificationTaskScreen({super.key});

  @override
  State<GamificationTaskScreen> createState() => _GamificationTaskScreenState();
}

class _GamificationTaskScreenState extends State<GamificationTaskScreen>
    with TickerProviderStateMixin {
  HomeController get _homeController => Get.find<HomeController>();
  late TabController tabGamificationController;
  GamificationController get _gamificationController =>
      Get.find<GamificationController>();

  @override
  void initState() {
    super.initState();
    tabGamificationController = TabController(length: 3, vsync: this);
    tabGamificationController.index = _gamificationController.index.value;
    tabGamificationController.addListener(indexChangeListener);
    _gamificationController
        .retrieveGamificationUserProgress(GamificationCycleType.daily);
  }

  void indexChangeListener() {
    if (tabGamificationController.indexIsChanging) {
      _gamificationController.index.value = tabGamificationController.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          color: const Color(0xFF102437),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [buildStatus(), buildTasksList(context)],
            ),
          ),
        ));
  }

  Column buildStatus() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            children: [
              _homeController.userMe.value.picture == null
                  ? SizedBox(
                      width: 70,
                      height: 70,
                      child: TinyAvatar(
                        baseString: _homeController.userMe.value.wallet!,
                        dimension: 70,
                        circular: true,
                        colourScheme: TinyAvatarColourScheme.seascape,
                      ))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(90.0),
                      child: CachedNetworkImage(
                          imageUrl: _homeController.userMe.value.picture!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                  color: SColors.activeColor)),
                          errorWidget: (context, url, error) => Image.asset(
                              "assets/images/app_icon_rounded.png"))),
              SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      displayName(
                          _homeController.userMe.value, _homeController),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          height: 1.0,
                          fontSize: 20,
                          fontFamily: "Gilroy",
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                  !_homeController.userMe.value.userName.isNullOrBlank!
                      ? Text("Status: Noob",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Gilroy",
                              fontWeight: FontWeight.w400,
                              color: Colors.grey))
                      : Container(),
                ],
              ),
              Spacer(),
              Column(
                children: [
                  Text("OCTO Points :",
                      style: TextStyle(
                          height: 0.5,
                          fontSize: 14,
                          fontFamily: "Gilroy",
                          fontWeight: FontWeight.w600,
                          color: Colors.grey)),
                  SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      Text(
                        _homeController.userMe.value.octoPoints?.toString() ??
                            '0',
                        style: TextStyle(
                            fontSize: 32,
                            fontFamily: "Gilroy",
                            fontWeight: FontWeight.w600,
                            color: SColors.activeColor),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Image.asset(
                        "assets/images/octo.png",
                        width: 36,
                        height: 36,
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
        SizedBox(
          height: 4,
        ),
        TabBar(
            controller: tabGamificationController,
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
              color: Colors.white,
            ),
            tabs: [
              Text(
                "Daily",
              ),
              Text(
                "Weekly",
              ),
              Text(
                "Special",
              )
            ]),
      ],
    );
  }

  MediaQuery buildTasksList(BuildContext context) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Expanded(
            child: Container(
          color: const Color(0xFF102437),
          child: _gamificationController.loadingTasks.value
              ? Center(
                  child: CircularProgressIndicator(
                    color: SColors.activeColor,
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: TabBarView(
                        viewportFraction: 0.99,
                        physics: const NeverScrollableScrollPhysics(),
                        controller: tabGamificationController,
                        children: [
                          ListView.builder(
                            itemBuilder: (context, index) {
                              return ListTile(
                                visualDensity: VisualDensity.compact,
                                titleAlignment: ListTileTitleAlignment.top,
                                minLeadingWidth: 0,
                                minVerticalPadding: 18,
                                dense: true,
                                leading: Column(
                                  children: [
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: _gamificationController
                                                  .dailyTasks
                                                  .value
                                                  ?.taskProgress?[index]
                                                  .completed ??
                                              false
                                          ? SColors.activeColor
                                          : Colors.grey,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                title: Text(
                                  _gamificationController
                                          .dailyTasks
                                          .value
                                          ?.taskProgress?[index]
                                          .taskName
                                          ?.capitalizeFirst ??
                                      '',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Gilroy",
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                                subtitle: Text(
                                  _gamificationController
                                          .dailyTasks
                                          .value
                                          ?.taskProgress?[index]
                                          .taskDescription ??
                                      '',
                                  style: TextStyle(
                                      fontFamily: "Gilroy", color: Colors.grey),
                                ),
                                trailing: Text(
                                  "+${_gamificationController.dailyTasks.value?.taskProgress?[index].points ?? ''}",
                                  style: TextStyle(
                                      fontFamily: "Gilroy",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: _gamificationController
                                                  .dailyTasks
                                                  .value
                                                  ?.taskProgress?[index]
                                                  .completed ??
                                              false
                                          ? SColors.activeColor
                                          : Colors.grey),
                                ),
                              );
                            },
                            itemCount: _gamificationController
                                .dailyTasks.value?.taskProgress?.length,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 96),
                              Icon(
                                Icons.lock_clock_outlined,
                                color: Colors.white,
                                size: 96,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                textAlign: TextAlign.center,
                                "Coming soon...",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Gilroy',
                                    color: Colors.white,
                                    fontSize: 24),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 96),
                              Icon(
                                Icons.lock_clock_outlined,
                                color: Colors.white,
                                size: 96,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                textAlign: TextAlign.center,
                                "Coming soon...",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Gilroy',
                                    color: Colors.white,
                                    fontSize: 24),
                              ),
                            ],
                          ),
                        ]),
                  ),
                ),
        )));
  }
}
