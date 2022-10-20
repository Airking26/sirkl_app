import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class ChatsService extends GetConnect{
  Future<Response<Map<String, dynamic>>> createInbox(String accessToken, String inboxCreationDTO) => post('${con.URL_SERVER}inbox/create', inboxCreationDTO, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> retrieveInboxes(String accessToken, String offset) => get('${con.URL_SERVER}inbox/retrieve/$offset', headers: {'Authorization':'Bearer $accessToken'});
}