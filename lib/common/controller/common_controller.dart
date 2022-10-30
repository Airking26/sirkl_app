import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/service/common_service.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/home/service/home_service.dart';

import '../model/refresh_token_dto.dart';

class CommonController extends GetxController{

  final HomeService _homeService = HomeService();
  final CommonService _commonService = CommonService();
  final box = GetStorage();

  Rx<User?> userClicked = (null as User?).obs;
  var userClickedFollowStatus = false.obs;
  var isCardExpandedList = <int>[].obs;
  var isLoadingUsers = true.obs;
  var users = <User>[].obs;
  var gettingStoryAndContacts = true.obs;

  Future<bool> addUserToSirkl(String id) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _commonService.addUserToSirkl(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _commonService.addUserToSirkl(accessToken, id);
      if(request.isOk) {
        userClickedFollowStatus.value = true;
        return true;
      } else {
        return false;
      }
    } else if(request.isOk) {
      userClickedFollowStatus.value = true;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> removeUserToSirkl(String id) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _commonService.removeUserToSirkl(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _commonService.removeUserToSirkl(accessToken, id);
      if(request.isOk) {
       userClickedFollowStatus.value = false;
       return true;
      } else {
        return false;
      }
    } else if(request.isOk) {
      userClickedFollowStatus.value = false;
      return true;
    } else {
      return false;
    }
  }

  showSirklUsers(String id) async{
    gettingStoryAndContacts.value = true;
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _commonService.getSirklUsers(accessToken, id);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _commonService.getSirklUsers(accessToken, id);
      users.value = request.body!.map<User>((user) => userFromJson(json.encode(user))).toList();
      users.refresh();
    } else if(request.isOk) {
      users.value = request.body!.map<User>((user) => userFromJson(json.encode(user))).toList();
      users.sort((a,b){ return a.userName!.toLowerCase().compareTo(b.userName!.toLowerCase());});
      users.refresh();
    }
    gettingStoryAndContacts.value = false;
  }

  searchInSirklUsers(String substring, String offset) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _commonService.searchSirklUsers(accessToken, substring, offset);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _commonService.searchSirklUsers(accessToken, substring, offset);
      if(request.isOk) return request.body!.map<User>((user) => userFromJson(json.encode(user))).toList();
    } else if(request.isOk){
      return request.body!.map<User>((user) => userFromJson(json.encode(user))).toList();
    }
  }

  searchUsers(String substring, String offset) async{
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _commonService.searchUsers(accessToken, substring, offset);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _commonService.searchUsers(accessToken, substring, offset);
      if(request.isOk) return request.body!.map<User>((user) => userFromJson(json.encode(user))).toList();
    } else if(request.isOk){
      return request.body!.map<User>((user) => userFromJson(json.encode(user))).toList();
    }
  }
}