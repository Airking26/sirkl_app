import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class CallService extends GetConnect{

  Future<Response<Map<String, dynamic>>> endCall(String accessToken, String id, String channel) => get('${con.URL_SERVER}call/end/$id/$channel' , headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> missedCallNotification(String accessToken, String id) => get('${con.URL_SERVER}call/missed_call/$id' , headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> createCall(String accessToken, String callCreationDTO) => post('${con.URL_SERVER}call/create', callCreationDTO,  headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> updateCall(String accessToken, String callModificationDTO) => patch('${con.URL_SERVER}call/update', callModificationDTO, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> retrieveCalls(String accessToken, String offset) => get('${con.URL_SERVER}call/retrieve/$offset', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> searchCalls(String accessToken, String substring) => get('${con.URL_SERVER}call/search/$substring', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> searchUser(String accessToken, String substring, String offset) => get('${con.URL_SERVER}search/users/$substring/$offset', headers: {'Authorization':'Bearer $accessToken'});

}