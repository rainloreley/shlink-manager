import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShortURL/ShortURL.dart';
import '../ServerManager.dart';

FutureOr<Either<List<ShortURL>, Failure>> API_getShortUrls(String? api_key, String? server_url, String apiVersion) async {
  var _currentPage = 1;
  var _maxPages = 2;
  List<ShortURL> _allUrls = [];

  Failure? error;

  while (_currentPage <= _maxPages) {
    final response = await _getShortUrlPage(_currentPage, api_key, server_url, apiVersion);
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

FutureOr<Either<ShortURLPageResponse, Failure>> _getShortUrlPage(int page, String? api_key, String? server_url, String apiVersion) async {
  try {
    final response = await http.get(Uri.parse("${server_url}/rest/v${apiVersion}/short-urls?page=${page}"), headers: {
      "X-Api-Key": api_key ?? "",
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