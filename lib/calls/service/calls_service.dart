import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class CallService extends GetConnect{

  Future<Response<Map<String, dynamic>>> notifyCallEntering(String accessToken, String id, String channel) => get('${con.URL_SERVER}call/invite/$id/$channel' , headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> createCall(String accessToken, String callCreationDTO) => post('${con.URL_SERVER}call/create', callCreationDTO,  headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> updateCall(String accessToken, String callModificationDTO) => patch('${con.URL_SERVER}call/udpate', callModificationDTO, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> retrieveCalls(String accessToken, String offset) => get('${con.URL_SERVER}call/retrieve/$offset', headers: {'Authorization':'Bearer $accessToken'});
}