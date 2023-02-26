// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:launch_review/launch_review.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/model/story_dto.dart';
import 'package:sirkl/common/model/wallet_connect_dto.dart';
import 'package:sirkl/common/model/web_wallet_connect_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/home/ui/pdf_screen.dart';
import 'package:sirkl/home/ui/story_viewer_screen.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:slider_button/slider_button.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

import '../../common/utils.dart';
import '../../profile/ui/profile_else_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  final _callController = Get.put(CallsController());
  final _navigationController = Get.put(NavigationController());
  final utils = Utils();
  final storyController = StoryController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var result;
  QRViewController? controller;

  @override
  void initState() {
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if(_homeController.accessToken.value.isEmpty) await _displayDialog(context);
    });*/
    _homeController.pagingController.value.addPageRequestListener((pageKey) {
      _homeController.pagingController.value.itemList = [];
      fetchPageStories();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildAppbar(context),
                _homeController.accessToken.value.isNotEmpty
                    ? _commonController.gettingStoryAndContacts.value
                        ? Container()
                        : _commonController.users.isNotEmpty
                            ? buildListOfStories()
                            : Container()
                    : _homeController.address.value.isEmpty
                        ? _homeController.qrActive.value ? buildQRCodeWidget() : buildConnectWalletUI()
                        : buildSignWalletUI(),
                _homeController.accessToken.value.isNotEmpty
                    ? _commonController.gettingStoryAndContacts.value &&
                            _homeController.loadingStories.value
                        ? Container(
                            margin: const EdgeInsets.only(top: 150),
                            child: const CircularProgressIndicator(
                                color: Color(0xff00CB7D)))
                        : _commonController.users.isNotEmpty
                            ? buildRepertoireList(context)
                            : buildEmptyFriends()
                    : Container(),
              ],
            )));
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(_homeController.qrActive.value ? 0 : 35)),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E2032) : Colors.white
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
                  onPressed: () {
                    if(_homeController.qrActive.value) {
                      _homeController.qrActive.value = false;
                      _navigationController.hideNavBar.value = false;
                    }
                  },
                  icon: Image.asset(
                    "assets/images/arrow_left.png",
                    color: _homeController.qrActive.value ? MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.white
                        : Colors.black : Colors.transparent,
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
                  },
                  icon: Image.asset(
                    "assets/images/more.png",
                    color: _homeController.accessToken.value.isEmpty
                        ? Colors.transparent
                        : MediaQuery.of(context).platformBrightness == Brightness.dark
                            ? Colors.transparent
                            : Colors.transparent,
                  )),
            ],
          ),
        ),
      ),
    );
  }



  Widget buildListOfStories() {
    return Container(
      padding: const EdgeInsets.only(right: 8, left: 8, top: 24),
      height: (_homeController.stories.value == null ||
                  _homeController.stories.value!.isEmpty) &&
              !_homeController.loadingStories.value
          ? 0
          : 125,
      child: PagedListView(
        scrollDirection: Axis.horizontal,
        pagingController: _homeController.pagingController.value,
        builderDelegate: PagedChildBuilderDelegate<List<StoryDto?>?>(
            itemBuilder: (context, item, index) => buildStory(item, index),
            firstPageProgressIndicatorBuilder: (context) => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff00CB7D),
                  ),
                ),
            noItemsFoundIndicatorBuilder: (context) => Container()),
      ),
    );
  }

  Widget buildStory(List<StoryDto?>? listOfStories, int index) {
    var hasUnread = false;
    for (var element in listOfStories!) {
      if (!element!.readers.contains(_homeController.id.value)) {
        hasUnread = true;
      }
    }
    return Column(
      children: [
        InkWell(
          onTap: () {
            _navigationController.hideNavBar.value = true;
            _homeController.indexStory.value = index;
            pushNewScreen(context, screen: const StoryViewerScreen()).then(
                (value) {
                  if(value == null){
                    _navigationController.hideNavBar.value = false;
                  }
                  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                  _homeController.pagingController.value.notifyListeners();
                });
          },
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff00CB7D),
                  width: hasUnread ? 3.0 : 0.0,
                ),
              ),
              child: listOfStories.first!.createdBy.picture.isNullOrBlank!
                  ? TinyAvatar(
                      baseString: _homeController.userMe.value.wallet!,
                      dimension: 70,
                      circular: true,
                      colourScheme: TinyAvatarColourScheme.seascape)
                  : CircleAvatar(
                      backgroundColor: const Color(0xff00CB7D),
                      radius: 36,
                      backgroundImage: CachedNetworkImageProvider(
                          listOfStories.first!.createdBy.picture!),
                    )),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          _homeController.stories.value![index]!.first!.createdBy.nickname.isNullOrBlank! ?
              (_homeController.stories.value![index]!.first!.createdBy.userName.isNullOrBlank!
                  ? "${_homeController.stories.value![index]!.first!.createdBy.wallet!.substring(0, 5)}..."
                  : _homeController.stories.value![index]!.first!.createdBy.userName!.length > 6
                      ? "${_homeController.stories.value![index]!.first!.createdBy.userName!.substring(0, 7)}..."
                      : _homeController.stories.value![index]!.first!.createdBy.userName!) :
          "${_homeController.stories.value![index]!.first!.createdBy.nickname!} (${_homeController.stories.value![index]!.first!.createdBy.userName.isNullOrBlank!
              ? "${_homeController.stories.value![index]!.first!.createdBy.wallet!.substring(0, 3)}..."
              : _homeController.stories.value![index]!.first!.createdBy.userName!.length > 3
              ? "${_homeController.stories.value![index]!.first!.createdBy.userName!.substring(0, 4)}..."
              : _homeController.stories.value![index]!.first!.createdBy.userName!})",
          style: TextStyle(
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: MediaQuery.of(context).platformBrightness == Brightness.dark? Colors.white : Colors.black),
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
                indexBarMargin:
                    const EdgeInsets.only(right: 8, top: 12, bottom: 12),
                indexHintBuilder: (context, hint) {
                  return Container(
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
                  );
                },
                indexBarItemHeight: MediaQuery.of(context).size.height / 50,
                indexBarOptions: IndexBarOptions(
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Gilroy"),
                    decoration: BoxDecoration(
                      color: MediaQuery.of(context).platformBrightness == Brightness.dark
                          ? const Color(0xff9BA0A5).withOpacity(0.8)
                          : const Color(0xFF828282).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    downDecoration: BoxDecoration(
                      color: MediaQuery.of(context).platformBrightness == Brightness.dark
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
                indexBarData: _commonController.users.length > 20
                    ? [
                        "0",
                        'A',
                        'B',
                        'C',
                        'D',
                        'E',
                        'F',
                        'G',
                        'H',
                        'I',
                        'J',
                        'K',
                        'L',
                        'M',
                        'N',
                        'O',
                        'P',
                        'Q',
                        'R',
                        'S',
                        'T',
                        'U',
                        'V',
                        'W',
                        'X',
                        'Y',
                        'Z',
                      ]
                    : [],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        index == 0
            ? Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 12),
                child: Text(
                  "MY SIRKL",
                  style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w700,
                      fontSize: 18),
                ),
              )
            : Container(),
        Offstage(
          offstage: !_commonController.users[index].isShowSuspension,
          child: Container(
            padding: EdgeInsets.only(
                left: 20, right: _commonController.users.length > 20 ? 60 : 0),
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  _commonController.users[index].nickname.isNullOrBlank! ?
                      (_commonController.users[index].userName.isNullOrBlank!
                          ? _commonController.users[index].wallet![0]
                          : _commonController.users[index].userName![0]
                              .toUpperCase()) : _commonController.users[index].nickname![0].toUpperCase(),
                  softWrap: false,
                  style: TextStyle(
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w700,
                      color: MediaQuery.of(context).platformBrightness == Brightness.dark? Colors.white : Colors.black,
                      fontSize: 20),
                ),
                Expanded(
                    child: Divider(
                  color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? const Color(0xFF9BA0A5)
                      : const Color(0xFF828282),
                  height: 2,
                  indent: 10.0,
                ))
              ],
            ),
          ),
        ),
        buildSirklTile(
            context, index, _commonController.users[index].isShowSuspension),
      ],
    );
  }

  Widget buildSirklTile(BuildContext context, int index, bool isShowSuspension) {
    return Padding(
      padding: EdgeInsets.only(
          right: _commonController.users.length > 20 ? 36.0 : 0),
      child: Column(
        children: [
          !isShowSuspension
              ? Divider(
                  color: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? const Color(0xFF9BA0A5)
                      : const Color(0xFF828282),
                  indent: 84,
                  endIndent: 24,
                  thickness: 0.2)
              : Container(),
          isShowSuspension
              ? const SizedBox(
                  height: 8,
                )
              : Container(),
          ListTile(
            leading: InkWell(
              onTap: () {
                _commonController.userClicked.value =
                    _commonController.users[index];
                pushNewScreen(context,
                    screen: const ProfileElseScreen(fromConversation: false));
              },
              child: _commonController.users[index].picture == null
                  ? SizedBox(
                      width: 56,
                      height: 56,
                      child: TinyAvatar(
                        baseString: _commonController.users[index].wallet!,
                        dimension: 56,
                        circular: true,
                        colourScheme: TinyAvatarColourScheme.seascape,
                      ))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(90.0),
                      child: CachedNetworkImage(
                          imageUrl: _commonController.users[index].picture!,
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
                              _commonController.users[index];
                          await _callController.inviteCall(
                              _commonController.users[index],
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
                                _commonController.users[index];
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
                      _commonController.users[index];
                  pushNewScreen(context,
                          screen:
                              const ProfileElseScreen(fromConversation: false))
                      .then((value) => _commonController.users.refresh());
                },
                child: Transform.translate(
                    offset: const Offset(-8, 0),
                    child: Text(
                        _commonController.users[index].nickname.isNullOrBlank! ?
                            (_commonController.users[index].userName.isNullOrBlank!
                                ? "${_commonController.users[index].wallet!.substring(0, 6)}...${_commonController.users[index].wallet!.substring(_commonController.users[index].wallet!.length)}"
                                : _commonController.users[index].userName!) :
                        _commonController.users[index].nickname!  + (_commonController.users[index].userName.isNullOrBlank! ? "" : " (${_commonController.users[index].userName!})"),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Gilroy",
                            fontWeight: FontWeight.w600,
                            color:MediaQuery.of(context).platformBrightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)))),
            subtitle: !_commonController.users[index].userName.isNullOrBlank! || !_commonController.users[index].nickname.isNullOrBlank!
                ? InkWell(
                    onTap: () {
                      _commonController.userClicked.value =
                          _commonController.users[index];
                      pushNewScreen(context,
                              screen: const ProfileElseScreen(
                                  fromConversation: false))
                          .then((value) => _commonController.users.refresh());
                    },
                    child: Transform.translate(
                        offset: const Offset(-8, 0),
                        child: Text("${_commonController.users[index].wallet!.substring(0, 6)}...${_commonController.users[index].wallet!.substring(_commonController.users[index].wallet!.length - 4)}",
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
          ),
          !isShowSuspension
              ? const SizedBox(
                  height: 8,
                )
              : const SizedBox(
                  height: 8,
                ),
        ],
      ),
    );
  }

  Map<String, HighlightedWord> words = {
    "terms and conditions": HighlightedWord(
      onTap: () {
        Get.to(() => const PDFScreen(isTermsAndConditions : 0));
      },
      textStyle: const TextStyle(
          color: Color(0xFF00CB7D),
          fontSize: 16,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
    ),
    "privacy policy": HighlightedWord(
      onTap: () {
        Get.to(() => const PDFScreen(isTermsAndConditions : 1));
      },
      textStyle: const TextStyle(
          color: Color(0xFF00CB7D),
          fontSize: 16,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
    ),
  };

  Column buildSignWalletUI() {
    return Column(
      children: [
        const SizedBox(
          height: 100,
        ),
        Image.asset(
          "assets/images/wallet.png",
          width: MediaQuery.of(context).size.height / 5,
          height: MediaQuery.of(context).size.height / 5,
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
                color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
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
          child: TextHighlight(text: con.bySigningRes.tr, words: words,
            textAlign: TextAlign.center, textStyle: TextStyle(
                color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                fontSize: 16,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        SliderButton(
          backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xff9BA0A5)
              : const Color(0xFF828282),
          baseColor: MediaQuery.of(context).platformBrightness == Brightness.dark? const Color(0xFF102437) : Colors.black,
          highlightedColor: Colors.white,
          alignLabel: const Alignment(0.3, 0),
          action: () async {
            await _homeController.signMessageWithMetamask(context);
          },
          label: const Text(
            "Slide to sign",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "Gilroy"),
          ),
          icon: Center(
            child: Image.asset(
              "assets/images/app_icon_rounded.png",
              width: 48,
            ),
          ),
        ),
      ],
    );
  }

  Column buildConnectWalletUI() {
    return Column(
      children: [
         SizedBox(
          height: MediaQuery.of(context).size.height / 12.5,
        ),
        Image.asset(
          "assets/images/wallet.png",
          width: MediaQuery.of(context).size.height / 5,
          height:  MediaQuery.of(context).size.height / 5,
        ),
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Text(
            "Let's Start",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
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
            "Connect or create your metamask wallet by clicking below",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? const Color(0xFF9BA0A5)
                    : const Color(0xFF828282),
                fontSize: 16,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(
          height: 40,
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
            child: const Text(
              "Connect",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w700),
            )),
        const SizedBox(height: 12,),

        NiceButtons(
            stretch: false,
            borderThickness: 2,
            progress: false,
            height: 55,
            borderColor: Colors.transparent,
            startColor: const Color(0xff1DE99B).withOpacity(0.5),
            endColor: const Color(0xff0063FB).withOpacity(0.5),
            gradientOrientation: GradientOrientation.Horizontal,
            onTap: (finish) async {
              _navigationController.hideNavBar.value = true;
              _homeController.qrActive.value = true;
              //pushNewScreen(context, screen: const QRCodeScreen()).then((value) => _navigationController.hideNavBar.value = false);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/qrcode.png", color: Colors.white, width: 28, height: 28,),
                const Text(
                  "Scan",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w700),
                ),
              ],
            )),
        const SizedBox(height: 18,),
        InkWell(
          onTap: ()async{
            //await _homeController.createWallet(context);
            await LaunchReview.launch(androidAppId: "io.metamask", iOSAppId: "1438144202", writeReview: false);
          },
          child: Text("OR Create a wallet", style: TextStyle(
              color: MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontSize: 13,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 24,),

        InkWell(
          onTap: (){
            showDialog(
              barrierDismissible: true,
                context: context, builder: (context){
              return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? const Color(0xFF102437)
                    : const Color.fromARGB(255, 247, 253, 255),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      const Icon(Icons.lock_outline_rounded, color: Color(0xFF00CB7D), size: 36,),
                      const SizedBox(height: 4,),
                      Text("PRIVATE AND SECURE LOGIN", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w400),)
                    ],),
                ],),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Connecting your Wallet to the app allows you to customize the way you experience SIRKL.io",
              textAlign: TextAlign.start,
              style: TextStyle(
              color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
              fontSize: 13,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w500)
                    ),
                    Text("\nOnce connected, our system will analyze the assets in your Wallet to give you access to your NFTs and cryptos",
              textAlign: TextAlign.start,
              style: TextStyle(
              color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
              fontSize: 13,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w400)
                    ),
                    Text("\nNo personal information is required, guaranteeing your anonymity",
              textAlign: TextAlign.start,
              style: TextStyle(
              color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
              fontSize: 13,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.w400)
                    ),
                    Text("\nThe authorization request requested during sign in is ONLY for READING. This does not grant SIRKL.io permission to make transactions with your Wallet",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: 13,
                            fontFamily: "Gilroy",
                            fontWeight: FontWeight.w500)
                    ),
                    Text("\nCAUTION: SIRKL.io will never ask for your private key",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: 13,
                            fontFamily: "Gilroy",
                            fontWeight: FontWeight.w400)
                    ),
                    const SizedBox(height: 12,),
                    TextButton(onPressed: (){
                      Navigator.pop(context);
                    }, child: const Text("I UNDERSTAND", style: TextStyle(color: Color(0xFF00CB7D), fontFamily: "Gilroy", fontWeight: FontWeight.w600),))
                  ],
                ),
              );
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.info_outline_rounded, size: 18, color: MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? const Color(0xFF9BA0A5)
                    : const Color(0xFF828282),),
              ),
              Text("Why connecting my wallet?", style: TextStyle(
    color: MediaQuery.of(context).platformBrightness == Brightness.dark
    ? const Color(0xFF9BA0A5)
            : const Color(0xFF828282),
    fontSize: 13,
    fontFamily: "Gilroy",
    fontWeight: FontWeight.w500))
            ],),
          ),
        )
      ],
    );
  }

  Column buildEmptyFriends() {
    return Column(
      children: [
        const SizedBox(
          height: 150,
        ),
        _homeController.isConfiguring.value
            ? WidgetCircularAnimator(
                innerColor:
                MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : const Color(0xFF1E2032),
                outerColor:
                MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : const Color(0xFF113751),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.grey[200]),
                  child: Image.asset(
                    "assets/images/wallet.png",
                    width: 150,
                    height: 150,
                  ),
                ),
              )
            : Image.asset(
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
            _homeController.isConfiguring.value
                ? con.configurationRes.tr
                : con.noFriendsRes.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: MediaQuery.of(context).platformBrightness == Brightness.dark? Colors.white : Colors.black,
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
            _homeController.isConfiguring.value
                ? con.configurationSentenceRes.tr
                : con.addUsersToSirklRes.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: MediaQuery.of(context).platformBrightness == Brightness.dark
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



  Future<void> fetchPageStories() async {
    try {
      await _homeController.retrieveStories(_homeController.pageKey.value);
      List<List<StoryDto?>?>? newItems = _homeController.pageKey.value > 0
          ? _homeController.stories.value!.sublist(
          _homeController.pageKey.value * 12,
          _homeController.stories.value!.length >=
              (_homeController.pageKey.value + 1) * 12
              ? (_homeController.pageKey.value + 1) * 12
              : _homeController.stories.value!.length)
          : _homeController.stories.value;
      final isLastPage = newItems!.length < 12;
      if (isLastPage) {
        _homeController.pagingController.value.appendLastPage(newItems);
      } else {
        final nextPageKey = _homeController.pageKey.value++;
        _homeController.pagingController.value
            .appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _homeController.pagingController.value.error = error;
    }
  }

  Widget buildQRCodeWidget(){
    return Flexible(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
           const Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text("Generate your QR code from the website 'app.sirkl.io' either from the login page or the header once you are logged in.",
                  textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, fontFamily: "Gilroy"),),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      var webWalletConnectDTO = webWalletConnectDtoFromJson(scanData.code!);
      _homeController.qrActive.value = false;
      if(DateTime.now().isBefore(DateTime.fromMillisecondsSinceEpoch(int.parse(webWalletConnectDTO.timestamp!) * 1000))) {
        await _homeController.loginWithWallet(
            context, webWalletConnectDTO.wallet!, webWalletConnectDTO.message!,
            webWalletConnectDTO.signature!);
      } else {
        Fluttertoast.showToast(
            msg: "Error, the QR Code is no longer valid",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? Colors.white : const Color(0xFF102437) ,
            textColor: SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? Colors.black : Colors.white,
            fontSize: 16.0
        );
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _homeController.loadingStories.value = true;
    _homeController.stories.value = [];
    _homeController.pagingController.value.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }


  final TextEditingController _textFieldController = TextEditingController();
  _displayDialog(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.85),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            title: const Text('Beta Version Access Code', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "Gilroy"),),
            content: TextField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: "Gilroy"),
              cursorColor: const Color(0xFF00CB7D),
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Enter Code", hintStyle: TextStyle(fontWeight: FontWeight.w500, fontFamily: "Gilroy"), focusColor: Color(0xFF00CB7D), hoverColor: Color(0xFF00CB7D), fillColor: Color(0xFF00CB7D),enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00CB7D)),
              ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00CB7D)),
                ),),
            ),
            actions: [
              TextButton(
                child: const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: Color(0xFF00CB7D)),),
                onPressed: () {
                  if(_textFieldController.text == "BETAKING2023") {
                    Navigator.of(context).pop();
                  } else {
                    Fluttertoast.showToast(
                      msg: "Wrong Access Code",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? Colors.white : const Color(0xFF102437) ,
                      textColor: SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? Colors.black : Colors.white,
                      fontSize: 16.0
                  );
                  }
                },
              )
            ],
          );
        }
    );
  }
}
