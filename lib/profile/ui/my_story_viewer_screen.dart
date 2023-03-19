import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/story_dto.dart';
import 'package:sirkl/common/model/story_modification_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:story_view/story_view.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyStoryViewerScreen extends StatefulWidget {
  const MyStoryViewerScreen({Key? key}) : super(key: key);

  @override
  State<MyStoryViewerScreen> createState() => _MyStoryViewerScreenState();
}

class _MyStoryViewerScreenState extends State<MyStoryViewerScreen> {

  final _navigationController = Get.put(NavigationController());
  final _profileController = Get.put(ProfileController());
  final _homeController = Get.put(HomeController());
  var controller = StoryController();
  List<StoryItem> storyItems = [];
  var currentIndex = -1;
  final _commonController = Get.put(CommonController());
  final _callController = Get.put(CallsController());

  @override
  void initState() {
      storyItems = _profileController.myStories.value!.map((e) => e.type == 0 ?
      StoryItem.pageImage(url: e.url,
          controller: controller,
          imageFit: BoxFit.cover,
          duration: const Duration(seconds: 5)) :
      StoryItem.pageVideo(
          e.url, controller: controller, imageFit: BoxFit.cover)).toList();
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
                  ) : ListView.builder(
                    itemCount: _profileController.readers.value?.length ?? 0,
                    itemBuilder: (context, index){
                      return ListTile(
                        leading: InkWell(
                          onTap: () {
                            _commonController.userClicked.value =
                            _profileController.readers.value?[index];
                            pushNewScreen(context,
                                screen: const ProfileElseScreen(fromConversation: false));
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
                                        _navigationController.hideNavBar.value = true;
                                        pushNewScreen(context,
                                            screen:
                                            const DetailedChatScreen(create: true))
                                            .then((value) => _navigationController
                                            .hideNavBar.value = false);
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
                                  const ProfileElseScreen(fromConversation: false));
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
                                      fromConversation: false));
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
            child: Align(alignment: Alignment.bottomCenter, child: MaterialButton(
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
                  ) : ListView.builder(
                    itemCount: _profileController.readers.value?.length ?? 0,
                    itemBuilder: (context, index){
                      return ListTile(
                        leading: InkWell(
                          onTap: () {
                            _commonController.userClicked.value =
                            _profileController.readers.value?[index];
                            pushNewScreen(context,
                                screen: const ProfileElseScreen(fromConversation: false));
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
                                        _navigationController.hideNavBar.value = true;
                                        pushNewScreen(context,
                                            screen:
                                            const DetailedChatScreen(create: true))
                                            .then((value) => _navigationController
                                            .hideNavBar.value = false);
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
                                  const ProfileElseScreen(fromConversation: false));
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
                                      fromConversation: false));
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
            ),
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
        //_commonController.userClicked.value = story.createdBy;
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


