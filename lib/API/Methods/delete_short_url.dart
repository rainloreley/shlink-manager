import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../server_manager.dart';

/// Deletes a short URL from the server
FutureOr<Either<String, Failure>> apiDeleteShortUrl(String shortCode,
    String? apiKey, String? serverUrl, String apiVersion) async {
  try {
    final response = await http.delete(
        Uri.parse("$serverUrl/rest/v$apiVersion/short-urls/$shortCode"),
        headers: {
          "X-Api-Key": apiKey ?? "",
        });
    if (response.statusCode == 204) {
      // get returned short url
      return left("");
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
