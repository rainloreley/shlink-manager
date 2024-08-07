import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shlink_app/API/Classes/ShlinkStats/shlink_stats.dart';
import 'package:shlink_app/API/Classes/ShortURL/RedirectRule/redirect_rule.dart';
import 'package:shlink_app/API/Classes/ShortURL/short_url.dart';
import 'package:shlink_app/API/Classes/ShortURLSubmission/short_url_submission.dart';
import 'package:shlink_app/API/Classes/Tag/tag_with_stats.dart';
import 'package:shlink_app/API/Methods/connect.dart';
import 'package:shlink_app/API/Methods/get_recent_short_urls.dart';
import 'package:shlink_app/API/Methods/get_redirect_rules.dart';
import 'package:shlink_app/API/Methods/get_server_health.dart';
import 'package:shlink_app/API/Methods/get_shlink_stats.dart';
import 'package:shlink_app/API/Methods/get_short_urls.dart';
import 'package:shlink_app/API/Methods/get_tags_with_stats.dart';
import 'package:shlink_app/API/Methods/set_redirect_rules.dart';
import 'package:shlink_app/API/Methods/update_short_url.dart';

import 'Methods/delete_short_url.dart';
import 'Methods/submit_short_url.dart';

class ServerManager {
  /// The URL of the Shlink server
  String? serverUrl;

  /// The API key to access the server
  String? apiKey;

  /// Current Shlink API Version used by the app
  static String apiVersion = "3";

  String getServerUrl() {
    return serverUrl ?? "";
  }

  String getApiVersion() {
    return apiVersion;
  }

  /// Checks whether the user provided information about the server
  /// (url and apikey)
  Future<bool> checkLogin() async {
    await _loadCredentials();
    return (serverUrl != null);
  }

  /// Logs out the user and removes data about the Shlink server
  Future<void> logOut(String url) async {
    const storage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();

    String? serverMapSerialized = await storage.read(key: "server_map");

    if (serverMapSerialized != null) {
      Map<String, String> serverMap =
          Map.castFrom(jsonDecode(serverMapSerialized));
      serverMap.remove(url);
      if (serverMap.isEmpty) {
        storage.delete(key: "server_map");
      } else {
        storage.write(key: "server_map", value: jsonEncode(serverMap));
      }
      if (serverUrl == url) {
        serverUrl = null;
        apiKey = null;
        prefs.remove("lastusedserver");
      }
    }
  }

  /// Returns all servers saved in the app
  Future<List<String>> getAvailableServers() async {
    const storage = FlutterSecureStorage();
    String? serverMapSerialized = await storage.read(key: "server_map");

    if (serverMapSerialized != null) {
      Map<String, String> serverMap =
          Map.castFrom(jsonDecode(serverMapSerialized));
      return serverMap.keys.toList();
    } else {
      return [];
    }
  }

  /// Loads the server credentials from [FlutterSecureStorage]
  Future<void> _loadCredentials() async {
    const storage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('first_run') ?? true) {
      await storage.deleteAll();

      prefs.setBool('first_run', false);
    } else {
      if (await _replaceDeprecatedStorageMethod()) {
        _loadCredentials();
        return;
      }

      String? serverMapSerialized = await storage.read(key: "server_map");
      String? lastUsedServer = prefs.getString("lastusedserver");

      if (serverMapSerialized != null) {
        Map<String, String> serverMap =
            Map.castFrom(jsonDecode(serverMapSerialized));
        if (lastUsedServer != null) {
          serverUrl = lastUsedServer;
          apiKey = serverMap[lastUsedServer]!;
        } else {
          List<String> availableServers = serverMap.keys.toList();
          if (availableServers.isNotEmpty) {
            serverUrl = availableServers.first;
            apiKey = serverMap[serverUrl];
            prefs.setString("lastusedserver", serverUrl!);
          }
        }
      }
    }
  }

  Future<bool> _replaceDeprecatedStorageMethod() async {
    const storage = FlutterSecureStorage();
    // deprecated data storage method, replaced because of multi-server support
    var v1DataServerurl = await storage.read(key: "shlink_url");
    var v1DataApikey = await storage.read(key: "shlink_apikey");

    if (v1DataServerurl != null && v1DataApikey != null) {
      // conversion to new data storage method
      Map<String, String> serverMap = {};
      serverMap[v1DataServerurl] = v1DataApikey;

      storage.write(key: "server_map", value: jsonEncode(serverMap));

      storage.delete(key: "shlink_url");
      storage.delete(key: "shlink_apikey");

      return true;
    } else {
      return false;
    }
  }

  /// Saves the provided server credentials to [FlutterSecureStorage]
  void _saveCredentials(String url, String apiKey) async {
    const storage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();
    String? serverMapSerialized = await storage.read(key: "server_map");
    Map<String, String> serverMap;
    if (serverMapSerialized != null) {
      serverMap = Map.castFrom(jsonDecode(serverMapSerialized));
    } else {
      serverMap = {};
    }
    serverMap[url] = apiKey;
    storage.write(key: "server_map", value: jsonEncode(serverMap));
    prefs.setString("lastusedserver", url);
  }

  /// Saves provided server credentials and tries to establish a connection
  FutureOr<Either<String, Failure>> initAndConnect(
      String url, String apiKey) async {
    // TODO: convert url to correct format
    serverUrl = url;
    this.apiKey = apiKey;
    _saveCredentials(url, apiKey);
    final result = await connect();
    result.fold((l) => null, (r) {
      logOut(url);
    });
    return result;
  }

  /// Establishes a connection to the server
  FutureOr<Either<String, Failure>> connect() async {
    _loadCredentials();
    return apiConnect(apiKey, serverUrl, apiVersion);
  }

  /// Gets all short URLs from the server
  FutureOr<Either<List<ShortURL>, Failure>> getShortUrls() async {
    return apiGetShortUrls(apiKey, serverUrl, apiVersion);
  }

  /// Gets all tags from the server
  FutureOr<Either<List<TagWithStats>, Failure>> getTags() async {
    return apiGetTagsWithStats(apiKey, serverUrl, apiVersion);
  }

  /// Gets statistics about the Shlink instance
  FutureOr<Either<ShlinkStats, Failure>> getShlinkStats() async {
    return apiGetShlinkStats(apiKey, serverUrl, apiVersion);
  }

  /// Saves a new short URL to the server
  FutureOr<Either<ShortURL, Failure>> submitShortUrl(
      ShortURLSubmission shortUrl) async {
    return apiSubmitShortUrl(shortUrl, apiKey, serverUrl, apiVersion);
  }

  FutureOr<Either<ShortURL, Failure>> updateShortUrl(
      ShortURLSubmission shortUrl) async {
    return apiUpdateShortUrl(shortUrl, apiKey, serverUrl, apiVersion);
  }

  /// Deletes a short URL from the server, identified by its slug
  FutureOr<Either<String, Failure>> deleteShortUrl(String shortCode) async {
    return apiDeleteShortUrl(shortCode, apiKey, serverUrl, apiVersion);
  }

  /// Gets health data about the server
  FutureOr<Either<ServerHealthResponse, Failure>> getServerHealth() async {
    return apiGetServerHealth(apiKey, serverUrl, apiVersion);
  }

  /// Gets recently created/used short URLs from the server
  FutureOr<Either<List<ShortURL>, Failure>> getRecentShortUrls() async {
    return apiGetRecentShortUrls(apiKey, serverUrl, apiVersion);
  }

  /// Gets redirect rules for a given short URL (code)
  FutureOr<Either<List<RedirectRule>, Failure>> getRedirectRules(
      String shortCode) async {
    return apiGetRedirectRules(shortCode, apiKey, serverUrl, apiVersion);
  }

  /// Sets redirect rules for a given short URL (code)
  FutureOr<Either<bool, Failure>> setRedirectRules(
      String shortCode, List<RedirectRule> redirectRules) async {
    return apiSetRedirectRules(
        shortCode, redirectRules, apiKey, serverUrl, apiVersion);
  }
}

/// Server response data type about a page of short URLs from the server
class ShortURLPageResponse {
  List<ShortURL> urls;
  int totalPages;

  ShortURLPageResponse(this.urls, this.totalPages);
}

/// Server response data type about a page of tags from the server
class TagsWithStatsPageResponse {
  List<TagWithStats> tags;
  int totalPages;

  TagsWithStatsPageResponse(this.tags, this.totalPages);
}

/// Server response data type about the health status of the server
class ServerHealthResponse {
  String status;
  String version;

  ServerHealthResponse({required this.status, required this.version});
}

/// Failure class, used for the API
abstract class Failure {}

/// Used when a request to a server fails
/// (due to networking issues or an unexpected response)
class RequestFailure extends Failure {
  int statusCode;
  String description;

  RequestFailure(this.statusCode, this.description);
}

/// Contains information about an error returned by the Shlink API
class ApiFailure extends Failure {
  String type;
  String detail;
  String title;
  int status;
  List<dynamic>? invalidElements;

  ApiFailure(
      {required this.type,
      required this.detail,
      required this.title,
      required this.status,
      this.invalidElements});
}
