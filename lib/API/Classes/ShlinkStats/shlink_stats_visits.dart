/// Visitor data
class ShlinkStatsVisits {
  /// Count of URL visits
  int total;

  /// Count of URL visits from humans
  int nonBots;

  /// Count of URL visits from bots/crawlers
  int bots;

  ShlinkStatsVisits(this.total, this.nonBots, this.bots);

  /// Converts the JSON data from the API to an instance of [ShlinkStatsVisits]
  ShlinkStatsVisits.fromJson(Map<String, dynamic> json)
      : total = json["total"],
        nonBots = json["nonBots"],
        bots = json["bots"];
}
