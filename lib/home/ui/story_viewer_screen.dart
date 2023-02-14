import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/story_dto.dart';
import 'package:sirkl/common/model/story_modification_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:story_view/story_view.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({Key? key}) : super(key: key);

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  final _navigationController = Get.put(NavigationController());
  var controller = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    storyItems = _homeController.stories.value![_homeController.indexStory.value]!.map((e) =>
    e!.type == 0 ?
        StoryItem.pageImage(url: e.url, controller: controller, imageFit: BoxFit.cover, duration: const Duration(seconds: 5)) :
        StoryItem.pageVideo(e.url, controller: controller, imageFit: BoxFit.cover)
    ).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StoryView(
            onComplete: (){
              if(_homeController.stories.value!.length - 1 > _homeController.actualStoryIndex.value) {
                _homeController.indexStory.value++;
                Navigator.of(context).pop(true);
                pushNewScreen(context, screen: const StoryViewerScreen());
              } else {
                _navigationController.hideNavBar.value = false;
                Navigator.pop(context);
              }
              },
            onVerticalSwipeComplete: (direction){
              if(direction == Direction.down) {
                _navigationController.hideNavBar.value = false;
                Navigator.pop(context);
              }
            },
            onStoryShow: (story) async{
              _homeController.actualStoryIndex.value = _homeController.stories.value?.indexOf(_homeController.stories.value![_homeController.indexStory.value]!) ?? 0;
              var storyToUpdate = _homeController.stories.value?[_homeController.indexStory.value]![storyItems.indexOf(story)]?.id;
              await _homeController.updateStory(StoryModificationDto(id: storyToUpdate!, readers: [_homeController.id.value]));
              },
            storyItems: storyItems,
            controller: controller,
          ),
          Container(
            padding: const EdgeInsets.only(
              top: 48,
              left: 16,
              right: 16,
            ),
            child: _buildProfileView(_homeController.stories.value![_homeController.indexStory.value]!.first!),
          )
        ],
      ),
    );
  }

  Widget _buildProfileView(StoryDto story) {

    var nowMilli = DateTime.now().millisecondsSinceEpoch;
    var updatedAtMilli =  DateTime.parse(story.createdAt.toIso8601String()).millisecondsSinceEpoch;
    var diffMilli = nowMilli - updatedAtMilli;
    var timeSince = DateTime.now().subtract(Duration(milliseconds: diffMilli));

    return InkWell(
      onTap: (){
        _commonController.userClicked.value = story.createdBy;
        _navigationController.hideNavBar.value = false;
        pushNewScreen(context, screen: const ProfileElseScreen(fromConversation: false)).then((value) => _navigationController.hideNavBar.value = true);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            story.createdBy.picture.isNullOrBlank! ?
            Wrap(
              children: [
                TinyAvatar(baseString: _homeController.userMe.value.wallet!, dimension: 46, circular: true, colourScheme: TinyAvatarColourScheme.seascape),
              ],
            ) :
            CircleAvatar(
              radius: 24,
              backgroundImage: CachedNetworkImageProvider(
                  story.createdBy.picture!
              ),
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
                  story.createdBy.nickname.isNullOrBlank! ?
    (story.createdBy.userName.isNullOrBlank! ? "${story.createdBy.wallet!.substring(0, 6)}...${story.createdBy.wallet!.substring(story.createdBy.wallet!.length - 4)}" : story.createdBy.userName!) :"${story.createdBy.nickname!} (${story.createdBy.userName.isNullOrBlank! ? "${story.createdBy.wallet!.substring(0, 10)}..." : story.createdBy.userName!})",
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
