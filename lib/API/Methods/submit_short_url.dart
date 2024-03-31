import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShortURL/short_url.dart';
import 'package:shlink_app/API/Classes/ShortURLSubmission/short_url_submission.dart';
import '../server_manager.dart';

/// Submits a short URL to a server for it to be added
FutureOr<Either<ShortURL, Failure>> apiSubmitShortUrl(
    ShortURLSubmission shortUrl,
    String? apiKey,
    String? serverUrl,
    String apiVersion) async {
  try {
    final response =
        await http.post(Uri.parse("$serverUrl/rest/v$apiVersion/short-urls"),
            headers: {
              "X-Api-Key": apiKey ?? "",
            },
            body: jsonEncode(shortUrl.toJson()));
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
