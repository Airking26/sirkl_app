import 'dart:convert';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:images_picker/images_picker.dart';
import 'package:ndialog/ndialog.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/nft_modification_dto.dart';
import 'package:sirkl/common/model/notification_dto.dart';
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/story_creation_dto.dart';
import 'package:sirkl/common/model/story_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/groups/controller/groups_controller.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/profile/service/profile_service.dart';

class ProfileController extends GetxController{

  final box = GetStorage();
  final _profileService = ProfileService();
  final _homeService = HomeService();
  final _homeController = Get.put(HomeController());

  Rx<UserDTO?> isUserExists = (null as UserDTO?).obs;
  Rx<List<StoryDto>?> myStories = (null as List<StoryDto>?).obs;
  Rx<List<UserDTO>?> readers = (null as List<UserDTO>?).obs;
  var isCardExpanded = false.obs;
  Rx<Uint8List?> videoThumbnail = Uint8List(0).obs;
  var isEditingProfile = false.obs;
  var isEditingProfileElse = false.obs;
  var isLoadingPicture = false.obs;
  var usernameTextEditingController = TextEditingController().obs;
  var descriptionTextEditingController = TextEditingController().obs;
  var usernameElseTextEditingController = TextEditingController().obs;
  var urlPicture = "".obs;
  var urlPictureGroup = "".obs;
  var hasUnreadNotif = false.obs;
  var isStoryPosting = false.obs;
  var simpleS3 = SimpleS3().obs;

  updateMe(UpdateMeDto updateMeDto, StreamChatClient streamChatClient) async {
    isLoadingPicture.value = true;
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.modifyUser(accessToken, updateMeDtoToJson(updateMeDto));
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.modifyUser(accessToken, updateMeDtoToJson(updateMeDto));
      if(request.isOk){
        _homeController.userMe.value = userFromJson(json.encode(request.body));
        box.write(con.USER, userToJson(userFromJson(json.encode(request.body))));
        if(!updateMeDto.userName.isNullOrBlank! || !updateMeDto.picture.isNullOrBlank!) {
          await streamChatClient.disconnectUser();
          await _homeController.retrieveTokenStreamChat(streamChatClient, null);
        }
        isEditingProfile.value = false;
        isLoadingPicture.value = false;
      } else {
        isLoadingPicture.value = false;
      }
    } else if(request.isOk){
      _homeController.userMe.value = userFromJson(json.encode(request.body));
      box.write(con.USER, userToJson(userFromJson(json.encode(request.body))));
      if(!updateMeDto.userName.isNullOrBlank! || !updateMeDto.picture.isNullOrBlank!) {
        await streamChatClient.disconnectUser();
        await _homeController.retrieveTokenStreamChat(streamChatClient, null);
      }
      isEditingProfile.value = false;
      isLoadingPicture.value = false;
    } else {
      isLoadingPicture.value = false;
    }
  }

  Future<UserDTO?> getUserByWallet(String wallet) async{
    UserDTO? user;
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.getUserByWallet(accessToken, wallet);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.getUserByWallet(accessToken, wallet);
      if(request.isOk && request.body != null){
        user = userFromJson(json.encode(request.body));
      } else {
        user = null;
      }
    } else if(request.isOk && request.body != null) {
      user = userFromJson(json.encode(request.body));
    } else {
      user = null;
    }
    return user;
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
    var uri = await simpleS3.value.uploadFile(file, "sirkl-bucket", "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92", AWSRegions.euCentral1, debugLog: true);
    var storyCreationDto = StoryCreationDto(url: uri, type: type);
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.postStory(accessToken, storyCreationDtoToJson(storyCreationDto));
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.postStory(accessToken, storyCreationDtoToJson(storyCreationDto));
      if(request.isOk){
        return true;
      } else {
        return false;
      }
    } else if(request.isOk){
      return true;
    } else {
      return false;
    }
  }

  getImage(bool profile) async{
    List<Media>? res = await ImagesPicker.pick(count: 1, pickType: PickType.all, language: Language.English, cropOpt: CropOption(aspectRatio: CropAspectRatio.custom, cropType: CropType.circle,), maxSize: 500, quality: 0.8);
    if(res != null) isLoadingPicture.value = true;
    profile ? urlPicture.value : urlPictureGroup.value = await SimpleS3().uploadFile(File(res!.first.path), "sirkl-bucket", "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92", AWSRegions.euCentral1, debugLog: true);
    isLoadingPicture.value = false;
  }

  checkIfHasUnreadNotif(String id) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.retrieveHasUnreadNotif(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.retrieveHasUnreadNotif(accessToken, id);
      if(request.isOk){
        if(request.body! == 'false') {
          hasUnreadNotif.value = false;
        } else {
          hasUnreadNotif.value = true;
        }
      }
    } else if(request.isOk){
      if(request.body! == 'false') {
        hasUnreadNotif.value = false;
      } else {
        hasUnreadNotif.value = true;
      }
    }
  }

  retrieveNotifications(String id, int offset) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    Response<List<dynamic>> request;
    try{
      request = await _profileService.retrieveNotifications(accessToken, id, offset.toString());
    } on CastError{
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request =  await _profileService.retrieveNotifications(accessToken, id, offset.toString());
    }
    if(request.isOk) {
      return notificationDtoFromJson(json.encode(request.body));
    }
  }

  updateNft(NftModificationDto nftModificationDto, StreamChatClient client) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _homeService.updateNFTStatus(accessToken, nftModificationDtoToJson(nftModificationDto));
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _homeService.updateNFTStatus(accessToken, nftModificationDtoToJson(nftModificationDto));
      if(request.isOk){
        if(nftModificationDto.isFav) {
          await client.updateChannelPartial(nftModificationDto.contractAddress, 'try', set: {"${_homeController.id.value}_favorite" : true});
        } else {
          await client.updateChannelPartial(nftModificationDto.contractAddress, 'try', unset: ["${_homeController.id.value}_favorite"]);
        }
      }
    } else if(request.isOk){
      if(nftModificationDto.isFav) {
        await client.updateChannelPartial(nftModificationDto.contractAddress, 'try', set: {"${_homeController.id.value}_favorite" : true});
      } else {
        await client.updateChannelPartial(nftModificationDto.contractAddress, 'try', unset: ["${_homeController.id.value}_favorite"]);
      }
    }
  }

  retrieveMyStories() async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.retrieveMyStories(accessToken);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.retrieveMyStories(accessToken);
      if(request.isOk){
        myStories.value = myStoryDtoFromJson(json.encode(request.body));
      }
    } else if(request.isOk){
      myStories.value = myStoryDtoFromJson(json.encode(request.body));
    }
  }

  retrieveUsersForAStory(String id) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.retrieveReadersForAStory(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.retrieveReadersForAStory(accessToken, id);
      if(request.isOk){
        readers.value = request.body!.map<UserDTO>((user) => userFromJson(json.encode(user))).toList();
      }
    } else if(request.isOk){
      readers.value = request.body!.map<UserDTO>((user) => userFromJson(json.encode(user))).toList();
    }
  }

  deleteUser(String id) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.deleteUser(accessToken, id);
    if(request.statusCode == 401) {
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.deleteUser(accessToken, id);
    }
  }

  Future<Uri> createDynamicLink(String link) async{
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    final DynamicLinkParameters parameters = DynamicLinkParameters(link: Uri.parse("${con.urlPrefix.tr}$link"), uriPrefix: con.urlPrefix.tr, androidParameters: const AndroidParameters(packageName: "io.airking.sirkl", minimumVersion: 0));
    final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl;
  }

}