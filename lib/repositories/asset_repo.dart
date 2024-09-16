import 'package:sirkl/models/group_creation_dto.dart';
import 'package:sirkl/models/nft_dto.dart';
import 'package:sirkl/models/nft_modification_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class AssetRepo {
  static Future<void> getAllNFTConfig() async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.nftRetrieveAll);
  }

  static Future<void> updateAllNFTConfig() async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.nftUpdateAll);
  }

  static Future<List<NftDto>> retrieveNFTs(
      {required String id, required bool isFav, required String offset}) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.nftRetrieve(id, isFav, offset));
    List<dynamic> list = res.jsonBody();
    return list.map((e) => NftDto.fromJson(e)).toList();
  }

  static Future<void> updateNFTStatus(
      NftModificationDto nftModification) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.patch(url: SUrls.nftUpdate, body: nftModification.toJson());
  }

  static Future<List<String>> retrieveContactAddress() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.retrieveContractAddress);
    List<dynamic> list = res.jsonBody();
    return list.cast<String>();
  }

  static Future<List<GroupCreationDto>>
      retrieveAssetsAvailableToCommunityCreation() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.retrieveAssetToCreateNewCommunity("0"));
    List<dynamic> list = res.jsonBody();
    return list.map((e) => GroupCreationDto.fromJson(e)).toList();
  }

  static Future<bool> isCommunityCreator(String wallet, String contract) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.isCommunityCreator(wallet, contract));
    return res.jsonBody();
  }
}
