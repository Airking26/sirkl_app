import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/models/story_dto.dart';
import 'package:sirkl/models/story_modification_dto.dart';
import 'package:sirkl/views/global/nav_bar/persistent-tab-view.dart';
import 'package:story_view/story_view.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tiny_avatar/tiny_avatar.dart';

import '../../controllers/home_controller.dart';
import '../profile/profile_else_screen.dart';

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({Key? key}) : super(key: key);

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  HomeController get _homeController => Get.find<HomeController>();
  CommonController get _commonController => Get.find<CommonController>();
  NavigationController get _navigationController =>
      Get.find<NavigationController>();
  var controller = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    storyItems = _homeController
        .stories.value![_homeController.indexStory.value]!
        .map((e) => e!.type == 0
            ? StoryItem.pageImage(
                url: e.url,
                controller: controller,
                imageFit: BoxFit.fitWidth,
                duration: const Duration(seconds: 5))
            : StoryItem.pageVideo(e.url,
                controller: controller, imageFit: BoxFit.fitWidth))
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StoryView(
            onComplete: () {
              if (_homeController.stories.value!.length - 1 >
                  _homeController.actualStoryIndex.value) {
                _homeController.indexStory.value++;
                Navigator.of(context).pop(true);
                pushNewScreen(context, screen: const StoryViewerScreen());
              } else {
                _navigationController.hideNavBar.value = false;
                Navigator.pop(context);
              }
            },
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                _navigationController.hideNavBar.value = false;
                Navigator.pop(context);
              }
            },
            onStoryShow: (story, index) async {
              _homeController.actualStoryIndex.value =
                  _homeController.stories.value?.indexOf(_homeController
                          .stories.value![_homeController.indexStory.value]!) ??
                      0;
              var storyToUpdate = _homeController
                  .stories
                  .value?[_homeController.indexStory.value]![
                      storyItems.indexOf(story)]
                  ?.id;
              await _homeController.updateStory(StoryModificationDto(
                  id: storyToUpdate!, readers: [_homeController.id.value]));
            },
            storyItems: storyItems,
            controller: controller,
          ),
          Container(
            padding: const EdgeInsets.only(
              top: 64,
              left: 24,
              right: 24,
            ),
            child: _buildProfileView(_homeController
                .stories.value![_homeController.indexStory.value]!.first!),
          )
        ],
      ),
    );
  }

  Widget _buildProfileView(StoryDto story) {
    var nowMilli = DateTime.now().millisecondsSinceEpoch;
    var updatedAtMilli = DateTime.parse(story.createdAt.toIso8601String())
        .millisecondsSinceEpoch;
    var diffMilli = nowMilli - updatedAtMilli;
    var timeSince = DateTime.now().subtract(Duration(milliseconds: diffMilli));

    return InkWell(
      onTap: () {
        _commonController.userClicked.value = story.createdBy;
        pushNewScreen(context,
                screen: const ProfileElseScreen(fromConversation: false),
                withNavBar: true)
            .then((value) => _navigationController.hideNavBar.value = true);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            story.createdBy.picture.isNullOrBlank!
                ? Wrap(
                    children: [
                      TinyAvatar(
                          baseString: _homeController.userMe.value.wallet!,
                          dimension: 46,
                          circular: true,
                          colourScheme: TinyAvatarColourScheme.seascape),
                    ],
                  )
                : CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        CachedNetworkImageProvider(story.createdBy.picture!),
                  ),
            const SizedBox(
              width: 16,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName(story.createdBy, _homeController),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: "Gilroy",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  timeago.format(timeSince),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Gilroy",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.7)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
