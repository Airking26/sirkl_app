import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class ChatsService extends GetConnect{
  Future<Response<Map<String, dynamic>>> createInbox(String accessToken, String inboxCreationDTO) => post('${con.URL_SERVER}inbox/create', inboxCreationDTO, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> modifyInbox(String accessToken,String id, String inboxModificationDTO) => patch('${con.URL_SERVER}inbox/$id', inboxModificationDTO, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> clearUnreadMessages(String accessToken,String id) => patch('${con.URL_SERVER}inbox/clear/$id', {} , headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> retrieveInboxes(String accessToken, String offset) => get('${con.URL_SERVER}inbox/retrieve/$offset', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> searchInInboxes(String accessToken, String substring) => get('${con.URL_SERVER}inbox/search/$substring', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> bulkPeerMessage(String accessToken, String inboxCreationDTO) => post('${con.URL_SERVER}inbox/bulk', inboxCreationDTO, headers: {'Authorization':'Bearer $accessToken'});
}