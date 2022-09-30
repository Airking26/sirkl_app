import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/sign_up_dto.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:sirkl/common/constants.dart' as con;

import '../../common/model/refresh_token_dtpo.dart';
import '../../common/model/sign_in_dto.dart';
import '../../common/model/update_fcm_dto.dart';

class HomeController extends GetxController{

  final HomeService _homeService = HomeService();
  final box = GetStorage();

  var accessToken = "".obs;
  var id = "".obs;
  var userMe = User().obs;
  var progress = true.obs;
  var isLoading = false.obs;
  var address = "".obs;
  var isUserExists = false.obs;
  var sessionStatus;

  connectWallet() async {
    final connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'SIRKL',
        description: 'SIRKL Login',
        url: 'https://walletconnect.org',
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ],
      ),
    );

    // Subscribe to events
    connector.on('connect', (session) async{
      address.value = sessionStatus?.accounts[0];
      progress.value = false;
      var isUserExistsBool = await _homeService.isUserExists(address.value);
      if(isUserExistsBool.body == "false") {
        isUserExists.value = true;
      } else {
        isUserExists.value = false;
      }
    });

    connector.on('session_request', (payload) {
    });

    connector.on('disconnect', (session) {
    });

    if (!connector.connected) {
      sessionStatus = await connector.createSession(
        chainId: 4160,
        onDisplayUri: (uri) async {
          await launchUrl(Uri.parse(uri));
        },
      );
    }
  }

  signIn(String wallet, String password) async{
    var requestSignIn = await _homeService.signIn(signInDtoToJson(SignInDto(wallet: wallet, password: password)));
    if(requestSignIn.isOk){
      var signSuccess = signInSuccessDtoFromJson(json.encode(requestSignIn.body));
      userMe.value = signSuccess.user!;
      box.write(con.ACCESS_TOKEN, signSuccess.accessToken!);
      accessToken.value = signSuccess.accessToken!;
      box.write(con.REFRESH_TOKEN, signSuccess.refreshToken!);
      box.write(con.USER, userToJson(signSuccess.user!));
      await putFCMToken();
      Get.back();
      isLoading.value = false;
    } else {
      isLoading.value = false;
      //Get.snackbar(con.error.tr, requestSignIn.statusText ?? "");
    }
  }

  signUp(String wallet, String password, String recoverySentence) async{
    var requestSignUp = await _homeService.signUp(signUpDtoToJson(SignUpDto(wallet: wallet, password: password, recoverySentence: recoverySentence)));
    if(requestSignUp.isOk){
      var signSuccess = signInSuccessDtoFromJson(json.encode(requestSignUp.body));
      userMe.value = signSuccess.user!;
      box.write(con.ACCESS_TOKEN, signSuccess.accessToken!);
      accessToken.value = signSuccess.accessToken!;
      box.write(con.REFRESH_TOKEN, signSuccess.refreshToken!);
      box.write(con.USER, userToJson(signSuccess.user!));
      await putFCMToken();
      isLoading.value = false;
    }
    else if(requestSignUp.bodyString != null && requestSignUp.bodyString!.contains("WALLET_ALREADY_USED")){
      isLoading.value = false;
      Get.snackbar(con.errorRes.tr, con.errorWalletAlreadyUsedRes.tr);
    }
    else {
      isLoading.value = false;
      Get.snackbar(con.errorRes.tr, requestSignUp.statusText ?? "");
    }
  }

  putFCMToken() async {
    final firebaseMessaging = await FirebaseMessaging.instance.getToken();
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var fcm = defaultTargetPlatform == TargetPlatform.android ? updateFcmdtoToJson(UpdateFcmdto(token: firebaseMessaging, platform: 'android')) : updateFcmdtoToJson(UpdateFcmdto(token: firebaseMessaging, platform: 'iOS'));
    var request = await _homeService.uploadFCMToken(accessToken!, fcm);
    var user = userFromJson(json.encode(request.body));
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _homeService.uploadFCMToken(accessToken, fcm);
    }
    userMe.value = user;
    return user;
  }

  retrieveAccessToken() async{
    var accessTok = box.read(con.ACCESS_TOKEN);
    accessToken.value = accessTok ?? '';
    id.value = userFromJson(box.read(con.USER) ?? "").id ?? "";
  }
}