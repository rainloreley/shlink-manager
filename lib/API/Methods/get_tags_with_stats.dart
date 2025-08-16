import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/Tag/tag_with_stats.dart';
import '../server_manager.dart';

/// Gets all tags
FutureOr<Either<List<TagWithStats>, Failure>> apiGetTagsWithStats(
    String? apiKey, String? serverUrl, String apiVersion) async {
  var currentPage = 1;
  var maxPages = 2;
  List<TagWithStats> allTags = [];

  Failure? error;

  while (currentPage <= maxPages) {
    final response =
    await _getTagsWithStatsPage(currentPage, apiKey, serverUrl, apiVersion);
    response.fold((l) {
      allTags.addAll(l.tags);
      maxPages = l.totalPages;
      currentPage++;
    }, (r) {
      maxPages = 0;
      error = r;
    });
  }
  if (error == null) {
    return left(allTags);
  } else {
    return right(error!);
  }
}

/// Gets all tags from a specific page
FutureOr<Either<TagsWithStatsPageResponse, Failure>> _getTagsWithStatsPage(
    int page, String? apiKey, String? serverUrl, String apiVersion) async {
  try {
    final response = await http.get(
        Uri.parse("$serverUrl/rest/v$apiVersion/tags/stats?page=$page"),
        headers: {
          "X-Api-Key": apiKey ?? "",
        });
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var pagesCount = jsonResponse["tags"]["pagination"]["pagesCount"] as int;
      List<TagWithStats> tags =
        (jsonResponse["tags"]["data"] as List<dynamic>).map((e) {
          return TagWithStats.fromJson(e);
        }).toList();
      return left(TagsWithStatsPageResponse(tags, pagesCount));
    } else {
      try {
        var jsonBody = jsonDecode(response.body);
        return right(ApiFailure(
            type: jsonBody["type"],
            detail: jsonBody["detail"],
            title: jsonBody["title"],
            status: jsonBody["status"]));
      } catch (resErr) {
        return right(RequestFailure(response.statusCode, resErr.toString()));
      }
    }
  } catch (reqErr) {
    return right(RequestFailure(0, reqErr.toString()));
  }
}
