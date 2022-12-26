import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story/story_page_view/story_page_view.dart';
import '../controller/home_controller.dart';

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({Key? key}) : super(key: key);

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {

  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;
  final _homeController = Get.put(HomeController());

  @override
  void initState() {
    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
        IndicatorAnimationCommand.resume);
    super.initState();
  }

  @override
  void dispose() {
    indicatorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoryPageView(
        itemBuilder: (context, pageIndex, storyIndex) {
          final user = _homeController.stories.value?[pageIndex]?[storyIndex]?.createdBy;
          final story = _homeController.stories.value?[pageIndex]?[storyIndex];
          return Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.black),
              ),
              Positioned.fill(
                child: Image.network(
                  story?.url ?? "",
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 44, left: 8),
                child: Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(user?.picture ?? ""),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      user?.userName ?? "",
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        gestureItemBuilder: (context, pageIndex, storyIndex) {
          return Stack(children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
            ),
          ]);
        },
        indicatorAnimationController: indicatorAnimationController,
        initialStoryIndex: (pageIndex) {
          return 0;
        },
        pageLength: _homeController.stories.value?.length ?? 0,
        storyLength: (int pageIndex) {
          return _homeController.stories.value?[pageIndex]?.length ?? 0;
        },
        onPageChanged: (index){
          var g = index;
        },
        onPageLimitReached: () {
          Get.back();
        },
      ),
    );
  }
}
