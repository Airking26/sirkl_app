import 'dart:ffi';

import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class HomeService extends GetConnect{

  Future<Response<Map<String, dynamic>>> signUp(String signUpDTO) => post('${con.URL_SERVER}auth/signUp', signUpDTO);
  Future<Response<Map<String, dynamic>>> signIn(String signInDTO) => post('${con.URL_SERVER}auth/signIn', signInDTO);
  Future<Response<String>> isUserExists(String wallet) => get('${con.URL_SERVER}auth/availability/wallet/$wallet');
  Future<Response<Map<String, dynamic>>> refreshToken(String refreshToken) => get('${con.URL_SERVER}auth/refresh', headers: {'Refresh': refreshToken});
  Future<Response<Map<String, dynamic>>> uploadFCMToken(String accessToken, String updateFcmdto) => put('${con.URL_SERVER}user/me/fcm', updateFcmdto, headers: {'Authorization':'Bearer $accessToken'});

}