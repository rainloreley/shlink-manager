class ShortURL_VisitsSummary {
  int total;
  int nonBots;
  int bots;

  ShortURL_VisitsSummary(this.total, this.nonBots, this.bots);

  ShortURL_VisitsSummary.fromJson(Map<String, dynamic> json):
      total = json["total"] as int,
      nonBots = json["nonBots"] as int,
      bots = json["bots"] as int;
}