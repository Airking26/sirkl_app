import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/models/wallet_connect_dto.dart';
import 'package:sirkl/networks/request.dart';

import '../networks/urls.dart';

class AuthRepo {
  static Future<SignInSuccessDto> verifySignature(
      WalletConnectDto connectDTO) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res =
        await req.post(url: SUrls.verifySignature, body: connectDTO.toJson());

    SignInSuccessDto signDTO = SignInSuccessDto.fromJson(res.jsonBody());
    await SRequests.saveTokenInfo(
        accessToken: signDTO.accessToken, refreshToken: signDTO.refreshToken);

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
    return res.jsonBody();
  }
}
