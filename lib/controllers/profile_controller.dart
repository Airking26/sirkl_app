import 'dart:convert';
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
import 'package:sirkl/common/model/nft_dto.dart';
import 'package:sirkl/common/model/nft_modification_dto.dart';
import 'package:sirkl/common/model/notification_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/story_creation_dto.dart';
import 'package:sirkl/common/model/story_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/repo/home_repo.dart';
import 'package:sirkl/repo/profile_repo.dart';

import '../common/save_pref_keys.dart';
import 'home_controller.dart';

class ProfileController extends GetxController{

  final box = GetStorage();

  HomeController get _homeController => Get.find<HomeController>();

  Rx<UserDTO?> isUserExists = (null as UserDTO?).obs;
  Rx<List<StoryDto>?> myStories = (null as List<StoryDto>?).obs;
  Rx<List<UserDTO>?> readers = (null as List<UserDTO>?).obs;
  final PagingController<int, NftDto> pagingController = PagingController(firstPageKey: 0);

  var usernameElseTextEditingController = TextEditingController().obs;

  var isEditingProfile = false.obs;
  var isEditingProfileElse = false.obs;
  var isLoadingPicture = false.obs;
  var urlPicture = "".obs;
  var urlPictureGroup = "".obs;
  var hasUnreadNotif = false.obs;
  var contactUsClicked = false.obs;
  var index = 0.obs;

  updateMe(UpdateMeDto updateMeDto, StreamChatClient streamChatClient) async {
    isLoadingPicture.value = true;

    UserDTO userDto = await ProfileRepo.modifyUser(updateMeDto );
        _homeController.userMe.value = userDto;
      box.write(SharedPref.USER, userDto.toJson());
      if(!updateMeDto.userName.isNullOrBlank! || !updateMeDto.picture.isNullOrBlank!) {
        UserDTO userToPass = UserDTO(id: _homeController.userMe.value.id,
            userName: _homeController.userMe.value.userName,
            picture: _homeController.userMe.value.picture,
            isAdmin: _homeController.userMe.value.isAdmin,
            createdAt: _homeController.userMe.value.createdAt,
            description: _homeController.userMe.value.description,
            fcmToken: _homeController.userMe.value.fcmToken,
            wallet: _homeController.userMe.value.wallet,
            following: _homeController.userMe.value.following,
            isInFollowing: _homeController.userMe.value.isInFollowing);
        await streamChatClient.updateUser(User(id: _homeController.id.value, name: _homeController.userMe.value.userName!, extraData: {"userDTO": userToPass}));
      }
      isEditingProfile.value = false;
      isLoadingPicture.value = false;
  }

  Future<UserDTO?> getUserByWallet(String wallet) async{


  try {
        UserDTO userDto = await ProfileRepo.getUserByWallet( wallet);

    return userDto;
  } catch(err) {
    return null;
  }
  

  }

  Future<bool> postStory(File file, int type) async{
    Fluttertoast.showToast(
        msg: "Story is being posted",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? Colors.white : const Color(0xFF102437) ,
        textColor: SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark ? Colors.black : Colors.white,
        fontSize: 16.0
    );
    String uri = await SimpleS3().uploadFile(file, "sirkl-bucket", "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92", AWSRegions.euCentral1, debugLog: true);
    StoryCreationDto storyCreationDto = StoryCreationDto(url: uri, type: type);

    try {
      await ProfileRepo.postStory(storyCreationDto);
      return true;
    } catch(err) {
      return false;
    }

  }

  getImageForProfile() async{
    List<Media>? res = await ImagesPicker.pick(count: 1, pickType: PickType.image, language: Language.English, cropOpt: CropOption(aspectRatio: CropAspectRatio.custom, cropType: CropType.circle,), maxSize: 500, quality: 0.8);
    if(res != null) isLoadingPicture.value = true;
    urlPicture.value = await SimpleS3().uploadFile(File(res!.first.path), "sirkl-bucket", "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92", AWSRegions.euCentral1, debugLog: true);
    isLoadingPicture.value = false;
  }

  getImageForGroup() async{
    List<Media>? res = await ImagesPicker.pick(count: 1, pickType: PickType.image, language: Language.English, cropOpt: CropOption(aspectRatio: CropAspectRatio.custom, cropType: CropType.circle,), maxSize: 500, quality: 0.8);
    if(res != null) isLoadingPicture.value = true;
    urlPictureGroup.value = await SimpleS3().uploadFile(File(res!.first.path), "sirkl-bucket", "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92", AWSRegions.euCentral1, debugLog: true);
    isLoadingPicture.value = false;
  }

  Future<void> checkIfHasUnreadNotif(String id) async{
    bool hasNoti = await ProfileRepo.retrieveHasUnreadNotif(id);
    hasUnreadNotif.value = hasNoti;
  }

  Future< List<NotificationDto>> retrieveNotifications(String id, int offset) async {
      return await ProfileRepo.retrieveNotifications( id: id, offset: offset.toString());
  }

  Future<void> updateNft(NftModificationDto nftModificationDto) async{

   await HomeRepo.updateNFTStatus(nftModificationDto);

  }

  retrieveMyStories() async{
    myStories.value = await ProfileRepo.retrieveMyStories();
  }

  Future<void> retrieveUsersForAStory(String id) async{

    List<UserDTO> users = await ProfileRepo.retrieveReadersForAStory(id);

    readers.value = users;
    
  }

  deleteUser(String id) async{
      await ProfileRepo.deleteUser(id);
  }

  Future<Uri> createDynamicLink(String link) async{
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    final DynamicLinkParameters parameters = DynamicLinkParameters(link: Uri.parse("${con.urlPrefix.tr}$link"), uriPrefix: con.urlPrefix.tr, androidParameters: const AndroidParameters(packageName: "io.airking.sirkl", minimumVersion: 0));
    final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl;
  }

  Future<void> deleteNotification(String id) async{
  
   await ProfileRepo.deleteNotification( id);

  }

}