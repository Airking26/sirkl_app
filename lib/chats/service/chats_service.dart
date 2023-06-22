import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class ChatsService extends GetConnect{
  Future<Response<String>> createInbox(String accessToken, String inboxCreationDTO) {

    return post('${con.URL_SERVER}inbox/create', inboxCreationDTO, headers: {'Authorization':'Bearer $accessToken', 'Accept': 'text/plain'});
  }
  Future<Response<Map<String, dynamic>>> walletsToMessages(String accessToken) => get('${con.URL_SERVER}inbox/update', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<String>> ethFromEns(String accessToken, String ens) => get('${con.URL_SERVER}inbox/eth_from_ens/$ens', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> deleteInbox(String accessToken, String id) => delete('${con.URL_SERVER}inbox/delete/$id', headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> requestToJoinGroup(String accessToken, String requestToJoinDTO) => post('${con.URL_SERVER}join/request_to_join', requestToJoinDTO,  headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<Map<String, dynamic>>> acceptDeclineRequest(String accessToken, String requestToJoinDTO) => post('${con.URL_SERVER}join/accept_decline_request', requestToJoinDTO,  headers: {'Authorization':'Bearer $accessToken'});
  Future<Response<List<dynamic>>> getRequestsWaiting(String accessToken, String channelId) => get('${con.URL_SERVER}join/requests/$channelId', headers: {'Authorization':'Bearer $accessToken'});
}