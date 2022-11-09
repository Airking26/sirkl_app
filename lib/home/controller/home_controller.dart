import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sirkl/common/model/collection_dto.dart';
import 'package:sirkl/common/model/moralis_metadata_dto.dart';
import 'package:sirkl/common/model/moralis_nft_contract_addresse.dart';
import 'package:sirkl/common/model/moralis_root_dto.dart';
import 'package:sirkl/common/model/sign_in_seed_phrase_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/sign_up_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/home/service/home_service.dart';
import 'package:sirkl/profile/service/profile_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:zego_zim/zego_zim.dart';

import '../../common/model/refresh_token_dto.dart';
import '../../common/model/sign_in_dto.dart';
import '../../common/model/update_fcm_dto.dart';

class HomeController extends GetxController{

  final HomeService _homeService = HomeService();
  final ProfileService _profileService = ProfileService();
  var id = "".obs;
  final box = GetStorage();

  var isPasswordLongEnough = false.obs;
  var isPasswordIncludeNumber = false.obs;
  var isPasswordIncludeSpecialCharacter = false.obs;
  var arePasswordIdentical = true.obs;
  var seedPhraseCopied = false.obs;
  var signUpSeedPhrase = false.obs;
  var forgotPassword = false.obs;
  var recoverPassword = false.obs;
  var password = "".obs;

  var accessToken = "".obs;
  var userMe = User().obs;
  var progress = true.obs;
  var isLoading = false.obs;
  var isLoadingNfts = true.obs;
  var address = "".obs;
  var isUserExists = false.obs;
  var sessionStatus;
  var nfts = <CollectionDbDto>[].obs;
  var tempSignInSuccess = SignInSuccessDto().obs;
  var tokenZegoCloud = "".obs;

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

    connector.on('session_request', (payload) {});

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

  signInSeedPhrase(String seedPhrase) async{
    var requestSignIn = await _homeService.signInSeedPhrase(signInSeedPhraseDtoToJson(SignInSeedPhraseDto(wallet: address.value, seedPhrase: seedPhrase)));
    if(requestSignIn.isOk){
      tempSignInSuccess.value = signInSuccessDtoFromJson(json.encode(requestSignIn.body));
      recoverPassword.value = true;
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
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken!);
      var refreshTokenDto = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDto.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _homeService.uploadFCMToken(accessToken, fcm);
    }
    userMe.value = userFromJson(json.encode(request.body));
    await retrieveTokenZegoCloud();
    await getNFTsContractAddresses();
  }

  retrieveAccessToken() async{
    var accessTok = box.read(con.ACCESS_TOKEN);
    accessToken.value = accessTok ?? '';
    id.value = userFromJson(box.read(con.USER) ?? "").id ?? "";
  }

  getNFTsContractAddresses() async{
    var req = await _homeService.getNFTsContractAddresses(userMe.value.wallet!);
    if(req.body != null){
    var initialArray = moralisNftContractAdressesFromJson(json.encode(req.body)).result!;
    if(moralisNftContractAdressesFromJson(json.encode(req.body)).cursor != null) {
      var cursor = moralisNftContractAdressesFromJson(json.encode(req.body))
          .cursor;
      while (cursor != null) {
        var newReq = await _homeService.getNextNFTsContractAddresses(
            userMe.value.wallet!, cursor);
        initialArray.addAll(
            moralisNftContractAdressesFromJson(json.encode(newReq.body))
                .result!);
        cursor =
            moralisNftContractAdressesFromJson(json.encode(newReq.body)).cursor;
      }
    }

      List<String> contractAddresses = [];
      for (var element in initialArray) {
        contractAddresses.add(element.tokenAddress!);
      }
      updateMe(UpdateMeDto(contractAddresses: contractAddresses));
    }
  }

  getNFTsTemporary(String wallet) async{
    isLoadingNfts.value = true;
    nfts.value.clear();
    var req = await _homeService.getNFTs(wallet);
    var mainCollection = moralisRootDtoFromJson(json.encode(req.body)).result!;
    var cursor = moralisRootDtoFromJson(json.encode(req.body)).cursor;
    while(cursor != null){
      var newReq = await _homeService.getNextNFTs(wallet, cursor);
      mainCollection.addAll(moralisRootDtoFromJson(json.encode(newReq.body)).result!);
      cursor = moralisRootDtoFromJson(json.encode(newReq.body)).cursor;
    }

    var groupedCollection = mainCollection.groupBy((p0) => p0!.name);

    groupedCollection.forEach((key, value) async{
      nfts.value.add(CollectionDbDto(collectionName: key ?? "", collectionImages: value.map((e) {
        if(moralisMetadataDtoFromJson(e!.metadata!).image!.startsWith("ipfs://")) {
          return "https://ipfs.moralis.io:2053/ipfs/${moralisMetadataDtoFromJson(e.metadata!).image!.split("ipfs://").last}";
        } else if(moralisMetadataDtoFromJson(e.metadata!).image!.contains("/ipfs/")){
          return "https://ipfs.moralis.io:2053/ipfs/${moralisMetadataDtoFromJson(e.metadata!).image!.split("/ipfs/").last}";
        }
        else {
          return moralisMetadataDtoFromJson(e.metadata!).image!;
        }
      }
      ).toList()));
      nfts.refresh();
    });

    isLoadingNfts.value = false;
  }

  updateMe(UpdateMeDto updateMeDto) async {
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.modifyUser(
        accessToken, updateMeDtoToJson(updateMeDto));
    if (request.statusCode == 401) {
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(
          json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.modifyUser(
          accessToken, updateMeDtoToJson(updateMeDto));
      if (request.isOk) {
        userMe.value = userFromJson(json.encode(request.body));
      }}
    else if (request.isOk) {
      userMe.value = userFromJson(json.encode(request.body));
    }
  }

  retrieveTokenZegoCloud() async{
    ZIMUserInfo userInfo = ZIMUserInfo();
    userInfo.userID = userMe.value.id!;
    userInfo.userName = userMe.value.userName!;
    var accessToken = box.read(con.ACCESS_TOKEN);
    var refreshToken = box.read(con.REFRESH_TOKEN);
    var request = await _profileService.retrieveTokenZegoCloud(accessToken);
    if(request.statusCode == 401){
      var requestToken = await _homeService.refreshToken(refreshToken);
      var refreshTokenDTO = refreshTokenDtoFromJson(json.encode(requestToken.body));
      accessToken = refreshTokenDTO.accessToken!;
      box.write(con.ACCESS_TOKEN, accessToken);
      request = await _profileService.retrieveTokenZegoCloud(accessToken);
      if(request.isOk) {
        tokenZegoCloud.value = request.body!;
        ZIM.getInstance()?.login(userInfo, tokenZegoCloud.value).then((value){
        }).catchError((onError){
          switch (onError.runtimeType) {
            case PlatformException:
              break;
            default:
          }
        });
      }
    } else if (request.isOk) {
      tokenZegoCloud.value = json.decode(request.body!);
      ZIM.getInstance()?.login(userInfo, tokenZegoCloud.value).then((value){
      }).catchError((onError){
        switch (onError.runtimeType) {
          case PlatformException:
            break;
          default:
        }
      });
    }
  }

}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
          (Map<K, List<E>> map, E element) =>
      map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}