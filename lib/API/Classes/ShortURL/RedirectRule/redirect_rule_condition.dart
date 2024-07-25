import 'package:shlink_app/API/Classes/ShortURL/RedirectRule/redirect_rule_condition_type.dart';

class RedirectRuleCondition {
  RedirectRuleConditionType type;
  String matchValue;
  String? matchKey;

  RedirectRuleCondition(String type, this.matchValue, this.matchKey)
      : type = RedirectRuleConditionType.fromApi(type);

  RedirectRuleCondition.fromJson(Map<String, dynamic> json)
      : type = RedirectRuleConditionType.fromApi(json["type"]),
        matchValue = json["matchValue"],
        matchKey = json["matchKey"];

  Map<String, dynamic> toJson() {
    return {"type": type.api, "matchValue": matchValue, "matchKey": matchKey};
  }
}
