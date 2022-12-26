import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:story_view/story_view.dart';

class StoryViewerSecondScreen extends StatefulWidget {
  const StoryViewerSecondScreen({Key? key}) : super(key: key);

  @override
  State<StoryViewerSecondScreen> createState() => _StoryViewerSecondScreenState();
}

class _StoryViewerSecondScreenState extends State<StoryViewerSecondScreen> {
  final _homeController = Get.put(HomeController());
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
                Get.to(() => const StoryViewerSecondScreen());
              } else {
                Get.back();
              }
              },
            onVerticalSwipeComplete: (direction){
              if(direction == Direction.down) Get.back();
            },
            onStoryShow: (story){
              _homeController.actualStoryIndex.value = _homeController.stories.value?.indexOf(_homeController.stories.value![_homeController.indexStory.value]!) ?? 0;
              var storyToUpdate = _homeController.stories.value?[_homeController.indexStory.value]![storyItems.indexOf(story)];
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
            child: _buildProfileView(),
          )
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
              "https://avatars2.githubusercontent.com/u/5024388?s=460&u=d260850b9267cf89188499695f8bcf71e743f8a7&v=4"),
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Text(
                "Not Grッ",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                "Hello",
                style: TextStyle(
                  color: Colors.white38,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
