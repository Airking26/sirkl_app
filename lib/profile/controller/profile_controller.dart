import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:images_picker/images_picker.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/refresh_token_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/profile/service/profile_service.dart';

class ProfileController extends GetxController{

  final box = GetStorage();
  final _profileService = ProfileService();
  final _homeService = HomeService();
  final _homeController = Get.put(HomeController());

  var isCardExpanded = false.obs;
  var isEditingProfile = false.obs;
  final usernameTextEditingController = TextEditingController().obs;
  final descriptionTextEditingController = TextEditingController().obs;

  updateMe(UpdateMeDto updateMeDto) async {
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
      }
    } else if(request.isOk){
      _homeController.userMe.value = userFromJson(json.encode(request.body));
      isEditingProfile.value = false;
    }
  }

  getImage() async{
    List<Media>? res = await ImagesPicker.pick(count: 1, pickType: PickType.image, language: Language.English);
    var o = res;
    var j = "";
  }

}