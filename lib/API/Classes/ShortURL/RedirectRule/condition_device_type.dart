enum ConditionDeviceType {
  IOS,
  ANDROID,
  DESKTOP;

  static ConditionDeviceType fromApi(String api) {
    switch (api) {
      case "ios":
        return ConditionDeviceType.IOS;
      case "android":
        return ConditionDeviceType.ANDROID;
      case "desktop":
        return ConditionDeviceType.DESKTOP;
    }
    throw ArgumentError("Invalid type $api");
  }

}

extension ConditionTypeExtension on ConditionDeviceType {

  String get api {
    switch (this) {
      case ConditionDeviceType.IOS:
        return "ios";
      case ConditionDeviceType.ANDROID:
        return "android";
      case ConditionDeviceType.DESKTOP:
        return "desktop";
    }
  }
  String get humanReadable {
    switch (this) {
      case ConditionDeviceType.IOS:
        return "iOS";
      case ConditionDeviceType.ANDROID:
        return "Android";
      case ConditionDeviceType.DESKTOP:
        return "Desktop";
    }
  }
}