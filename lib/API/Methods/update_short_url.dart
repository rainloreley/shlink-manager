import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShortURL/short_url.dart';
import 'package:shlink_app/API/Classes/ShortURLSubmission/short_url_submission.dart';
import '../server_manager.dart';

/// Updates an existing short URL
FutureOr<Either<ShortURL, Failure>> apiUpdateShortUrl(ShortURLSubmission shortUrl, String? apiKey, String? serverUrl, String apiVersion) async {
  String shortCode = shortUrl.customSlug ?? "";
  if (shortCode == "") {
    return right(RequestFailure(0, "Missing short code"));
  }
  Map<String, dynamic> shortUrlData = shortUrl.toJson();
  shortUrlData.remove("shortCode");
  shortUrlData.remove("shortUrl");
  try {
    final response = await http.patch(Uri.parse("$serverUrl/rest/v$apiVersion/short-urls/$shortCode"),
    headers: {
      "X-Api-Key": apiKey ?? "",
    },
    body: jsonEncode(shortUrlData));

    if (response.statusCode == 200) {
      // get returned short url
      var jsonBody = jsonDecode(response.body);
      return left(ShortURL.fromJson(jsonBody));
    } else {
      try {
        var jsonBody = jsonDecode(response.body);
        return right(ApiFailure(
            type: jsonBody["type"],
            detail: jsonBody["detail"],
            title: jsonBody["title"],
            status: jsonBody["status"],
            invalidElements: jsonBody["invalidElements"]));
      } catch (resErr) {
        return right(RequestFailure(response.statusCode, resErr.toString()));
      }
    }
  } catch (reqErr) {
    return right(RequestFailure(0, reqErr.toString()));
  }
}