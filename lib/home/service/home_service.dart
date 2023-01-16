import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class HomeService extends GetConnect{

  Future<Response<Map<String, dynamic>>> signUp(String signUpDTO) => post('${con.URL_SERVER}auth/signUp', signUpDTO);
  Future<Response<Map<String, dynamic>>> signIn(String signInDTO) => post('${con.URL_SERVER}auth/signIn', signInDTO);
  Future<Response<Map<String, dynamic>>> verifySignature(String walletConnectDTO) => post('${con.URL_SERVER}auth/verifySignature', walletConnectDTO);
  Future<Response<Map<String, dynamic>>> signInSeedPhrase(String signInDTO) => post('${con.URL_SERVER}auth/signIn/seedPhrase', signInDTO);
  Future<Response<Map<String, dynamic>>> refreshToken(String refreshToken) => get('${con.URL_SERVER}auth/refresh', headers: {'Refresh': refreshToken});
  Future<Response<Map<String, dynamic>>> uploadFCMToken(String accessToken, String updateFcmdto) => put('${con.URL_SERVER}user/me/fcm', updateFcmdto, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> uploadAPNToken(String accessToken, String apnToken) => put('${con.URL_SERVER}user/me/apn/$apnToken', null, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> getNFTs(String wallet) => get("https://deep-index.moralis.io/api/v2/$wallet/nft", headers: {"accept": 'application/json', "X-API-Key": con.moralisApiKey}, query: {"chain": 'eth', "format": 'decimal', "disable_total": 'true', "normalizeMetadata": 'true'});
  Future<Response<Map<String, dynamic>>> getNFTByAlchemy(String wallet) => get("https://eth-mainnet.g.alchemy.com/v2/${con.alchemyApiKey}/getNFTs?owner=$wallet&omitMetadata=false&filters[]=AIRDROPS&filters[]=SPAM",  headers: {"accept": 'application/json'});
  Future<Response<Map<String, dynamic>>> getNextNFTByAlchemy(String wallet, String cursor) => get("https://eth-mainnet.g.alchemy.com/v2/${con.alchemyApiKey}/getNFTs?owner=$wallet&omitMetadata=false&filters[]=AIRDROPS&filters[]=SPAM&pageSize=25&pageKey=$cursor",  headers: {"accept": 'application/json'});
  Future<Response<Map<String, dynamic>>> getNextNFTByAlchemyForGroup(String wallet, String cursor) => get("https://eth-mainnet.g.alchemy.com/v2/${con.alchemyApiKey}/getNFTs?owner=$wallet&omitMetadata=false&filters[]=AIRDROPS&filters[]=SPAM&pageKey=$cursor",  headers: {"accept": 'application/json'});
  Future<Response<Map<String, dynamic>>> getNextNFTs(String wallet, String cursor) => get("https://deep-index.moralis.io/api/v2/$wallet/nft", headers: {"accept": 'application/json', "X-API-Key": con.moralisApiKey}, query: {"chain": 'eth', "format": 'decimal', "disable_total": 'true', "normalizeMetadata": 'true', "cursor": cursor});
  Future<Response<Map<String, dynamic>>> getNFTsContractAddresses(String wallet) => get("https://deep-index.moralis.io/api/v2/$wallet/nft/collections?chain=eth&disable_total=true", headers: {"accept": 'application/json', "X-API-Key": con.moralisApiKey}, query: {"chain": 'eth', "format": 'decimal'});
  Future<Response<Map<String, dynamic>>> getNextNFTsContractAddresses(String wallet, String cursor) => get("https://deep-index.moralis.io/api/v2/$wallet/nft/collections?chain=eth&disable_total=true", headers: {"accept": 'application/json', "X-API-Key": con.moralisApiKey}, query: {"chain": 'eth', "format": 'decimal',"cursor": cursor});
  Future<Response<Map<String, dynamic>>> updateStory(String accessToken, String storyModificationDTO) => patch('${con.URL_SERVER}story/modify', storyModificationDTO, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> updateNicknames(String accessToken, String wallet, String nickname) => put('${con.URL_SERVER}nicknames/$wallet/$nickname', null, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> retrieveNicknames(String accessToken) => get('${con.URL_SERVER}nicknames/retrieve', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> retrieveStories(String accessToken, String offset) => get('${con.URL_SERVER}story/$offset', headers: {'Authorization':'Bearer $accessToken'});
}