import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../server_manager.dart';

/// Tries to connect to the Shlink server
FutureOr<Either<String, Failure>> apiConnect(String? apiKey, String? serverUrl, String apiVersion) async {
  try {
    final response = await http.get(Uri.parse("$serverUrl/rest/v$apiVersion/short-urls"), headers: {
      "X-Api-Key": apiKey ?? "",
    });
    if (response.statusCode == 200) {
      return left("");
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