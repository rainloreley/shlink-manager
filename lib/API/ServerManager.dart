import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShortURL.dart';

class ServerManager {

  String? _server_url;
  String? _api_key;

  static String apiVersion = "3";

  String getServerUrl() {
    return _server_url ?? "";
  }

  Future<bool> checkLogin() async {
    await _loadCredentials();
    return (_server_url != null);
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
    try {
      final response = await http.get(Uri.parse("${_server_url}/rest/v${apiVersion}/short-urls"), headers: {
        "X-Api-Key": _api_key ?? "",
      });
      if (response.statusCode == 200) {
        return left("");
      }
      else {
        try {
          var jsonBody = jsonDecode(response.body);
          return right(ApiFailure(jsonBody["type"], jsonBody["detail"], jsonBody["title"], jsonBody["status"]));
        }
        catch(resErr) {
          return right(RequestFailure(response.statusCode, resErr.toString()));
        }
      }
    }
    catch(reqErr) {
      return right(RequestFailure(0, reqErr.toString()));
    }
  }

  FutureOr<Either<List<ShortURL>, Failure>> getShortUrls() async {
    var _currentPage = 1;
    var _maxPages = 2;
    List<ShortURL> _allUrls = [];

    Failure? error;

    while (_currentPage <= _maxPages) {
      final response = await _getShortUrlPage(_currentPage);
      response.fold((l) {
        _allUrls.addAll(l.urls);
        _maxPages = l.totalPages;
        _currentPage++;
      }, (r) {
        _maxPages = 0;
        error = r;
      });
    }
    if (error == null) {
      return left(_allUrls);
    }
    else {
      return right(error!);
    }
  }

  FutureOr<Either<ShortURLPageResponse, Failure>> _getShortUrlPage(int page) async {
    try {
      final response = await http.get(Uri.parse("${_server_url}/rest/v${apiVersion}/short-urls?page=${page}"), headers: {
        "X-Api-Key": _api_key ?? "",
      });
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var pagesCount = jsonResponse["shortUrls"]["pagination"]["pagesCount"] as int;
        List<ShortURL> shortURLs = (jsonResponse["shortUrls"]["data"] as List<dynamic>).map((e) {
          return ShortURL.fromJson(e);
        }).toList();
        return left(ShortURLPageResponse(shortURLs, pagesCount));
      }
      else {
        try {
          var jsonBody = jsonDecode(response.body);
          return right(ApiFailure(jsonBody["type"], jsonBody["detail"], jsonBody["title"], jsonBody["status"]));
        }
        catch(resErr) {
          return right(RequestFailure(response.statusCode, resErr.toString()));
        }
      }
    }
    catch(reqErr) {
      return right(RequestFailure(0, reqErr.toString()));
    }
  }
}

class ShortURLPageResponse {
  List<ShortURL> urls;
  int totalPages;

  ShortURLPageResponse(this.urls, this.totalPages);
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

  ApiFailure(this.type, this.detail, this.title, this.status);
}