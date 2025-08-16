import 'package:shlink_app/API/Classes/ShortURL/visits_summary.dart';

/// Tag with stats data
class TagWithStats {
  /// Tag name
  String tag;

  /// Amount of short URLs using this tag
  int shortUrlsCount;

  /// visits summary for tag
  VisitsSummary visitsSummary;

  TagWithStats(this.tag, this.shortUrlsCount, this.visitsSummary);

  TagWithStats.fromJson(Map<String, dynamic> json)
      : tag = json["tag"] as String,
        shortUrlsCount = json["shortUrlsCount"] as int,
        visitsSummary = VisitsSummary.fromJson(json["visitsSummary"]);
}
