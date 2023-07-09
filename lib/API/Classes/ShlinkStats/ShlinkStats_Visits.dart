class ShlinkStats_Visits {
  int total;
  int nonBots;
  int bots;

  ShlinkStats_Visits(this.total, this.nonBots, this.bots);

  ShlinkStats_Visits.fromJson(Map<String, dynamic> json)
      : total = json["total"],
        nonBots = json["nonBots"],
        bots = json["bots"];
}