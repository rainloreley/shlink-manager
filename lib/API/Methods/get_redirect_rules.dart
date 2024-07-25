import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShortURL/RedirectRule/redirect_rule.dart';
import '../server_manager.dart';

/// Gets redirect rules for a given short URL (code).
FutureOr<Either<List<RedirectRule>, Failure>> apiGetRedirectRules(
    String shortCode,
    String? apiKey,
    String? serverUrl,
    String apiVersion) async {
  try {
    final response = await http.get(
        Uri.parse(
            "$serverUrl/rest/v$apiVersion/short-urls/$shortCode/redirect-rules"),
        headers: {
          "X-Api-Key": apiKey ?? "",
        });
    if (response.statusCode == 200) {
      // get returned redirect rules
      var jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

      // convert json array to object array
      List<RedirectRule> redirectRules =
          (jsonBody["redirectRules"] as List<dynamic>)
              .map((e) => RedirectRule.fromJson(e))
              .toList();

      return left(redirectRules);
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
