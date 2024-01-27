import 'package:shlink_app/API/Classes/ShortURL/visits_summary.dart';

/// Includes data about the statistics of a Shlink instance
class ShlinkStats {
  /// Data about non-orphan visits
  VisitsSummary nonOrphanVisits;
  /// Data about orphan visits (without any valid slug assigned)
  VisitsSummary orphanVisits;
  /// Total count of all short URLs
  int shortUrlsCount;
  /// Total count all all tags
  int tagsCount;

  ShlinkStats(this.nonOrphanVisits, this.orphanVisits, this.shortUrlsCount, this.tagsCount);
}