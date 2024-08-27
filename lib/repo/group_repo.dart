import 'package:sirkl/networks/request.dart';

import '../common/model/admin_dto.dart';
import '../common/model/contract_creator_dto.dart';
import '../common/model/group_creation_dto.dart';
import '../common/model/group_dto.dart';
import '../config/s_config.dart';
import '../networks/urls.dart';

class GroupRepo {
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
        "api?module=contract&action=getcontractcreation&contractaddresses=$contract&apikey=${SConfig.ethScanApiKey}");
    try {
      return ContractCreatorDto.fromJson(res.jsonBody());
    } catch (err) {
      return null;
    }
  }

  static Future<void> createGroup(GroupCreationDto groupCreationDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(url: SUrls.groupCreate, body: groupCreationDto.toJson());
  }

  static Future<void> changeAdminRole(AdminDto adminDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(url: SUrls.userAdminRole, body: adminDto.toJson());
  }

  static Future<void> addUserToSirklClub(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.userAddSirklClub(id));
  }
}
