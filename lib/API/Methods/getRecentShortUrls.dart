import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShortURL/ShortURL.dart';
import '../ServerManager.dart';

FutureOr<Either<List<ShortURL>, Failure>> API_getRecentShortUrls(String? api_key, String? server_url, String apiVersion) async {
  try {
    final response = await http.get(Uri.parse("${server_url}/rest/v${apiVersion}/short-urls?itemsPerPage=5&orderBy=dateCreated-DESC"), headers: {
      "X-Api-Key": api_key ?? "",
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