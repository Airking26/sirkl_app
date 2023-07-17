// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sirkl/global_getx/calls/calls_controller.dart';

import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/global_getx/common/common_controller.dart';
import 'package:sirkl/global_getx/profile/profile_controller.dart';
import 'package:sirkl/global_getx/navigation/navigation_controller.dart';
import 'package:sirkl/views/profile/profile_else_screen.dart';

import 'package:story_view/story_view.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

import '../../global_getx/home/home_controller.dart';
import '../chats/detailed_chat_screen.dart';

class MyStoryViewerScreen extends StatefulWidget {
  const MyStoryViewerScreen({Key? key}) : super(key: key);

  @override
  State<MyStoryViewerScreen> createState() => _MyStoryViewerScreenState();
}

class _MyStoryViewerScreenState extends State<MyStoryViewerScreen> {

  NavigationController get _navigationController => Get.find<NavigationController>();
  ProfileController get _profileController => Get.find<ProfileController>();  
  HomeController get _homeController => Get.find<HomeController>();
  CallsController get _callController => Get.find<CallsController>();

  var controller = StoryController();
  List<StoryItem> storyItems = [];
  var currentIndex = -1;
  CommonController get _commonController => Get.find<CommonController>();

  @override
  void initState() {
      storyItems = _profileController.myStories.value!.map((e) => e.type == 0 ?
      StoryItem.pageImage(url: e.url,
          controller: controller,
          imageFit: BoxFit.fitWidth,
          duration: const Duration(seconds: 5)) :
      StoryItem.pageVideo(
          e.url, controller: controller, imageFit: BoxFit.fitWidth)).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StoryView(
            onComplete: (){
                _navigationController.hideNavBar.value = false;
                Navigator.pop(context);
              },
            onVerticalSwipeComplete: (direction) async{
              if(direction == Direction.down) {
                _navigationController.hideNavBar.value = false;
                Navigator.pop(context);
              } else if(direction == Direction.up){
                controller.pause();
                await _profileController.retrieveUsersForAStory(_profileController.myStories.value![currentIndex].id);
                showModalBottomSheet(context: context, builder: (context){
                  return _profileController.readers.value == null || _profileController.readers.value?.length == 0 ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
                    child: Text("No one has seen your story yet", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, fontFamily: 'Gilroy', color: Colors.black),),
                  ) : buildListViewReaders();
                }).then((value) {
                  _profileController.readers.value = [];
                  controller.play();});
              }
            },
            onStoryShow: (story) async{
              currentIndex++;
              },
            storyItems: storyItems,
            controller: controller,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Align(alignment: Alignment.bottomCenter, child:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  padding: const EdgeInsets.all(15),
                  elevation: 0,
                  color: Colors.white24,
                  highlightElevation: 0,
                  minWidth: double.minPositive,
                  height: double.minPositive,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  onPressed: () async{
                    controller.pause();
                    await _profileController.retrieveUsersForAStory(_profileController.myStories.value![currentIndex].id);
                    showModalBottomSheet(context: context, builder: (context){
                      return _profileController.readers.value == null || _profileController.readers.value?.length == 0 ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
                        child: Text("No one has seen your story yet", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, fontFamily: 'Gilroy', color: Colors.black),),
                      ) : buildListViewReaders();
                    }).then((value) {
                      _profileController.readers.value = [];
                      controller.play();});
                  },
                  child: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.white ,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 24,),
                MaterialButton(
                  padding: const EdgeInsets.all(15),
                  elevation: 0,
                  color: Colors.white24,
                  highlightElevation: 0,
                  minWidth: double.minPositive,
                  height: double.minPositive,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  onPressed: () async{
                    controller.pause();

                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => CupertinoAlertDialog(
                          title: Text(
                            "Delete Story",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Gilroy",
                                color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          content: Text("Are you sure?",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Gilroy",
                                  color: MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.5))),
                          actions: [
                            CupertinoDialogAction(
                              child: Text("No",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Gilroy",
                                      color:
                                      MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                          ? Colors.white
                                          : Colors.black)),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text("Yes",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Gilroy",
                                      color:
                                      MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                          ? Colors.white
                                          : Colors.black)),
                              onPressed: () async {
                                await _homeController.deleteStory(_profileController.myStories.value![currentIndex].createdBy.id!, _profileController.myStories.value![currentIndex].id);
                                _profileController.myStories.value?.removeWhere((element) => element.id == _profileController.myStories.value![currentIndex].id);
                                _profileController.myStories.refresh();
                                Fluttertoast.showToast(
                                    msg: "The story has been deleted",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                                controller.play();
                                Get.back();
                              },
                            )
                          ],
                        ));
                  },
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.white ,
                    size: 25,
                  ),
                ),
              ],
            ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildListViewReaders() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
                  separatorBuilder: (BuildContext context, int index) { return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Divider(),
                  ); },
                  itemCount: _profileController.readers.value?.length ?? 0,
                  itemBuilder: (context, index){
                    return ListTile(
                      leading: InkWell(
                        onTap: () {
                          _commonController.userClicked.value =
                          _profileController.readers.value?[index];
                          pushNewScreen(context,
                              screen: const ProfileElseScreen(fromConversation: false), withNavBar: true).then((value) => _navigationController.hideNavBar.value = true);
                        },
                        child: _profileController.readers.value?[index].picture == null
                            ? SizedBox(
                            width: 56,
                            height: 56,
                            child: TinyAvatar(
                              baseString: _profileController.readers.value![index].wallet!,
                              dimension: 56,
                              circular: true,
                              colourScheme: TinyAvatarColourScheme.seascape,
                            ))
                            : ClipRRect(
                            borderRadius: BorderRadius.circular(90.0),
                            child: CachedNetworkImage(
                                imageUrl: _profileController.readers.value![index].picture!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                        color: Color(0xff00CB7D))),
                                errorWidget: (context, url, error) => Image.asset(
                                    "assets/images/app_icon_rounded.png"))),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    _callController.userCalled.value =
                                    _profileController.readers.value![index];
                                    await _callController.inviteCall(
                                        _profileController.readers.value![index],
                                        DateTime.now().toString(),
                                        _homeController.id.value);
                                  },
                                  child: Image.asset(
                                    "assets/images/call_tab.png",
                                    color: const Color(0xFF00CB7D),
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                    onTap: () {
                                      _commonController.userClicked.value =
                                      _profileController.readers.value?[index];
                                      pushNewScreen(context,
                                          screen:
                                          const DetailedChatScreen(create: true));
                                    },
                                    child: Image.asset(
                                      "assets/images/chat_tab.png",
                                      width: 20,
                                      height: 20,
                                      color: const Color(0xFF9BA0A5),
                                    )),
                                const SizedBox(
                                  width: 8,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      title: InkWell(
                          onTap: () {
                            _commonController.userClicked.value =
                            _profileController.readers.value?[index];
                            pushNewScreen(context,
                                screen:
                                const ProfileElseScreen(fromConversation: false), withNavBar: true).then((value) => _navigationController.hideNavBar.value = true);
                          },
                          child: Transform.translate(
                              offset: const Offset(-8, 0),
                              child: Text(
                                  _profileController.readers.value![index].nickname.isNullOrBlank! ?
                                  (_profileController.readers.value![index].userName.isNullOrBlank!
                                      ? "${_profileController.readers.value![index].wallet!.substring(0, 6)}...${_profileController.readers.value![index].wallet!.substring(_profileController.readers.value![index].wallet!.length)}"
                                      : _profileController.readers.value![index].userName!) :
                                  _profileController.readers.value![index].nickname!  + (_profileController.readers.value![index].userName.isNullOrBlank! ? "" : " (${_profileController.readers.value![index].userName!})"),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Gilroy",
                                      fontWeight: FontWeight.w600,
                                      color:MediaQuery.of(context).platformBrightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black)))),
                      subtitle: !_profileController.readers.value![index].userName.isNullOrBlank! || !_profileController.readers.value![index].nickname.isNullOrBlank!
                          ? InkWell(
                          onTap: () {
                            _commonController.userClicked.value =
                            _profileController.readers.value![index];
                            pushNewScreen(context,
                                screen: const ProfileElseScreen(
                                    fromConversation: false), withNavBar: true).then((value) => _navigationController.hideNavBar.value = true);
                          },
                          child: Transform.translate(
                              offset: const Offset(-8, 0),
                              child: Text("${_profileController.readers.value![index].wallet!.substring(0, 6)}...${_profileController.readers.value![index].wallet!.substring(_profileController.readers.value![index].wallet!.length - 4)}",
                                  //maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: "Gilroy",
                                      fontWeight: FontWeight.w500,
                                      color:MediaQuery.of(context).platformBrightness == Brightness.dark
                                          ? const Color(0xFF9BA0A5)
                                          : const Color(0xFF828282)))))
                          : null,
                    );
                  },
                );
  }

}


