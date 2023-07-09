import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../ServerManager.dart';

FutureOr<Either<String, Failure>> API_connect(String? api_key, String? server_url, String apiVersion) async {
  try {
    final response = await http.get(Uri.parse("${server_url}/rest/v${apiVersion}/short-urls"), headers: {
      "X-Api-Key": api_key ?? "",
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