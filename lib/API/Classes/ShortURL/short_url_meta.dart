/// Metadata for a short URL
class ShortURLMeta {
  /// The date since when this short URL has been valid
  DateTime? validSince;

  /// The data when this short URL expires
  DateTime? validUntil;

  /// Amount of maximum visits allowed to this short URL
  int? maxVisits;

  ShortURLMeta(this.validSince, this.validUntil, this.maxVisits);

  /// Converts JSON data from the API to an instance of [ShortURLMeta]
  ShortURLMeta.fromJson(Map<String, dynamic> json)
      : validSince = json["validSince"] != null
            ? DateTime.parse(json["validSince"]).toLocal()
            : null,
        validUntil = json["validUntil"] != null
            ? DateTime.parse(json["validUntil"]).toLocal()
            : null,
        maxVisits = json["maxVisits"];
}
