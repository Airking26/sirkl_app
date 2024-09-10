import 'package:sirkl/models/contract_creator_dto.dart';
import 'package:sirkl/models/group_creation_dto.dart';
import 'package:sirkl/models/group_dto.dart';
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
}
