/// Data about device-specific long URLs for one short URL
class DeviceLongUrls {
  /// Custom URL for Android devices
  final String? android;

  /// Custom URL for iOS devices
  final String? ios;

  /// Custom URL for desktop
  final String? desktop;

  DeviceLongUrls(this.android, this.ios, this.desktop);

  /// Converts JSON data from the API to an instance of [DeviceLongUrls]
  DeviceLongUrls.fromJson(Map<String, dynamic> json)
      : android = json["android"],
        ios = json["ios"],
        desktop = json["desktop"];

  /// Converts data from this class to an JSON object of type
  Map<String, dynamic> toJson() =>
      {"android": android, "ios": ios, "desktop": desktop};
}
