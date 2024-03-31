import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShortURL/visits_summary.dart';
import '../Classes/ShlinkStats/shlink_stats.dart';
import '../server_manager.dart';

/// Gets statistics about the Shlink server
FutureOr<Either<ShlinkStats, Failure>> apiGetShlinkStats(
    String? apiKey, String? serverUrl, String apiVersion) async {
  VisitsSummary? nonOrphanVisits;
  VisitsSummary? orphanVisits;
  int shortUrlsCount = 0;
  int tagsCount = 0;
  Failure? failure;

  var visitStatsResponse = await _getVisitStats(apiKey, serverUrl, apiVersion);
  visitStatsResponse.fold((l) {
    nonOrphanVisits = l.nonOrphanVisits;
    orphanVisits = l.orphanVisits;
  }, (r) {
    failure = r;
    return right(r);
  });

  var shortUrlsCountResponse =
      await _getShortUrlsCount(apiKey, serverUrl, apiVersion);
  shortUrlsCountResponse.fold((l) {
    shortUrlsCount = l;
  }, (r) {
    failure = r;
    return right(r);
  });

  var tagsCountResponse = await _getTagsCount(apiKey, serverUrl, apiVersion);
  tagsCountResponse.fold((l) {
    tagsCount = l;
  }, (r) {
    failure = r;
    return right(r);
  });

  while (failure == null && (orphanVisits == null)) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  if (failure != null) {
    return right(failure!);
  }
  return left(
      ShlinkStats(nonOrphanVisits!, orphanVisits!, shortUrlsCount, tagsCount));
}

class _ShlinkVisitStats {
  VisitsSummary nonOrphanVisits;
  VisitsSummary orphanVisits;

  _ShlinkVisitStats(this.nonOrphanVisits, this.orphanVisits);
}

/// Gets visitor statistics about the entire server
FutureOr<Either<_ShlinkVisitStats, Failure>> _getVisitStats(
    String? apiKey, String? serverUrl, String apiVersion) async {
  try {
    final response = await http
        .get(Uri.parse("$serverUrl/rest/v$apiVersion/visits"), headers: {
      "X-Api-Key": apiKey ?? "",
    });
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var nonOrphanVisits =
          VisitsSummary.fromJson(jsonResponse["visits"]["nonOrphanVisits"]);
      var orphanVisits =
          VisitsSummary.fromJson(jsonResponse["visits"]["orphanVisits"]);
      return left(_ShlinkVisitStats(nonOrphanVisits, orphanVisits));
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

/// Gets amount of short URLs
FutureOr<Either<int, Failure>> _getShortUrlsCount(
    String? apiKey, String? serverUrl, String apiVersion) async {
  try {
    final response = await http
        .get(Uri.parse("$serverUrl/rest/v$apiVersion/short-urls"), headers: {
      "X-Api-Key": apiKey ?? "",
    });
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return left(jsonResponse["shortUrls"]["pagination"]["totalItems"]);
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

/// Gets amount of tags
FutureOr<Either<int, Failure>> _getTagsCount(
    String? apiKey, String? serverUrl, String apiVersion) async {
  try {
    final response = await http
        .get(Uri.parse("$serverUrl/rest/v$apiVersion/tags"), headers: {
      "X-Api-Key": apiKey ?? "",
    });
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return left(jsonResponse["tags"]["pagination"]["totalItems"]);
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
