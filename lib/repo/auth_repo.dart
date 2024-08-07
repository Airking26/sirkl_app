


import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/wallet_connect_dto.dart';
import 'package:sirkl/networks/request.dart';

import '../networks/urls.dart';

class AuthRepo {
  static Future<SignInSuccessDto> verifySignature(WalletConnectDto connectDTO) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.post(url: SUrls.verifySignature, body: connectDTO.toJson());
  
    SignInSuccessDto signDTO = SignInSuccessDto.fromJson(res.jsonBody());
    await SRequests.saveTokenInfo(accessToken: signDTO.accessToken, refreshToken: signDTO.refreshToken);

    return signDTO;
  }

  static Future<bool> checkBetaCode(String code) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.checkBetaCode(code));
    return res.jsonBody();
  }

  static Future<bool> isWalletUser(String wallet) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.checkWalletIsUser(wallet));
    var m = res.jsonBody();
    return res.jsonBody();
  }

}