// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/navigation_controller.dart';
import 'package:sirkl/models/nft_dto.dart';
import 'package:sirkl/views/chats/detailed_chat_screen.dart';
import 'package:sirkl/views/global/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/views/global/stream_chat/src/stream_chat.dart';
import 'package:sirkl/views/profile/settings_profile_else_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';

import '../../config/s_colors.dart';
import '../../controllers/home_controller.dart';

class ProfileElseScreen extends StatefulWidget {
  const ProfileElseScreen(
      {Key? key, required this.fromConversation, this.fromNested = false})
      : super(key: key);
  final bool fromConversation;
  final bool fromNested;

  @override
  State<ProfileElseScreen> createState() => _ProfileElseScreenState();
}

class _ProfileElseScreenState extends State<ProfileElseScreen> {
  HomeController get _homeController => Get.find<HomeController>();
  CommonController get _commonController => Get.find<CommonController>();
  NavigationController get _navigationController =>
      Get.find<NavigationController>();
  final PagingController<int, NftDto> pagingController =
      PagingController(firstPageKey: 0);
  static var pageKey = 0;

  @override
  void initState() {
    _commonController.checkUserIsInFollowing();
    pagingController.addPageRequestListener((pageKey) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        fetchNFTs();
      });
    });

    super.initState();
  }

  Future<void> fetchNFTs() async {
    try {
      List<NftDto> newItems = await _homeController.getAssets(
          _commonController.userClicked.value!.id!,
          false,
          pageKey,
          _commonController.userClicked.value!);
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
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? const Color(0xFF102437)
                : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() => Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: AlignmentDirectional.topCenter,
                  fit: StackFit.loose,
                  children: [
                    Container(
                      height: 180,
                      margin: const EdgeInsets.only(bottom: 0.25),
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.01),
                            blurRadius: 0.01,
                          ),
                        ],
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(45)),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? const Color(0xFF113751)
                                  : Colors.white,
                              MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? const Color(0xFF1E2032)
                                  : Colors.white
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
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.keyboard_arrow_left_rounded,
                                  size: 42,
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  pushNewScreen(context,
                                          screen:
                                              const SettingsProfileElseScreen(
                                                  fromConversation: false,
                                                  fromProfile: true),
                                          withNavBar: false)
                                      .then((value) => _navigationController
                                          .hideNavBar
                                          .value = !widget.fromNested);
                                },
                                child: SizedBox(
                                  height: 75,
                                  width: 200,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      displayName(
                                          _commonController.userClicked.value!,
                                          _homeController),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 20,
                                          fontFamily: "Gilroy",
                                          fontWeight: FontWeight.w600,
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    if (!_commonController
                                        .userClickedFollowStatus.value) {
                                      if (await _commonController
                                          .addUserToSirkl(
                                              _commonController
                                                  .userClicked.value!.id!,
                                              StreamChat.of(context).client,
                                              _homeController.id.value)) {
                                        showToast(
                                            context,
                                            con.userAddedToSirklRes.trParams({
                                              "user": _commonController
                                                      .userClicked
                                                      .value!
                                                      .userName
                                                      .isNullOrBlank!
                                                  ? "${_commonController.userClicked.value!.wallet!.substring(0, 6)}...${_commonController.userClicked.value!.wallet!.substring(_commonController.userClicked.value!.wallet!.length - 4)}"
                                                  : _commonController
                                                      .userClicked
                                                      .value!
                                                      .userName!
                                            }));
                                      }
                                    } else {
                                      widget.fromConversation
                                          ? Navigator.of(context).pop()
                                          : pushNewScreen(context,
                                                  screen:
                                                      const DetailedChatScreen(
                                                          create: true,
                                                          fromProfile: true),
                                                  withNavBar: false)
                                              .then((value) =>
                                                  _navigationController
                                                          .hideNavBar.value =
                                                      !widget.fromNested);
                                    }
                                  },
                                  icon: Image.asset(
                                    _commonController
                                            .userClickedFollowStatus.value
                                        ? "assets/images/chat_tab.png"
                                        : "assets/images/add_user.png",
                                    color: _commonController
                                            .userClickedFollowStatus.value
                                        ? MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black
                                        : SColors.activeColor,
                                    height: 26,
                                    width: 26,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: Platform.isAndroid ? 105 : 95,
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? const Color(0xFF122034)
                                      : Colors.white,
                                  width: 5),
                              borderRadius: BorderRadius.circular(90)),
                          child: ClipOval(
                            child: SizedBox.fromSize(
                              size: const Size.fromRadius(70),
                              child: GestureDetector(
                                  onTap: () {},
                                  child: _commonController
                                              .userClicked.value!.picture ==
                                          null
                                      ? TinyAvatar(
                                          baseString:
                                              _commonController.userClicked.value!
                                                  .wallet!,
                                          dimension: 140,
                                          circular: true,
                                          colourScheme:
                                              TinyAvatarColourScheme.seascape)
                                      : CachedNetworkImage(
                                          imageUrl: _commonController
                                              .userClicked.value!.picture!,
                                          color: Colors.white.withOpacity(0.0),
                                          fit: BoxFit.cover,
                                          colorBlendMode: BlendMode.difference,
                                          placeholder: (context, url) => Center(
                                              child: CircularProgressIndicator(
                                                  color: SColors.activeColor)),
                                          errorWidget: (context, url, error) =>
                                              Image.asset("assets/images/app_icon_rounded.png"))),
                            ),
                          )),
                    ),
                    Container()
                  ],
                ),
                const SizedBox(
                  height: 90,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(
                          text: _commonController.userClicked.value!.wallet!));
                      // ignore: use_build_context_synchronously
                      showToast(context, con.walletCopiedRes.tr);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${_commonController.userClicked.value!.wallet!.substring(0, 6)}...${_commonController.userClicked.value!.wallet!.substring(_commonController.userClicked.value!.wallet!.length - 4)}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: "Gilroy",
                              fontWeight: FontWeight.w500,
                              color: SColors.activeColor,
                              fontSize: 16),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Image.asset(
                          "assets/images/copy.png",
                          height: 18,
                          width: 18,
                          color: SColors.activeColor,
                        )
                      ],
                    ),
                  ),
                ),
                _commonController.userClicked.value!.description.isNullOrBlank!
                    ? const SizedBox(
                        height: 0,
                      )
                    : const SizedBox(
                        height: 10,
                      ),
                _commonController.userClicked.value!.description.isNullOrBlank!
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: Text(
                          _commonController.userClicked.value!.description!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              height: 1.5,
                              fontFamily: "Gilroy",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF828282),
                              fontSize: 15),
                        ),
                      ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Divider(
                    color: Color(0xFF828282),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          con.nFTCollectionRes.tr,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Gilroy",
                              fontWeight: FontWeight.w600,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black),
                        ))),
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SafeArea(
                        child: PagedListView(
                          pagingController: pagingController,
                          builderDelegate: PagedChildBuilderDelegate<NftDto>(
                              firstPageProgressIndicatorBuilder: (context) =>
                                  Center(
                                    child: CircularProgressIndicator(
                                      color: SColors.activeColor,
                                    ),
                                  ),
                              newPageProgressIndicatorBuilder: (context) =>
                                  Center(
                                    child: CircularProgressIndicator(
                                      color: SColors.activeColor,
                                    ),
                                  ),
                              itemBuilder: (context, item, index) =>
                                  CardNFT(item, _commonController, index)),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )));
  }

  @override
  void dispose() {
    pageKey = 0;
    super.dispose();
  }
}

class CardNFT extends StatefulWidget {
  final NftDto nftDto;
  final CommonController commonController;
  final int index;
  const CardNFT(this.nftDto, this.commonController, this.index, {Key? key})
      : super(key: key);

  @override
  State<CardNFT> createState() => _CardNFTState();
}

class _CardNFTState extends State<CardNFT> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? const Color(0xFF1A2E40)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 0.01), //(x,y)
              blurRadius: 0.01,
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
          ),
          child: ExpansionTile(
            showTrailingIcon: widget.nftDto.isNft ?? true,
            enabled: widget.nftDto.isNft ?? true,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(90),
              child: CachedNetworkImage(
                  imageUrl: widget.nftDto.collectionImage!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                          color: SColors.activeColor)),
                  errorWidget: (context, url, error) =>
                      Image.asset("assets/images/app_icon_rounded.png")),
            ),
            title: Text(widget.nftDto.title!,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600,
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black)),
            subtitle: Row(
              children: [
                Image.asset(
                  widget.nftDto.chain == "Polygon"
                      ? "assets/images/polygon.png"
                      : "assets/images/ethereum-logo.png",
                  width: 12,
                  height: 12,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                    widget.nftDto.isNft ?? true
                        ? "${widget.nftDto.images!.length} available"
                        : widget.nftDto.subtitle == null
                            ? ""
                            : "Currency : ${widget.nftDto.subtitle?.toUpperCase()}",
                    style: const TextStyle(
                        fontSize: 12,
                        fontFamily: "Gilroy",
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF828282))),
              ],
            ),
            onExpansionChanged: (expanded) {
              if (expanded) {
                widget.commonController.isCardExpandedList.assign(widget.index);
              } else {
                widget.commonController.isCardExpandedList.remove(widget.index);
              }
              widget.commonController.isCardExpandedList.refresh();
            },
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 18.0, left: 80, right: 20),
                child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                      itemCount: widget.nftDto.images!.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox.fromSize(
                                  child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: widget.nftDto.images![i],
                                      width: 80,
                                      height: 70,
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                              color: SColors.activeColor)),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              "assets/images/app_icon_rounded.png")))),
                        );
                      },
                      scrollDirection: Axis.horizontal,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
