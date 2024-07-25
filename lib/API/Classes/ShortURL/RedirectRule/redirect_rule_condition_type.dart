enum RedirectRuleConditionType {
  DEVICE,
  LANGUAGE,
  QUERY_PARAM;

  static RedirectRuleConditionType fromApi(String api) {
    switch (api) {
      case "device":
        return RedirectRuleConditionType.DEVICE;
      case "language":
        return RedirectRuleConditionType.LANGUAGE;
      case "query-param":
        return RedirectRuleConditionType.QUERY_PARAM;
    }
    throw ArgumentError("Invalid type $api");
  }

}

extension ConditionTypeExtension on RedirectRuleConditionType {

  String get api {
    switch (this) {
      case RedirectRuleConditionType.DEVICE:
        return "device";
      case RedirectRuleConditionType.LANGUAGE:
        return "language";
      case RedirectRuleConditionType.QUERY_PARAM:
        return "query-param";
    }
  }
  String get humanReadable {
    switch (this) {
      case RedirectRuleConditionType.DEVICE:
        return "Device";
      case RedirectRuleConditionType.LANGUAGE:
        return "Language";
      case RedirectRuleConditionType.QUERY_PARAM:
        return "Query parameter";
    }
  }
}