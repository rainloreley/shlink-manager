import 'package:shlink_app/API/Classes/ShortURL/RedirectRule/redirect_rule_condition.dart';

/// Single redirect rule for a short URL.
class RedirectRule {
  String longUrl;
  int priority;
  List<RedirectRuleCondition> conditions;

  RedirectRule(this.longUrl, this.priority, this.conditions);

  RedirectRule.fromJson(Map<String, dynamic> json)
    : longUrl = json["longUrl"],
      priority = json["priority"],
      conditions = (json["conditions"] as List<dynamic>).map((e)
      => RedirectRuleCondition.fromJson(e)).toList();

  Map<String, dynamic> toJson() {
    return {
      "longUrl": longUrl,
      "conditions": conditions.map((e) => e.toJson()).toList()
    };
  }
}