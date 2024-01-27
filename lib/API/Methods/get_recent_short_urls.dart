import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShortURL/short_url.dart';
import '../server_manager.dart';

/// Gets recently created short URLs from the server
FutureOr<Either<List<ShortURL>, Failure>> apiGetRecentShortUrls(String? apiKey, String? serverUrl, String apiVersion) async {
  try {
    final response = await http.get(Uri.parse("$serverUrl/rest/v$apiVersion/short-urls?itemsPerPage=5&orderBy=dateCreated-DESC"), headers: {
      "X-Api-Key": apiKey ?? "",
    });
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List<ShortURL> shortURLs = (jsonResponse["shortUrls"]["data"] as List<dynamic>).map((e) {
        return ShortURL.fromJson(e);
      }).toList();
      return left(shortURLs);
    }
    else {
      try {
        var jsonBody = jsonDecode(response.body);
        return right(ApiFailure(type: jsonBody["type"], detail: jsonBody["detail"], title: jsonBody["title"], status: jsonBody["status"]));
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