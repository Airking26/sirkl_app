import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class CallService extends GetConnect{

  Future<Response<Map<String, dynamic>>> notifyCallEntering(String accessToken, String id, String channel) => get('${con.URL_SERVER}call/invite/$id/$channel' , headers: {'Authorization':'Bearer $accessToken'});
}