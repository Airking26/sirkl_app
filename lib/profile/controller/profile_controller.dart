import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:images_picker/images_picker.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/profile/service/profile_service.dart';
import 'package:zego_zim/zego_zim.dart';

class ProfileController extends GetxController{

  final box = GetStorage();
  final _profileService = ProfileService();
  final _homeService = HomeService();
  final _homeController = Get.put(HomeController());

  var isCardExpanded = false.obs;
  var isCardExpandedList = <int>[].obs;
  var isEditingProfile = false.obs;
  var isLoadingPicture = false.obs;
  var usernameTextEditingController = TextEditingController().obs;
  var descriptionTextEditingController = TextEditingController().obs;
  var urlPicture = "".obs;
  var tokenZegoCloud = "".obs;

  updateMe(UpdateMeDto updateMeDto) async {
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
        isEditingProfile.value = false;
        isLoadingPicture.value = false;
      } else {
        isLoadingPicture.value = false;
      }
    } else if(request.isOk){
      _homeController.userMe.value = userFromJson(json.encode(request.body));
      isEditingProfile.value = false;
      isLoadingPicture.value = false;
    } else {
      isLoadingPicture.value = false;
    }
  }

  getImage() async{
    List<Media>? res = await ImagesPicker.pick(count: 1, pickType: PickType.image, language: Language.English,
      cropOpt: CropOption(
      aspectRatio: CropAspectRatio.custom,
      cropType: CropType.circle, // currently for android
    ), maxSize: 500, quality: 0.8);
    //await ImagesPicker.saveImageToAlbum(File(res!.first.path), albumName: "Pictures");
    if(res != null) isLoadingPicture.value = true;
    urlPicture.value = await SimpleS3().uploadFile(File(res!.first.path), "sirkl-bucket", "eu-central-1:aef70dab-a133-4297-abba-653ca5c77a92", AWSRegions.euCentral1, debugLog: true);
    isLoadingPicture.value = false;
  }

  retrieveTokenZegoCloud() async{
    ZIMUserInfo userInfo = ZIMUserInfo();
    userInfo.userID = _homeController.userMe.value.id!;
    userInfo.userName = _homeController.userMe.value.userName!;
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.retrieveTokenZegoCloud(accessToken);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.retrieveTokenZegoCloud(accessToken);
      if(request.isOk) tokenZegoCloud.value = request.body!;
    } else if (request.isOk) {
      tokenZegoCloud.value = json.decode(request.body!);
      ZIM.getInstance()?.login(userInfo, tokenZegoCloud.value).then((value){
        var t = value;
        var c = "";
      }).catchError((onError){
        switch (onError.runtimeType) {
          case PlatformException:
            var k = "error";
          //This will be triggered when login failed.
            break;
          default:
        }
      });
    }
  }

}