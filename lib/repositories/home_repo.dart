import 'package:sirkl/config/s_config.dart';
import 'package:sirkl/models/contract_address_dto.dart';
import 'package:sirkl/models/nft_dto.dart';
import 'package:sirkl/models/nft_modification_dto.dart';
import 'package:sirkl/models/nickname_creation_dto.dart';
import 'package:sirkl/models/notification_register_dto.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/models/story_dto.dart';
import 'package:sirkl/models/story_modification_dto.dart';
import 'package:sirkl/models/token_dto.dart';
import 'package:sirkl/models/token_metadata_details_dto.dart';
import 'package:sirkl/models/update_fcm_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class HomeRepo {
  static Future<UserDTO> uploadFCMToken(UpdateFcmdto fcmBody) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.put(url: SUrls.userMeFCM, body: fcmBody.toJson());
    return UserDTO.fromJson(res.jsonBody());
  }

  static Future<void> uploadAPNToken(String apnToken) async =>
      await SRequests(SUrls.baseURL)
          .put(url: '${SUrls.userMeAPN}/$apnToken', body: null);

  static Future<TokenDto> getTokenContractAddressesWithAlchemy(
      {required String wallet}) async {
    SRequests req = SRequests(SUrls.ethMainNetBaseUrl);
    Response res = await req.post(url: "v2/${SConfig.alchemyApiKey}", body: {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'alchemy_getTokenBalances',
      'params': [
        wallet,
      ],
    });
    return TokenDto.fromJson(res.jsonBody());
  }

  static Future<TokenMetadataDetailsDto> getTokenMetadataWithAlchemy(
      {required String token}) async {
    SRequests req = SRequests(SUrls.ethMainNetBaseUrl);
    Response res = await req.post(url: "v2/${SConfig.alchemyApiKey}", body: {
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'alchemy_getTokenMetadata',
      'params': [
        token,
      ],
    });
    return TokenMetadataDetailsDto.fromJson(res.jsonBody());
  }

  static Future<ContractAddressDto> getContractAddressesWithAlchemy(
      {required wallet, String? cursor}) async {
    SRequests req = SRequests(SUrls.ethMainNetBaseUrl);
    Response res = await req.get(
        "nft/v2/${SConfig.alchemyApiKey}/getContractsForOwner?owner=$wallet&pageSize=100&withMetadata=true&filters[]=AIRDROPS&filters[]=SPAM$cursor");
    return ContractAddressDto.fromJson(res.jsonBody());
  }

  static Future<void> getAllNFTConfig() async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.nftRetrieveAll);
  }

  static Future<void> updateAllNFTConfig() async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.nftUpdateAll);
  }

  static Future<List<String>> retrieveContactAddress() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.retrieveContractAddress);
    List<dynamic> list = res.jsonBody();
    return list.cast<String>();
  }

  static Future<List<NftDto>> retrieveNFTs(
      {required String id, required bool isFav, required String offset}) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get('${SUrls.nftRetrieve}/$id/$isFav/$offset');
    List<dynamic> list = res.jsonBody();
    return list.map((e) => NftDto.fromJson(e)).toList();
  }

  static Future<void> updateStory(StoryModificationDto modifiedStory) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res =
        await req.patch(url: SUrls.storyModify, body: modifiedStory.toJson());
    // Server must be returning some response
  }

  static Future<void> deleteStory(
      {required String createdBy, required String id}) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.delete(url: '${SUrls.storyMine}/$createdBy/$id');
  }

  static Future<void> updateNicknames(
      {required String wallet,
      required NicknameCreationDto nickNameDto}) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.put(
        url: '${SUrls.nicknames}/$wallet', body: nickNameDto.toJson());
  }

  static Future<void> receiveWelcomeMessage() async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.userMeWelcomeMessage);
  }

  static Future<Map<String, dynamic>> retrieveNicknames() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.nicknamesRetrieve);
    return res.jsonBody();
  }

  static Future<List<List<StoryDto>>> retrieveStories(String offset) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get('${SUrls.storyOthers}/$offset');
    return (res.jsonBody() as List)
        .map((list) => (list as List).map((e) => StoryDto.fromJson(e)).toList())
        .toList();
  }

  static Future<void> registerNotification(
      NotificationRegisterDto notification) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(
        url: SUrls.notificationRegister, body: notification.toJson());
  }

  static Future<void> updateNFTStatus(NftModificationDto nftModi) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.patch(url: SUrls.nftUpdate, body: nftModi.toJson());
  }
}
