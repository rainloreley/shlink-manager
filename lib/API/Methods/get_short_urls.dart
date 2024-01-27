import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShortURL/short_url.dart';
import '../server_manager.dart';

/// Gets all short URLs
FutureOr<Either<List<ShortURL>, Failure>> apiGetShortUrls(String? apiKey, String? serverUrl, String apiVersion) async {
  var currentPage = 1;
  var maxPages = 2;
  List<ShortURL> allUrls = [];

  Failure? error;

  while (currentPage <= maxPages) {
    final response = await _getShortUrlPage(currentPage, apiKey, serverUrl, apiVersion);
    response.fold((l) {
      allUrls.addAll(l.urls);
      maxPages = l.totalPages;
      currentPage++;
    }, (r) {
      maxPages = 0;
      error = r;
    });
  }
  if (error == null) {
    return left(allUrls);
  }
  else {
    return right(error!);
  }
}

/// Gets all short URLs from a specific page
FutureOr<Either<ShortURLPageResponse, Failure>> _getShortUrlPage(int page, String? apiKey, String? serverUrl, String apiVersion) async {
  try {
    final response = await http.get(Uri.parse("$serverUrl/rest/v$apiVersion/short-urls?page=$page"), headers: {
      "X-Api-Key": apiKey ?? "",
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