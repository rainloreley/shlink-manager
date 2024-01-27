/// Visitor data
class VisitsSummary {
  /// Count of total visits
  int total;

  /// Count of visits from humans
  int nonBots;

  /// Count of visits from bots/crawlers
  int bots;

  VisitsSummary(this.total, this.nonBots, this.bots);

  /// Converts JSON data from the API to an instance of [VisitsSummary]
  VisitsSummary.fromJson(Map<String, dynamic> json)
      : total = json["total"] as int,
        nonBots = json["nonBots"] as int,
        bots = json["bots"] as int;
}
