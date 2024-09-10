import 'package:sirkl/models/contract_address_dto.dart';
import 'package:sirkl/models/contract_creator_dto.dart';
import 'package:sirkl/models/group_creation_dto.dart';
import 'package:sirkl/models/group_dto.dart';
import 'package:sirkl/models/token_dto.dart';
import 'package:sirkl/models/token_metadata_details_dto.dart';
import 'package:sirkl/networks/request.dart';

import '../config/s_config.dart';
import '../networks/urls.dart';

class GroupRepo {
  static Future<void> createGroup(GroupCreationDto groupCreationDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(url: SUrls.groupCreate, body: groupCreationDto.toJson());
  }

  static Future<List<GroupDto>> retrieveGroups() async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.groupRetrieve);
    return (res.jsonBody() as List<dynamic>)
        .map((e) => GroupDto.fromJson(e))
        .toList();
  }

  static Future<ContractCreatorDto?> retrieveCreatorGroup(
      String contract) async {
    SRequests req = SRequests(SUrls.etherscanBaseUrl);
    Response res = await req.get(
        "api?module=contract&action=getcontractcreation&contractaddresses=$contract&apikey=${SConfig.ETHERSCAN_API_KEY}");
    try {
      return ContractCreatorDto.fromJson(res.jsonBody());
    } catch (err) {
      return null;
    }
  }

  static Future<TokenDto> getTokenContractAddressesWithAlchemy(
      {required String wallet}) async {
    SRequests req = SRequests(SUrls.ethMainNetBaseUrl);
    Response res = await req.post(url: "v2/${SConfig.ALCHEMY_API_KEY}", body: {
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
    Response res = await req.post(url: "v2/${SConfig.ALCHEMY_API_KEY}", body: {
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
        "nft/v2/${SConfig.ALCHEMY_API_KEY}/getContractsForOwner?owner=$wallet&pageSize=100&withMetadata=true&filters[]=AIRDROPS&filters[]=SPAM$cursor");
    return ContractAddressDto.fromJson(res.jsonBody());
  }
}
