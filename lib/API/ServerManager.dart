import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shlink_app/API/Classes/ShlinkStats/ShlinkStats.dart';
import 'package:shlink_app/API/Classes/ShortURL/ShortURL.dart';
import 'package:shlink_app/API/Classes/ShortURLSubmission/ShortURLSubmission.dart';
import 'package:shlink_app/API/Methods/connect.dart';
import 'package:shlink_app/API/Methods/getRecentShortUrls.dart';
import 'package:shlink_app/API/Methods/getServerHealth.dart';
import 'package:shlink_app/API/Methods/getShlinkStats.dart';
import 'package:shlink_app/API/Methods/getShortUrls.dart';

import 'Methods/deleteShortUrl.dart';
import 'Methods/submitShortUrl.dart';

class ServerManager {

  String? _server_url;
  String? _api_key;

  static String apiVersion = "3";

  String getServerUrl() {
    return _server_url ?? "";
  }

  String getApiVersion() {
    return apiVersion;
  }

  Future<bool> checkLogin() async {
    await _loadCredentials();
    return (_server_url != null);
  }

  Future<void> logOut() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: "shlink_url");
    await storage.delete(key: "shlink_apikey");
  }

  Future<void> _loadCredentials() async {
    const storage = FlutterSecureStorage();
    _server_url = await storage.read(key: "shlink_url");
    _api_key = await storage.read(key: "shlink_apikey");
  }

  void _saveCredentials(String url, String apiKey) async {
    const storage = FlutterSecureStorage();
    storage.write(key: "shlink_url", value: url);
    storage.write(key: "shlink_apikey", value: apiKey);
  }

  void _removeCredentials() async {
    const storage = FlutterSecureStorage();
    storage.delete(key: "shlink_url");
    storage.delete(key: "shlink_apikey");
  }

  FutureOr<Either<String, Failure>> initAndConnect(String url, String apiKey) async {
    // TODO: convert url to correct format
    _server_url = url;
    _api_key = apiKey;
    _saveCredentials(url, apiKey);
    final result = await connect();
    result.fold((l) => null, (r) {
      _removeCredentials();
    });
    return result;
  }

  FutureOr<Either<String, Failure>> connect() async {
    _loadCredentials();
    return API_connect(_api_key, _server_url, apiVersion);
  }

  FutureOr<Either<List<ShortURL>, Failure>> getShortUrls() async {
    return API_getShortUrls(_api_key, _server_url, apiVersion);
  }

  FutureOr<Either<ShlinkStats, Failure>> getShlinkStats() async {
    return API_getShlinkStats(_api_key, _server_url, apiVersion);
  }

  FutureOr<Either<String, Failure>> submitShortUrl(ShortURLSubmission shortUrl) async {
    return API_submitShortUrl(shortUrl, _api_key, _server_url, apiVersion);
  }

  FutureOr<Either<String, Failure>> deleteShortUrl(String shortCode) async {
    return API_deleteShortUrl(shortCode, _api_key, _server_url, apiVersion);
  }

  FutureOr<Either<ServerHealthResponse, Failure>> getServerHealth() async {
    return API_getServerHealth(_api_key, _server_url, apiVersion);
  }

  FutureOr<Either<List<ShortURL>, Failure>> getRecentShortUrls() async {
    return API_getRecentShortUrls(_api_key, _server_url, apiVersion);
  }
}

class ShortURLPageResponse {
  List<ShortURL> urls;
  int totalPages;

  ShortURLPageResponse(this.urls, this.totalPages);
}

class ServerHealthResponse {
  String status;
  String version;

  ServerHealthResponse({required this.status, required this.version});
}

abstract class Failure {}

class RequestFailure extends Failure {
  int statusCode;
  String description;

  RequestFailure(this.statusCode, this.description);
}

class ApiFailure extends Failure {
  String type;
  String detail;
  String title;
  int status;
  List<dynamic>? invalidElements;

  ApiFailure({required this.type, required this.detail, required this.title, required this.status, this.invalidElements});
}