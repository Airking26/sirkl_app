import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:images_picker/images_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/models/nft_dto.dart';
import 'package:sirkl/models/nft_modification_dto.dart';
import 'package:sirkl/models/notification_dto.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/models/story_creation_dto.dart';
import 'package:sirkl/models/story_dto.dart';
import 'package:sirkl/models/update_me_dto.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/repo/home_repo.dart';
import 'package:sirkl/repo/profile_repo.dart';

import '../common/save_pref_keys.dart';
import 'home_controller.dart';

class ProfileController extends GetxController {
  final box = GetStorage();

  HomeController get _homeController => Get.find<HomeController>();

  Rx<UserDTO?> isUserExists = (null as UserDTO?).obs;
  Rx<List<StoryDto>?> myStories = (null as List<StoryDto>?).obs;
  Rx<List<UserDTO>?> readers = (null as List<UserDTO>?).obs;
  final PagingController<int, NftDto> pagingController =
      PagingController(firstPageKey: 0);
  final TextEditingController _usernameController = TextEditingController();

  var usernameElseTextEditingController = TextEditingController().obs;

  var isEditingProfile = false.obs;
  var isEditingProfileElse = false.obs;
  var isLoadingPicture = false.obs;
  var urlPicture = "".obs;
  var urlPictureGroup = "".obs;
  var hasUnreadNotification = false.obs;
  var contactUsClicked = false.obs;
  var index = 0.obs;

  final _isUsernameValid = false.obs;
  final _isCheckingUsernameValidity = false.obs;
  final _errorMessage = ''.obs;

  retrieveMe() async {
    _homeController.userMe.value = await ProfileRepo.retrieveUser();
    box.write(SharedPref.USER, _homeController.userMe.value.toJson());
  }

  updateMe(UpdateMeDto updateMeDto, StreamChatClient streamChatClient) async {
    isLoadingPicture.value = true;

    UserDTO userDto = await ProfileRepo.modifyUser(updateMeDto);
    _homeController.userMe.value = userDto;
    box.write(SharedPref.USER, userDto.toJson());
    if (!updateMeDto.userName.isNullOrBlank! ||
        !updateMeDto.picture.isNullOrBlank!) {
      await streamChatClient.updateUser(User(
          id: _homeController.id.value,
          name: _homeController.userMe.value.userName!,
          extraData: {"userDTO": userDto}));
    }
    isEditingProfile.value = false;
    isLoadingPicture.value = false;
  }

  Future<UserDTO?> getUserByWallet(String wallet) async {
    try {
      UserDTO userDto = await ProfileRepo.getUserByWallet(wallet);
      return userDto;
    } catch (err) {
      return null;
    }
  }

  Future<bool> postStory(File file, int type) async {
    Fluttertoast.showToast(
        msg: "Story is being posted",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor:
            SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark
                ? Colors.white
                : const Color(0xFF102437),
        textColor:
            SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark
                ? Colors.black
                : Colors.white,
        fontSize: 16.0);
    String uri = await SimpleS3().uploadFile(
        file,
        "sirkl-bucket",
        "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92",
        AWSRegions.euCentral1,
        debugLog: true);
    StoryCreationDto storyCreationDto = StoryCreationDto(url: uri, type: type);

    try {
      await ProfileRepo.postStory(storyCreationDto);
      return true;
    } catch (err) {
      return false;
    }
  }

  getImageForProfile() async {
    List<Media>? res = await ImagesPicker.pick(
        count: 1,
        pickType: PickType.image,
        language: Language.English,
        cropOpt: CropOption(
          aspectRatio: CropAspectRatio.custom,
          cropType: CropType.circle,
        ),
        maxSize: 500,
        quality: 0.8);
    if (res != null) isLoadingPicture.value = true;
    urlPicture.value = await SimpleS3().uploadFile(
        File(res!.first.path),
        "sirkl-bucket",
        "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92",
        AWSRegions.euCentral1,
        debugLog: true);
    isLoadingPicture.value = false;
  }

  getImageForGroup() async {
    List<Media>? res = await ImagesPicker.pick(
        count: 1,
        pickType: PickType.image,
        language: Language.English,
        cropOpt: CropOption(
          aspectRatio: CropAspectRatio.custom,
          cropType: CropType.circle,
        ),
        maxSize: 500,
        quality: 0.8);
    if (res != null) isLoadingPicture.value = true;
    urlPictureGroup.value = await SimpleS3().uploadFile(
        File(res!.first.path),
        "sirkl-bucket",
        "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92",
        AWSRegions.euCentral1,
        debugLog: true);
    isLoadingPicture.value = false;
  }

  Future<void> checkIfHasUnreadNotification(String id) async {
    bool hasNotification = await ProfileRepo.retrieveHasUnreadNotif(id);
    hasUnreadNotification.value = hasNotification;
  }

  Future<List<NotificationDto>> retrieveNotifications(
          String id, int offset) async =>
      await ProfileRepo.retrieveNotifications(
          id: id, offset: offset.toString());
  Future<void> updateNft(NftModificationDto nftModificationDto) async =>
      await HomeRepo.updateNFTStatus(nftModificationDto);
  retrieveMyStories() async =>
      myStories.value = await ProfileRepo.retrieveMyStories();

  Future<void> retrieveUsersForAStory(String id) async {
    List<UserDTO> users = await ProfileRepo.retrieveReadersForAStory(id);
    readers.value = users;
  }

  deleteUser(String id) async => await ProfileRepo.deleteUser(id);

  Future<Uri> createDynamicLink(String link) async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        link: Uri.parse("${con.urlPrefix.tr}$link"),
        uriPrefix: con.urlPrefix.tr,
        androidParameters: const AndroidParameters(
            packageName: "io.airking.sirkl", minimumVersion: 0));
    final ShortDynamicLink shortLink =
        await dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl;
  }

  Future<void> deleteNotification(String id) async =>
      await ProfileRepo.deleteNotification(id);

  Future<void> promptClaimUsername(BuildContext context) async =>
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                backgroundColor:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xFF102437)
                        : Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                title: const Column(
                  children: [
                    Text(
                      "Claim your free username",
                      style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 24,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      "Remembering your wallet address is easier with a free username from SIRKL.io",
                      style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        promptChooseUsername(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: SColors.activeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          "Claim my username",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? const Color(0xFF102437)
                                : Colors.white,
                            fontSize: 18,
                            decoration: TextDecoration.none,
                            fontFamily: "Gilroy",
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    ElevatedButton(
                      onPressed: () async => Get.back(),
                      style: TextButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor:
                            MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? const Color(0xFF102437)
                                : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Text(
                          "Maybe later",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.grey,
                            fontFamily: "Gilroy",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));

  Future<void> promptChooseUsername(BuildContext context) async =>
      await showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  backgroundColor: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? const Color(0xFF102437)
                      : Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  title: const Column(
                    children: [
                      Text(
                        "Pick your username",
                        style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        "Choose wisely! You won't be able to change it afterwards",
                        style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  content: Obx(() => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            style: const TextStyle(
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w500),
                            controller: _usernameController,
                            onChanged: (value) async {
                              setState(() {});
                              if (value.isNotEmpty) {
                                if (!RegExp(r'^[a-z0-9]+$').hasMatch(value)) {
                                  _isUsernameValid.value = false;
                                  _errorMessage.value =
                                      "Username must contain only lowercase letter and numbers";
                                } else if (value.length < 3) {
                                  _isUsernameValid.value = false;
                                  _errorMessage.value = "Username too short";
                                } else if (value.length > 8) {
                                  _isUsernameValid.value = false;
                                  _errorMessage.value = "Username too long";
                                } else {
                                  _isCheckingUsernameValidity.value = true;
                                  if (await ProfileRepo
                                      .checkIsUsernameAvailable(value)) {
                                    _isUsernameValid.value = true;
                                  } else {
                                    _isUsernameValid.value = false;
                                    _errorMessage.value =
                                        "Username already taken";
                                  }
                                  _isCheckingUsernameValidity.value = false;
                                }
                              } else {
                                _isCheckingUsernameValidity.value = false;
                                _isUsernameValid.value = false;
                                _errorMessage.value = "";
                              }
                            },
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                  fontFamily: 'Gilroy',
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black87),
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: _usernameController.text.isEmpty
                                        ? Colors.grey
                                        : _isUsernameValid.value
                                            ? SColors.activeColor
                                            : Colors.redAccent,
                                    width: 2.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: _usernameController.text.isEmpty
                                        ? Colors.grey
                                        : _isUsernameValid.value
                                            ? SColors.activeColor
                                            : Colors.redAccent,
                                    width: 2.0),
                              ),
                            ),
                          ),
                          !_isUsernameValid.value &&
                                  _errorMessage.value.isNotEmpty
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4.0, left: 4),
                                  child: Text(
                                    _errorMessage.value,
                                    style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontFamily: 'Gilroy',
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      )),
                  actions: <Widget>[
                    Obx(() => _isCheckingUsernameValidity.value
                        ? Center(
                            child: CircularProgressIndicator(
                            color: SColors.activeColor,
                          ))
                        : ElevatedButton(
                            onPressed: () async {
                              if (_usernameController.text.isNotEmpty &&
                                  _usernameController.text.length > 2 &&
                                  _usernameController.text.length < 9 &&
                                  _isUsernameValid.value &&
                                  !_isCheckingUsernameValidity.value) {
                                await updateMe(
                                    UpdateMeDto(
                                        userName: _usernameController.text),
                                    StreamChat.of(context).client);
                                Get.back();
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor:
                                  _usernameController.text.isNotEmpty &&
                                          _usernameController.text.length > 2 &&
                                          _usernameController.text.length < 9 &&
                                          _isUsernameValid.value &&
                                          !_isCheckingUsernameValidity.value
                                      ? SColors.activeColor
                                      : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                "Claim my username",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? const Color(0xFF102437)
                                      : Colors.white,
                                  fontSize: 18,
                                  decoration: TextDecoration.none,
                                  fontFamily: "Gilroy",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )),
                  ],
                ),
              )).then((_) {
        _usernameController.clear();
        _errorMessage.value = '';
        _isCheckingUsernameValidity.value = false;
        _isUsernameValid.value = false;
      });
}
