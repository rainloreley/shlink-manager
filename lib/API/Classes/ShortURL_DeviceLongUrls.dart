import 'dart:convert';

class ShortURL_DeviceLongUrls {
  final String? android;
  final String? ios;
  final String? desktop;

  ShortURL_DeviceLongUrls(this.android, this.ios, this.desktop);

  ShortURL_DeviceLongUrls.fromJson(Map<String, dynamic> json)
    : android = json["android"],
      ios = json["ios"],
      desktop = json["desktop"];
}