import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class GroupService extends GetConnect{
  Future<Response<List<dynamic>>> retrieveGroups(String accessToken) => get('${con.URL_SERVER}group/retrieve', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> createGroup(String accessToken, String name, String image, String contractAddress) => post('${con.URL_SERVER}group/$name/halo/$contractAddress' , null , headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> retrieveCreatorGroup(String contract) => get("https://api.etherscan.io/api?module=contract&action=getcontractcreation&contractaddresses=$contract&apikey=V3EVCZS2JV1WG9SSB14171DEFDQYQ63QFU");
}