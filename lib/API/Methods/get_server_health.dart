import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../server_manager.dart';

/// Gets the status of the server and health information
FutureOr<Either<ServerHealthResponse, Failure>> apiGetServerHealth(
    String? apiKey, String? serverUrl, String apiVersion) async {
  try {
    final response = await http
        .get(Uri.parse("$serverUrl/rest/v$apiVersion/health"), headers: {
      "X-Api-Key": apiKey ?? "",
    });
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return left(ServerHealthResponse(
          status: jsonData["status"], version: jsonData["version"]));
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
