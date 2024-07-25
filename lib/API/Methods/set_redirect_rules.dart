import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shlink_app/API/Classes/ShortURL/RedirectRule/redirect_rule.dart';
import '../server_manager.dart';

/// Saves the redirect rules for a given short URL (code).
FutureOr<Either<bool, Failure>> apiSetRedirectRules(
    String shortCode,
    List<RedirectRule> redirectRules,
    String? apiKey,
    String? serverUrl,
    String apiVersion) async {
  try {
    Map<String, dynamic> body = {};
    List<Map<String, dynamic>> redirectRulesJson = redirectRules.map((e) => e.toJson()).toList();
    body["redirectRules"] = redirectRulesJson;
    final response =
    await http.post(Uri.parse("$serverUrl/rest/v$apiVersion/short-urls/$shortCode/redirect-rules"),
        headers: {
          "X-Api-Key": apiKey ?? "",
        }, body: jsonEncode(body));
    if (response.statusCode == 200) {
      return left(true);
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