import 'package:flutter/material.dart';
import 'package:shlink_app/API/server_manager.dart';

SnackBar buildApiErrorSnackbar(Failure r, BuildContext context) {
  var text = "";

  if (r is RequestFailure) {
    text = r.description;
  } else {
    text = (r as ApiFailure).detail;
    if ((r).invalidElements != null) {
      text = "$text: ${(r).invalidElements}";
    }
  }

  final snackBar = SnackBar(
      content: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onError)),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating);

  return snackBar;
}