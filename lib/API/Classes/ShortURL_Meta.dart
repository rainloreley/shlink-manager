class ShortURL_Meta {
  DateTime? validSince;
  DateTime? validUntil;
  int? maxVisits;

  ShortURL_Meta(this.validSince, this.validUntil, this.maxVisits);

  ShortURL_Meta.fromJson(Map<String, dynamic> json):
      validSince = json["validSince"] != null ? DateTime.parse(json["validSince"]) : null,
      validUntil = json["validUntil"] != null ? DateTime.parse(json["validUntil"]) : null,
      maxVisits = json["maxVisits"];
}