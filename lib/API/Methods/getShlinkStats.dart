import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShlinkStats/ShlinkStats_Visits.dart';
import '../Classes/ShlinkStats/ShlinkStats.dart';
import '../ServerManager.dart';

FutureOr<Either<ShlinkStats, Failure>> API_getShlinkStats(String? api_key, String? server_url, String apiVersion) async {

  var nonOrphanVisits;
  var orphanVisits;
  var shortUrlsCount;
  var tagsCount;
  var failure;
  
  var visitStatsResponse = await _getVisitStats(api_key, server_url, apiVersion);
  visitStatsResponse.fold((l) {
    nonOrphanVisits = l.nonOrphanVisits;
    orphanVisits = l.orphanVisits;
  }, (r) {
    failure = r;
    return right(r);
  });

  var shortUrlsCountResponse = await _getShortUrlsCount(api_key, server_url, apiVersion);
  shortUrlsCountResponse.fold((l) {
    shortUrlsCount = l;
  }, (r) {
    failure = r;
    return right(r);
  });

  var tagsCountResponse = await _getTagsCount(api_key, server_url, apiVersion);
  tagsCountResponse.fold((l) {
    tagsCount = l;
  }, (r) {
    failure = r;
    return right(r);
  });

  while(failure == null && (nonOrphanVisits == null || orphanVisits == null || shortUrlsCount == null || tagsCount == null)) {
    await Future.delayed(Duration(milliseconds: 100));
  }

  if (failure != null) {
    return right(failure);
  }
  return left(ShlinkStats(nonOrphanVisits, orphanVisits, shortUrlsCount, tagsCount));
}

/*Future<tuple.Tuple3<FutureOr<Either<_ShlinkVisitStats, Failure>>, FutureOr<Either<int, Failure>>, FutureOr<Either<int, Failure>>>> waiterFunction(String? api_key, String? server_url, String apiVersion) async {
  late FutureOr<Either<_ShlinkVisitStats, Failure>> visits;
  late FutureOr<Either<int, Failure>> shortUrlsCount;
  late FutureOr<Either<int, Failure>> tagsCount;

  await Future.wait([
    _getVisitStats(api_key, server_url, apiVersion).then((value) => visits = value),
    _getShortUrlsCount(api_key, server_url, apiVersion).then((value) => shortUrlsCount = value),
    _getTagsCount(api_key, server_url, apiVersion).then((value) => tagsCount = value),
  ]);

  return Future.value(tuple.Tuple3(visits, shortUrlsCount, tagsCount));

}*/

class _ShlinkVisitStats {
  ShlinkStats_Visits nonOrphanVisits;
  ShlinkStats_Visits orphanVisits;

  _ShlinkVisitStats(this.nonOrphanVisits, this.orphanVisits);
}

FutureOr<Either<_ShlinkVisitStats, Failure>> _getVisitStats(String? api_key, String? server_url, String apiVersion) async {
  try {
    final response = await http.get(Uri.parse("${server_url}/rest/v${apiVersion}/visits"), headers: {
      "X-Api-Key": api_key ?? "",
    });
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var nonOrphanVisits = ShlinkStats_Visits.fromJson(jsonResponse["visits"]["nonOrphanVisits"]);
      var orphanVisits = ShlinkStats_Visits.fromJson(jsonResponse["visits"]["orphanVisits"]);
      return left(_ShlinkVisitStats(nonOrphanVisits, orphanVisits));

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

// get short urls count
FutureOr<Either<int, Failure>> _getShortUrlsCount(String? api_key, String? server_url, String apiVersion) async {
  try {
    final response = await http.get(Uri.parse("${server_url}/rest/v${apiVersion}/short-urls"), headers: {
      "X-Api-Key": api_key ?? "",
    });
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return left(jsonResponse["shortUrls"]["pagination"]["totalItems"]);
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

// get tags count
FutureOr<Either<int, Failure>> _getTagsCount(String? api_key, String? server_url, String apiVersion) async {
  try {
    final response = await http.get(Uri.parse("${server_url}/rest/v${apiVersion}/tags"), headers: {
      "X-Api-Key": api_key ?? "",
    });
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return left(jsonResponse["tags"]["pagination"]["totalItems"]);
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