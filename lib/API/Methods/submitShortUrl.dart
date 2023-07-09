import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShortURLSubmission/ShortURLSubmission.dart';
import '../ServerManager.dart';

FutureOr<Either<String, Failure>> API_submitShortUrl(ShortURLSubmission shortUrl, String? api_key, String? server_url, String apiVersion) async {
  try {
    final response = await http.post(Uri.parse("${server_url}/rest/v${apiVersion}/short-urls"), headers: {
      "X-Api-Key": api_key ?? "",
    }, body: jsonEncode(shortUrl.toJson()));
    if (response.statusCode == 200) {
      // get returned short url
      var jsonBody = jsonDecode(response.body);
      return left(jsonBody["shortUrl"]);
    }
    else {
      try {
        var jsonBody = jsonDecode(response.body);
        return right(ApiFailure(type: jsonBody["type"], detail: jsonBody["detail"], title: jsonBody["title"], status: jsonBody["status"], invalidElements: jsonBody["invalidElements"] ?? null));
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