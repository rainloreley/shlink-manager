import 'package:shlink_app/API/Classes/ShlinkStats/ShlinkStats_Visits.dart';

class ShlinkStats {
  ShlinkStats_Visits nonOrphanVisits;
  ShlinkStats_Visits orphanVisits;
  int shortUrlsCount;
  int tagsCount;

  ShlinkStats(this.nonOrphanVisits, this.orphanVisits, this.shortUrlsCount, this.tagsCount);
}