import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/story_dto.dart';
import 'package:sirkl/common/model/story_modification_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';
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
  var controller = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    storyItems = _homeController.stories.value![_homeController.indexStory.value]!.map((e) => StoryItem.pageImage(url: e!.url, controller: controller, imageFit: BoxFit.cover)).toList();
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
                Get.back();
                Get.to(() => const StoryViewerScreen());
              } else {
                Get.back();
              }
              },
            onVerticalSwipeComplete: (direction){
              if(direction == Direction.down) Get.back();
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
        Get.to(() => const ProfileElseScreen(fromConversation: false));
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
                  story.createdBy.userName.isNullOrBlank! ? "${story.createdBy.wallet!.substring(0, 10)}..." : story.createdBy.userName!,
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