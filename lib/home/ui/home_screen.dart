import 'dart:io';

import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/model/story_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/home/ui/story_viewer_second_screen.dart';
import 'package:slider_button/slider_button.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

import '../../common/utils.dart';
import '../../common/view/dialog/custom_dial.dart';
import '../../profile/ui/profile_else_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  YYDialog dialogMenu = YYDialog();
  final utils = Utils();
  final PagingController<int, List<StoryDto>> pagingController = PagingController(firstPageKey: 0);
  static var pageKey = 0;
  final storyController = StoryController();


  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {fetchPageStories();});
    super.initState();
  }

  Future<void> fetchPageStories() async {
    try {
      List<List<StoryDto>> newItems = await _homeController.retrieveStories(pageKey);
      final isLastPage = newItems.length < 12;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey++;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() =>
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildAppbar(context),
                _homeController.accessToken.value.isNotEmpty
                    ? _commonController.gettingStoryAndContacts.value
                    ? Container()
                //TODO: Check story
                    : !_commonController.users.isNotEmpty
                    ? buildListOfStories()
                    : Container()
                    : _homeController.address.value.isEmpty
                    ? buildConnectWalletUI()
                    : buildSignWalletUI(),
                _homeController.accessToken.value.isNotEmpty ? _commonController.gettingStoryAndContacts.value ? Container(
                    margin: const EdgeInsets.only(top: 150),
                    child: const CircularProgressIndicator(color: Color(0xff00CB7D)))
                    : _commonController.users.isNotEmpty
                    ? buildRepertoireList(context)
                    : buildEmptyFriends()
                    : Container(),
              ],
            )
        ));
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
            colors: [
              Get.isDarkMode ? const Color(0xFF113751) : Colors.white,
              Get.isDarkMode ? const Color(0xFF1E2032) : Colors.white
            ]),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 44.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    "assets/images/arrow_left.png",
                    color: Get.isDarkMode
                        ? Colors.transparent
                        : Colors.transparent,
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 20,
                ),
              ),
              IconButton(
                  onPressed: () {
                    dialogMenu = dialogPopMenu(context);
                  },
                  icon: Image.asset(
                    "assets/images/more.png",
                    color: _homeController.accessToken.value.isEmpty
                        ? Colors.transparent
                        : Get.isDarkMode
                        ? Colors.transparent
                        : Colors.transparent,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  YYDialog dialogPopMenu(BuildContext context) {
    return YYDialog().build(context)
      ..width = 120
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor =
      Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05)
      ..backgroundColor = Get.isDarkMode
          ? const Color(0xFF1E3244).withOpacity(0.95)
          : Colors.white
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                con.contactUsRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                con.rulesRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..show();
  }

  Widget buildListOfStories(){
    return Container(
      padding: const EdgeInsets.only(right: 4, left: 4, top: 12),
      height: 122,
      child: PagedListView(
        scrollDirection: Axis.horizontal,
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<List<StoryDto>>(itemBuilder: (context, item, index) => buildStory(item, index)),
      ),
    );
  }

  Widget buildStory(List<StoryDto> listOfStories, int index){
    var hasUnread = false;
    listOfStories.forEach((element) {
      if(!element.readers.contains(_homeController.id.value)) hasUnread = true;
    });
    return Column(
      children: [
        InkWell(
          onTap: () {
            _homeController.indexStory.value = index;
            Get.to(() => const StoryViewerSecondScreen());
            },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff00CB7D),
                  width: hasUnread ? 2.0 : 0.0,
                ),
              ),
              child: listOfStories.first.createdBy.picture.isNullOrBlank! ?
              TinyAvatar(baseString: _homeController.userMe.value.wallet!, dimension: 70, circular: true, colourScheme: TinyAvatarColourScheme.seascape) :
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(listOfStories.first.createdBy.picture ?? ""),
              )
          ),
        ),
        SizedBox(height: 4,),
        Text(
          _homeController.stories.value![index]!.first!.createdBy.userName.isNullOrBlank! ?
          "${_homeController.stories.value![index]!.first!.createdBy.wallet.substring(0, 5)}...":
          _homeController.stories.value![index]!.first!.createdBy.userName.length > 6 ?
          "${_homeController.stories.value![index]!.first!.createdBy.userName.substring(0, 7)}..." :
          _homeController.stories.value![index]!.first!.createdBy.userName,
          style: TextStyle(
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Get.isDarkMode ? Colors.white : Colors.black),
        )
      ],
    );
  }


Widget buildRepertoireList(BuildContext context) {
  SuspensionUtil.sortListBySuspensionTag(_commonController.users);
  SuspensionUtil.setShowSuspensionStatus(_commonController.users);
  return MediaQuery.removePadding(
    context: context,
    removeTop: true,
    child: Flexible(
        fit: FlexFit.loose,
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: SafeArea(
            child: AzListView(
              indexBarWidth: _commonController.users.length > 20 ? 30 : 0,
              indexBarMargin: const EdgeInsets.only(right: 8, top: 12, bottom: 12),
              indexHintBuilder: (context, hint) {return Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xff00CB7D)),
                alignment: Alignment.center,
                child: Text(hint,
                    style: const TextStyle(
                        fontFamily: "Gilroy",
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 18)),
              );},
              indexBarItemHeight: MediaQuery.of(context).size.height / 50,
              indexBarOptions: IndexBarOptions(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy"),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5).withOpacity(0.8)
                        : const Color(0xFF828282).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  downDecoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5).withOpacity(0.8)
                        : const Color(0xFF828282).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  selectTextStyle: const TextStyle(
                      color: Color(0xff00CB7D),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy"),
                  selectItemDecoration: const BoxDecoration(),
                  needRebuild: true,
                  indexHintAlignment: Alignment.centerRight,
                  indexHintOffset: const Offset(0, 0)),
              padding: const EdgeInsets.only(top: 16),
              indexBarData: _commonController.users.length > 20 ? ["0", 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',] : [],
              data: _commonController.users,
              itemCount: _commonController.users.length,
              itemBuilder: buildSirklRepertoire,
            ),
          ),
        )),
  );
}

Widget buildSirklRepertoire(BuildContext context, int index) {
  return Column(
    children: [
      Offstage(
        offstage: !_commonController.users[index].isShowSuspension,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: _commonController.users.length > 20 ? 60 : 0),
          width: double.infinity,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text(
                _commonController.users[index].userName.isNullOrBlank! ?
                _commonController.users[index].wallet![0] : _commonController.users[index].userName![0].toUpperCase(),
                softWrap: false,
                style: TextStyle(
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w700,
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 20),
              ),
              Expanded(
                  child: Divider(
                    color: Get.isDarkMode
                        ? const Color(0xFF9BA0A5)
                        : const Color(0xFF828282),
                    height: 2,
                    indent: 10.0,
                  ))
            ],
          ),
        ),
      ),
      buildSirklTile(context, index, _commonController.users[index].isShowSuspension),
    ],
  );
}

Widget buildSirklTile(BuildContext context, int index, bool isShowSuspension) {
  return Padding(
    padding: EdgeInsets.only(right: _commonController.users.length > 20 ? 36.0 : 0),
    child: Column(
      children: [
        !isShowSuspension ? Divider(color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282), indent: 84, endIndent: 24, thickness: 0.2) : Container(),
        isShowSuspension ? const SizedBox(height: 8,) : Container(),
        ListTile(
          leading: InkWell(
            onTap: () {
              _commonController.userClicked.value =
              _commonController.users[index];
              Get.to(() => const ProfileElseScreen(fromConversation: false));
            },
            child: _commonController.users[index].picture == null
                ? SizedBox(
                width: 56,
                height: 56,
                child: TinyAvatar(
                  baseString: _commonController.users[index].wallet!,
                  dimension: 56,
                  circular: true,
                  colourScheme:TinyAvatarColourScheme.seascape ,
                ))
                : ClipRRect(
                borderRadius: BorderRadius.circular(90.0),
                child: CachedNetworkImage(
                    imageUrl: _commonController.users[index].picture!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,placeholder: (context, url) => Center(child: const CircularProgressIndicator(color: Color(0xff00CB7D))),
                    errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")
                )),
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
                    Image.asset(
                      "assets/images/call_tab.png",
                      color: const Color(0xFF00CB7D),
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    InkWell(
                        onTap: () {
                          _commonController.userClicked.value =
                          _commonController.users[index];
                          Get.to(() => const DetailedChatScreen(create:true));
                        },
                        child: Image.asset(
                          "assets/images/chat_tab.png",
                          width: 20,
                          height: 20,
                          color: const Color(0xFF9BA0A5),
                        )),
                    const SizedBox(
                      width: 4,
                    ),
                    Image.asset("assets/images/more.png",
                        width: 20, height: 20, color: const Color(0xFF9BA0A5))
                  ],
                ),
              )
            ],
          ),
          title:InkWell(
              onTap: () {
                _commonController.userClicked.value =
                _commonController.users[index];
                Get.to(() => const ProfileElseScreen(fromConversation: false));
              },
              child: Transform.translate(
                  offset: const Offset(-8, 0),
                  child: Text(
                      _commonController.users[index].userName.isNullOrBlank! ?
                      _commonController.users[index].wallet! : _commonController.users[index].userName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Gilroy",
                          fontWeight: FontWeight.w600,
                          color: Get.isDarkMode
                              ? Colors.white
                              : Colors.black)))),
          subtitle:  !_commonController.users[index].userName.isNullOrBlank! ? InkWell(
              onTap: () {
                _commonController.userClicked.value =
                _commonController.users[index];
                Get.to(() => const ProfileElseScreen(fromConversation:false));
              },
              child: Transform.translate(
                  offset: const Offset(-8, 0),
                  child: Text(_commonController.users[index].wallet!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13,
                          fontFamily: "Gilroy",
                          fontWeight: FontWeight.w500,
                          color: Get.isDarkMode
                              ? const Color(0xFF9BA0A5)
                              : const Color(0xFF828282))))) : null,
        ),
        !isShowSuspension ? const SizedBox(height: 8,) : const SizedBox(height: 8,),
      ],
    ),
  );
}

Column buildSignWalletUI() {
  return Column(
    children: [
      const SizedBox(
        height: 100,
      ),
      Image.asset(
        "assets/images/wallet.png",
        width: 150,
        height: 150,
      ),
      const SizedBox(
        height: 30,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          con.walletConnectedRes.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Get.isDarkMode ? Colors.white : Colors.black,
              fontSize: 25,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          con.bySigningRes.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Get.isDarkMode
                  ? const Color(0xFF9BA0A5)
                  : const Color(0xFF828282),
              fontSize: 16,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w500),
        ),
      ),
      const SizedBox(
        height: 50,
      ),
      SliderButton(
        backgroundColor: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282),
        baseColor: Get.isDarkMode ? const Color(0xFF102437)  : Colors.black,
        highlightedColor: Colors.white,
        alignLabel: Alignment(0.3, 0),
        action: () async{
          await _homeController.signMessageWithMetamask(context);
        },
        label: Text("Slide to sign", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy"),),
        icon: Center(child: Image.asset("assets/images/app_icon_rounded.png", width: 48,),),
      ),
    ],
  );
}

Column buildConnectWalletUI() {
  return Column(
    children: [
      const SizedBox(
        height: 100,
      ),
      Image.asset(
        "assets/images/wallet.png",
        width: 150,
        height: 150,
      ),
      const SizedBox(
        height: 30,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 54.0),
        child: Text(
          con.connectYourWalletRes.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Get.isDarkMode ? Colors.white : Colors.black,
              fontSize: 25,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 54.0),
        child: Text(
          con.talkWithRes.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Get.isDarkMode
                  ? const Color(0xFF9BA0A5)
                  : const Color(0xFF828282),
              fontSize: 16,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w500),
        ),
      ),
      const SizedBox(
        height: 50,
      ),
      NiceButtons(
          stretch: false,
          borderThickness: 5,
          progress: false,
          borderColor: const Color(0xff0063FB).withOpacity(0.5),
          startColor: const Color(0xff1DE99B),
          endColor: const Color(0xff0063FB),
          gradientOrientation: GradientOrientation.Horizontal,
          onTap: (finish) async {
            await _homeController.connectWallet(context);
          },
          child: Text(
            con.getStartedRes.tr,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w700),
          )),
    ],
  );
}

Column buildEmptyFriends() {
  return Column(
    children: [
      const SizedBox(
        height: 150,
      ),
      _homeController.isConfiguring.value ?
      WidgetCircularAnimator(
        innerColor: Get.isDarkMode ? Colors.white :  const Color(0xFF1E2032) ,
        outerColor: Get.isDarkMode ? Colors.white : const Color(0xFF113751),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.grey[200]),
          child: Image.asset(
            "assets/images/wallet.png",
            width: 150,
            height: 150,
          ),
        ),
      ):Image.asset(
        "assets/images/people.png",
        width: 150,
        height: 150,
      ),
      const SizedBox(
        height: 30,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 54.0),
        child: Text(
          _homeController.isConfiguring.value ? con.configurationRes.tr : con.noFriendsRes.tr ,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Get.isDarkMode ? Colors.white : Colors.black,
              fontSize: 25,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 54.0),
        child: Text(
          _homeController.isConfiguring.value ? con.configurationSentenceRes.tr : con.addUsersToSirklRes.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Get.isDarkMode
                  ? const Color(0xFF9BA0A5)
                  : const Color(0xFF828282),
              fontSize: 16,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );
}


}
