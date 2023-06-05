import 'dart:convert';

import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class HomeService extends GetConnect{

  
  Future<Response<Map<String, dynamic>>> verifySignature(String walletConnectDTO) => post('${con.URL_SERVER}auth/verifySignature', walletConnectDTO);
  Future<Response<Map<String, dynamic>>> refreshToken(String refreshToken) => get('${con.URL_SERVER}auth/refresh', headers: {'Refresh': refreshToken});
  Future<Response<Map<String, dynamic>>> uploadFCMToken(String accessToken, String updateFcmdto) => put('${con.URL_SERVER}user/me/fcm', updateFcmdto, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> uploadAPNToken(String accessToken, String apnToken) => put('${con.URL_SERVER}user/me/apn/$apnToken', null, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>>  getContractAddressesWithAlchemy(String wallet, String? cursor) => get("https://eth-mainnet.g.alchemy.com/nft/v2/${con.alchemyApiKey}/getContractsForOwner?owner=$wallet&pageSize=100&withMetadata=true&filters[]=AIRDROPS&filters[]=SPAM$cursor", headers: {"accept": 'application/json'},);
  Future<Response<Map<String, dynamic>>>  getTokenContractAddressesWithAlchemy(String wallet, String? cursor) => post("https://eth-mainnet.g.alchemy.com/v2/${con.alchemyApiKey}", jsonEncode({
    'jsonrpc': '2.0',
    'id': 1,
    'method': 'alchemy_getTokenBalances',
    'params': [
      wallet,
      "erc20",
    ],
  }), headers: {"accept": 'application/json'});
  Future<Response<Map<String, dynamic>>>  getTokenMetadataWithAlchemy(String contractAddress) => post("https://eth-mainnet.g.alchemy.com/v2/${con.alchemyApiKey}", jsonEncode({
    'jsonrpc': '2.0',
    'id': 1,
    'method': 'alchemy_getTokenMetadata',
    'params': [
      contractAddress,
    ],
  }), headers: {"accept": 'application/json'});
  Future<Response<Map<String, dynamic>>> updateStory(String accessToken, String storyModificationDTO) => patch('${con.URL_SERVER}story/modify', storyModificationDTO, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> deleteStory(String accessToken, String createdBy, String id) => delete('${con.URL_SERVER}story/mine/$createdBy/$id', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> updateNicknames(String accessToken, String wallet, String nicknameCreationDTO) => put('${con.URL_SERVER}nicknames/$wallet', nicknameCreationDTO, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> retrieveNicknames(String accessToken) => get('${con.URL_SERVER}nicknames/retrieve', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> retrieveStories(String accessToken, String offset) => get('${con.URL_SERVER}story/others/$offset', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> retrieveNFTs(String accessToken, String id, bool isFav, String offset) => get('${con.URL_SERVER}nft/retrieve/$id/$isFav/$offset', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> getAllNFTConfig(String accessToken) => get('${con.URL_SERVER}nft/retrieveAll', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> updateAllNFTConfig(String accessToken) => get('${con.URL_SERVER}nft/updateAll', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> registerNotification(String accessToken, String notification) => post('${con.URL_SERVER}notification/register', notification, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> updateNFTStatus(String accessToken, String nFTModificationDTO) => patch('${con.URL_SERVER}nft/update', nFTModificationDTO , headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> receiveWelcomeMessage(String accessToken) => get('${con.URL_SERVER}user/me/welcome_message' , headers: {'Authorization':'Bearer $accessToken'});
}