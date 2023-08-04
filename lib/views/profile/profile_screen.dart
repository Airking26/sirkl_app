// ignore_for_file: use_build_context_synchronously, duplicate_ignore, invalid_use_of_visible_for_testing_member

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_badged/flutter_badge.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/nft_dto.dart';
import 'package:sirkl/common/model/nft_modification_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/story_insta/drishya_picker.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/common/web3/web3_controller.dart';
import 'package:sirkl/global_getx/groups/groups_controller.dart';
import 'package:sirkl/global_getx/navigation/navigation_controller.dart';
import 'package:sirkl/views/profile/settings_screen.dart';

import 'package:tiny_avatar/tiny_avatar.dart';
import '../../common/view/dialog/custom_dial.dart';
import '../../config/s_colors.dart';
import '../../global_getx/home/home_controller.dart';
import '../../global_getx/profile/profile_controller.dart';
import 'my_story_viewer_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  late final GalleryController controller;
  ProfileController get _profileController => Get.find<ProfileController>();
  HomeController get _homeController => Get.find<HomeController>();
  NavigationController get _navigationController => Get.find<NavigationController>();
  final TextEditingController usernameTextEditingController = TextEditingController();
  final TextEditingController descriptionTextEditingController = TextEditingController();

  final PagingController<int, NftDto> pagingController =
      PagingController(firstPageKey: 0);
  YYDialog dialogMenu = YYDialog();
  static var pageKey = 0;
  Utils utils = Utils();

  @override
  void initState() {
    controller = GalleryController();
    _profileController.retrieveMyStories();
    pagingController.addPageRequestListener((pageKey) {fetchNFTs();});
    usernameTextEditingController.text =
        _homeController.userMe.value.userName!.isEmpty
            ? "${_homeController.userMe.value.wallet!.substring(0, 6)}...${_homeController.userMe.value.wallet!.substring(_homeController.userMe.value.wallet!.length - 4)}"
            : _homeController.userMe.value.userName!;
    descriptionTextEditingController.text =
        _homeController.userMe.value.description.isNullOrBlank!
            ? ""
            : _homeController.userMe.value.description!;
    _profileController.urlPicture.value = _homeController.userMe.value.picture == null ? "" : _homeController.userMe.value.picture!;
    super.initState();
  }

  Future<void> fetchNFTs() async {
    try {
      List<NftDto> newItems = await _homeController.getNFT(
          _homeController.id.value,
          _homeController.isFavNftSelected.value,
          pageKey);
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
                DeferredPointerHandler(
                  child: Stack(
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
                              offset: Offset(0.0, 0.01), //(x,y)
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _profileController
                                    .isEditingProfile.value
                                    ? const SizedBox(width: 42, height: 24,) : IconButton(
                                            onPressed: () async {
                                              pushNewScreen(context, screen: const NotificationScreen()).then((value) => _profileController.checkIfHasUnreadNotif(_homeController.id.value));
                                            },
                                            icon: FlutterBadge(
                                              icon: Image.asset(
                                                "assets/images/bell.png",
                                                color: MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              itemCount: _profileController
                                                      .hasUnreadNotif.value
                                                  ? 1
                                                  : 0,
                                              hideZeroCount: true,
                                              badgeColor:
                                                  SColors.activeColor,
                                              badgeTextColor:
                                                  SColors.activeColor,
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 0.1,
                                                      right: 16,
                                                      left: 12),
                                            )),
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child:  _profileController
                                      .isEditingProfile.value
                                      ? SizedBox(
                                    width: 200,
                                    child: TextField(
                                      //autofocus: true,
                                      maxLines: 1,
                                      controller: usernameTextEditingController,
                                      maxLength: 13,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: "Gilroy",
                                          fontWeight: FontWeight.w600,
                                          color: MediaQuery.of(context)
                                              .platformBrightness ==
                                              Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isCollapsed: true,
                                          hintText: ""),
                                    ),
                                  )
                                      : Text(
                                          _homeController.userMe.value.userName!
                                                      .isEmpty ||
                                                  _homeController.userMe.value
                                                          .userName ==
                                                      _homeController
                                                          .userMe.value.wallet
                                              ? "${_homeController.userMe.value.wallet!.substring(0, 6)}...${_homeController.userMe.value.wallet!.substring(_homeController.userMe.value.wallet!.length - 4)}"
                                              : _homeController
                                                  .userMe.value.userName!,
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
                                _profileController.isLoadingPicture.value
                                    ? Container(
                                    padding: const EdgeInsets.all(8),
                                    width: 48,
                                    height: 48,
                                    child:  CircularProgressIndicator(
                                      color: SColors.activeColor,
                                    )) :
                                _profileController.isEditingProfile.value
                                    ? InkWell(
                                  onTap: () async {
                                    await _profileController.updateMe(
                                        UpdateMeDto(
                                            userName: usernameTextEditingController
                                                .text
                                                .isEmpty
                                                ? "${_homeController
                                                .userMe
                                                .value
                                                .wallet!.substring(0, 6)}...${_homeController.userMe.value.wallet!.substring(_homeController.userMe.value.wallet!.length - 4)}"
                                                : usernameTextEditingController
                                                .text,
                                            description: descriptionTextEditingController
                                                .text
                                                .isEmpty
                                                ? ""
                                                : descriptionTextEditingController
                                                .text,
                                            picture:
                                            _profileController
                                                .urlPicture
                                                .value),
                                        StreamChat.of(context)
                                            .client);
                                    usernameTextEditingController.clear();
                                    descriptionTextEditingController.clear();
                                  },
                                  child:  Padding(
                                    padding: const  EdgeInsets.only(
                                        top: 16.0, left: 16),
                                    child: Text("DONE",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Gilroy',
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.w700,
                                            color:
                                            SColors.activeColor)),
                                  ),
                                ) :IconButton(
                                    onPressed: () async {
                                      pushNewScreen(context, screen: const SettingScreen(), withNavBar: false).then((value) => _navigationController.hideNavBar.value = false);
                                    },
                                    icon: Image.asset("assets/images/more.png", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,)),
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
                                    color: _profileController.myStories.value == null || _profileController.myStories.value!.isEmpty ? MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? const Color(0xFF122034)
                                        : Colors.white :
                                    SColors.activeColor,
                                    width: 5),
                                borderRadius: BorderRadius.circular(90)),
                            child: DeferPointer(
                              child: ClipOval(
                                child: SizedBox.fromSize(
                                  size: const Size.fromRadius(70),
                                  child: GestureDetector(
                                      onTap: () async {
                                        if(_profileController.isEditingProfile.value){
                                          await _profileController.getImageForProfile();
                                        }
                                        else if(_profileController.myStories.value != null && _profileController.myStories.value!.isNotEmpty){
                                          pushNewScreen(context, screen: const MyStoryViewerScreen(), withNavBar: false).then((value) {
                                                if(value == null){
                                                  _navigationController.hideNavBar.value = false;
                                                }
                                                // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                                _homeController.pagingController.value.notifyListeners();
                                              });
                                        }
                                      },
                                      child: _profileController.urlPicture.value.isEmpty
                                          ? TinyAvatar(
                                              baseString: _profileController.urlPicture.value,
                                              dimension: 140,
                                              circular: true,
                                              colourScheme: TinyAvatarColourScheme
                                                  .seascape)
                                          : CachedNetworkImage(
                                              imageUrl: _profileController.urlPicture.value,
                                              color: Colors.white.withOpacity(_profileController
                                                  .isEditingProfile
                                                  .value
                                                  ? 0.2
                                                  : 0.0),
                                              fit: BoxFit.cover,
                                              colorBlendMode:
                                                  BlendMode.difference,
                                              placeholder: (context, url) =>
                                                   Center(
                                                      child: CircularProgressIndicator(
                                                          color: SColors.activeColor)),
                                              errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png"))),
                                ),
                              ),
                            )),
                      ),
                      _profileController.isEditingProfile.value ? const SizedBox() : Positioned(
                              top: Platform.isAndroid ? 210 : 190,
                              right: MediaQuery.of(context).size.width / 3.25,
                              child: DeferPointer(
                                paintOnTop: true,
                                child: CameraViewField(
                                  onCapture: (value) async {
                                    if (!value.first.isFavorite) {
                                      final file = await value.first.file;
                                      if (await _profileController.postStory(file!, value.first.type == AssetType.image ? 0 : 1)) {
                                        utils.showToast(context, "Story has been posted");
                                        _profileController.retrieveMyStories();
                                      }
                                    } else {
                                      if (await _profileController.postStory(value.first.pickedFile!, value.first.type == AssetType.image ? 0 : 1)) {
                                        utils.showToast(context, "Story has been posted");
                                        _profileController.retrieveMyStories();
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [
                                          Color(0xFF1DE99B),
                                          Color(0xFF0063FB)
                                        ]),
                                        borderRadius: BorderRadius.circular(90),
                                        border: Border.all(
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.dark
                                                ? const Color(0xFF122034)
                                                : Colors.white,
                                            width: 2)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Image.asset(
                                        'assets/images/plus.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(
                          text: _homeController.userMe.value.wallet!));
                      utils.showToast(context, con.walletCopiedRes.tr);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${_homeController.userMe.value.wallet!.substring(0, 6)}...${_homeController.userMe.value.wallet!.substring(_homeController.userMe.value.wallet!.length - 4)}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style:  TextStyle(
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
                _homeController.userMe.value.description.isNullOrBlank! ? const SizedBox(height: 0) : const SizedBox(height: 4,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: _profileController.isEditingProfile.value
                      ? TextField(
                          maxLines: 2,
                          controller: descriptionTextEditingController,
                          maxLength: 120,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Gilroy",
                              fontWeight: FontWeight.w500,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? const Color(0xFF9BA0A5)
                                      : const Color(0xFF828282)),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: _homeController.userMe.value.description.isNullOrBlank! ? con.noDescYetRes.tr : _homeController.userMe.value.description!),
                        )
                      : _homeController.userMe.value.description.isNullOrBlank! ? Container(): Text(
                               _homeController.userMe.value.description!,
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
                  padding: const EdgeInsets.only(left: 24.0, right: 24),
                  child: _homeController.iHaveNft.value
                      ? Row(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  con.myNFTCollectionRes.tr,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: "Gilroy",
                                      fontWeight: FontWeight.w600,
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black),
                                )),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                _homeController.isFavNftSelected.value
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _homeController.isFavNftSelected.value
                                    ? SColors.activeColor
                                    : MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black.withOpacity(0.5),
                              ),
                              onPressed: () {
                                pageKey = 0;
                                _homeController.isFavNftSelected.value =
                                    !_homeController.isFavNftSelected.value;
                                pagingController.refresh();
                              },
                            )
                          ],
                        )
                      : Container(),
                ),
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
                                   Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: SColors.activeColor,
                                      ),
                                    ),
                                  ),
                              itemBuilder: (context, item, index) =>
                                  CardNFT(item, index, pagingController)),
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
    controller.dispose();
    super.dispose();
  }
}

class CardNFT extends StatefulWidget {
  final NftDto nftDto;
  final int index;
  final PagingController pagingController;

  const CardNFT(this.nftDto, this.index, this.pagingController, {Key? key})
      : super(key: key);

  @override
  State<CardNFT> createState() => _CardNFTState();
}

class _CardNFTState extends State<CardNFT> with AutomaticKeepAliveClientMixin {

  ProfileController get _profileController => Get.find<ProfileController>();  
  HomeController get homeController => Get.find<HomeController>();
  GroupsController get _groupController => Get.find<GroupsController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Get.isDarkMode ? const Color(0xFF1A2E40) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 0.01), //(x,y)
              blurRadius: 0.01,
            ),
          ],
        ),
        child: ExpansionTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(90),
            child: CachedNetworkImage(
                imageUrl: widget.nftDto.collectionImage!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                placeholder: (context, url) =>  Center(
                    child: CircularProgressIndicator(color: SColors.activeColor)),
                errorWidget: (context, url, error) =>
                    Image.asset("assets/images/app_icon_rounded.png")),
          ),
          trailing: Obx(() => homeController.isFavNftSelected.value
              ? const SizedBox(
                  width: 0,
                  height: 0,
                )
              : IconButton(
                  icon: Icon(
                      homeController.isInFav
                              .contains(widget.nftDto.contractAddress)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color: homeController.isInFav
                              .contains(widget.nftDto.contractAddress)
                          ? SColors.activeColor
                          : MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.5)),
                  onPressed: () async {
                    bool fav;
                    if (homeController.isInFav.contains(widget.nftDto.contractAddress)) {
                      homeController.isInFav.remove(widget.nftDto.contractAddress);
                      fav = false;
                    } else {
                      homeController.isInFav.add(widget.nftDto.contractAddress!);
                      fav = true;
                    }
                    // ignore: invalid_use_of_protected_member
                    widget.pagingController.notifyListeners();
                    await _profileController.updateNft(
                        NftModificationDto(
                            contractAddress: widget.nftDto.contractAddress!,
                            id: homeController.id.value,
                            isFav: fav));
                    if(fav) {
                      await StreamChat.of(context).client.updateChannelPartial(widget.nftDto.contractAddress!, 'try', set: {"${homeController.id.value}_favorite" : true});
                    } else {
                      await StreamChat.of(context).client.updateChannelPartial(widget.nftDto.contractAddress!, 'try', unset: ["${homeController.id.value}_favorite"]);
                    }
                    _groupController.refreshGroups.value = true;
                  },
                )),
          title: Text(widget.nftDto.title!,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w600,
                  color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black)),
          subtitle: Text("${widget.nftDto.images!.length} available",
              style: const TextStyle(
                  fontSize: 12,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF828282))),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0, left: 80, right: 20),
              child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    itemCount: widget.nftDto.images!.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            if (_profileController.isEditingProfile.value) {
                              _profileController.urlPicture.value =
                                  widget.nftDto.images![i];
                            }
                          },
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox.fromSize(
                                  child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: widget.nftDto.images![i],
                                      width: 80,
                                      height: 70,
                                      placeholder: (context, url) =>
                                           Center(
                                              child: CircularProgressIndicator(
                                                  color: SColors.activeColor)),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              "assets/images/app_icon_rounded.png")))),
                        ),
                      );
                    },
                    scrollDirection: Axis.horizontal,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
