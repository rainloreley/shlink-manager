import 'dart:ui';

import 'package:flutter/widgets.dart';

Color stringToColor(String string) {
  int hash = 0;
  string.split('').forEach((char) {
    hash = char.codeUnitAt(0) + ((hash << 5) - hash);
  });
  var rgb = [];
  for (int i = 0; i < 3; i++) {
    var value = (hash >> (i * 8)) & 0xff;
    rgb.add(int.parse(value.toRadixString(16).padLeft(2, '0'), radix: 16));
  }
  if (rgb.length != 3) {
    return const Color(0xff000000);
  }
  return Color.fromARGB(1, rgb[0], rgb[1], rgb[2]);
}
