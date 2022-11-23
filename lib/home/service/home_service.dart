import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class HomeService extends GetConnect{

  Future<Response<Map<String, dynamic>>> signUp(String signUpDTO) => post('${con.URL_SERVER}auth/signUp', signUpDTO);
  Future<Response<Map<String, dynamic>>> signIn(String signInDTO) => post('${con.URL_SERVER}auth/signIn', signInDTO);
  Future<Response<Map<String, dynamic>>> verifySignature(String walletConnectDTO) => post('${con.URL_SERVER}auth/verifySignature', walletConnectDTO);
  Future<Response<Map<String, dynamic>>> signInSeedPhrase(String signInDTO) => post('${con.URL_SERVER}auth/signIn/seedPhrase', signInDTO);
  Future<Response<String>> isUserExists(String wallet) => get('${con.URL_SERVER}auth/availability/wallet/$wallet');
  Future<Response<Map<String, dynamic>>> refreshToken(String refreshToken) => get('${con.URL_SERVER}auth/refresh', headers: {'Refresh': refreshToken});
  Future<Response<Map<String, dynamic>>> uploadFCMToken(String accessToken, String updateFcmdto) => put('${con.URL_SERVER}user/me/fcm', updateFcmdto, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> getNFTs(String wallet) => get("https://deep-index.moralis.io/api/v2/$wallet/nft", headers: {"accept": 'application/json', "X-API-Key": con.moralisApiKey}, query: {"chain": 'eth', "format": 'decimal'});
  Future<Response<Map<String, dynamic>>> getNextNFTs(String wallet, String cursor) => get("https://deep-index.moralis.io/api/v2/$wallet/nft", headers: {"accept": 'application/json', "X-API-Key": con.moralisApiKey}, query: {"chain": 'eth', "format": 'decimal', "cursor": cursor});
  Future<Response<Map<String, dynamic>>> getNFTsContractAddresses(String wallet) => get("https://deep-index.moralis.io/api/v2/$wallet/nft/collections?chain=eth", headers: {"accept": 'application/json', "X-API-Key": con.moralisApiKey}, query: {"chain": 'eth', "format": 'decimal'});
  Future<Response<Map<String, dynamic>>> getNextNFTsContractAddresses(String wallet, String cursor) => get("https://deep-index.moralis.io/api/v2/$wallet/nft/collections?chain=eth", headers: {"accept": 'application/json', "X-API-Key": con.moralisApiKey}, query: {"chain": 'eth', "format": 'decimal',"cursor": cursor});

}