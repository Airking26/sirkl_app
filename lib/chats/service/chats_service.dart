import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class ChatsService extends GetConnect{
  Future<Response<dynamic>> createInbox(String accessToken, String inboxCreationDTO) => post('${con.URL_SERVER}inbox/create', inboxCreationDTO, headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> walletsToMessages(String accessToken) => get('${con.URL_SERVER}inbox/update', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<String>> ethFromEns(String accessToken, String ens) => get('${con.URL_SERVER}inbox/eth_from_ens/$ens', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> deleteInbox(String accessToken, String id) => delete('${con.URL_SERVER}inbox/delete/$id', headers: {'Authorization':'Bearer $accessToken'});
}