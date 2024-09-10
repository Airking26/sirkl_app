import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:sirkl/models/refresh_token_dto.dart';
import 'package:sirkl/networks/urls.dart';

import '../common/save_pref_keys.dart';

export 'package:http/http.dart';

extension ResponseConverter on Response {
  jsonBody() => jsonDecode(body);
}

class SRequests {
  static final _box = GetStorage();
  final String baseUrl;

  SRequests(this.baseUrl);

  Future<Response> post(
      {required String url, required Map<dynamic, dynamic> body}) async {
    debugPrint('Posting ${baseUrl + url}');
    final Response response = await http.post(_uriBuilder(url),
        body: jsonEncode(body), headers: await _headers);

    handleError(response);

    return response;
  }

  Future<Response> put(
      {required String url, required Map<dynamic, dynamic>? body}) async {
    final Response response = await http.put(_uriBuilder(url),
        body: jsonEncode(body ?? {}), headers: await _headers);

    handleError(response);

    return response;
  }

  Future<Response> patch(
      {required String url, required Map<dynamic, dynamic>? body}) async {
    final Response response = await http.patch(_uriBuilder(url),
        body: jsonEncode(body ?? {}), headers: await _headers);

    handleError(response);

    return response;
  }

  Future<Response> delete({required String url}) async {
    debugPrint('Calling ${_uriBuilder(url).toString()}');
    final Response response =
        await http.delete(_uriBuilder(url), headers: await _headers);

    handleError(response);

    return response;
  }

  Future<Response> get(String url) async {
    debugPrint('Calling ${_uriBuilder(url).toString()}');
    final Response response =
        await http.get(_uriBuilder(url), headers: await _headers);

    handleError(response);

    return response;
  }

  Uri _uriBuilder(url) => Uri.parse(baseUrl + url);

  Map<dynamic, dynamic> _parseEachToString(Map<dynamic, dynamic> json) {
    for (String key in json.keys) {
      if (json[key].runtimeType != String) {
        if (json[key].runtimeType == List) {
          json[key].forEach((item) {
            _parseEachToString(json[key]);
          });
        }
        if (json[key].runtimeType == Map) {
          _parseEachToString(json[key]);
        }
        if (json[key].runtimeType == int || json[key].runtimeType == double) {
          json[key] = json[key].toString();
        }
      }
    }

    return json;
  }

  void handleError(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        debugPrint(jsonDecode(response.body).toString());
      } catch (err) {}
      throw HttpException(jsonDecode(response.body)['detail'].toString());
    }
  }

  get _headers async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    if (await _accessToken != null) {
      headers["Authorization"] = 'Bearer ${await _accessToken}';
    }
    return headers;
  }

  Future<String?> get _accessToken async {
    String? accessToken = _box.read(SharedPref.ACCESS_TOKEN);
    if (accessToken == null) {
      return accessToken;
    }
    if (await _isTokenValid) {
      return _box.read(SharedPref.ACCESS_TOKEN);
    }
    String? refreshToken = _box.read(SharedPref.REFRESH_TOKEN);
    if (refreshToken == null) {
      return null;
    }
    final Response response = await http.get(_uriBuilder(SUrls.refreshToken),
        headers: {'refresh': refreshToken});
    accessToken = RefreshTokenDto.fromJson(response.jsonBody()).accessToken;
    await _box.write(SharedPref.ACCESS_TOKEN, accessToken);
    await saveTokenInfo(accessToken: accessToken, refreshToken: refreshToken);
    return accessToken;
  }

  Future<bool> get _isTokenValid async {
    int? exp = _box.read(SharedPref.JWT_EXP_AT);
    if (exp == null) {
      return false;
    }
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp > currentTime;
  }

  static Future<void> saveTokenInfo(
      {required String accessToken, required String refreshToken}) async {
    await _box.write(SharedPref.ACCESS_TOKEN, accessToken);
    await _box.write(SharedPref.REFRESH_TOKEN, refreshToken);
    JWT jwt = JWT.decode(accessToken);
    Map<String, dynamic> payload = jwt.payload;
    int? exp = payload['exp'];
    if (payload.containsKey('exp')) {
      await _box.write(SharedPref.JWT_EXP_AT, exp);
    }
  }
}
