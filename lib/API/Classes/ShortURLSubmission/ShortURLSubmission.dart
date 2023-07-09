import '../ShortURL/ShortURL_DeviceLongUrls.dart';

class ShortURLSubmission {
  String longUrl;
  ShortURL_DeviceLongUrls? deviceLongUrls;
  String? validSince;
  String? validUntil;
  int? maxVisits;
  List<String> tags;
  String? title;
  bool crawlable;
  bool forwardQuery;
  String? customSlug;
  bool findIfExists;
  String? domain;
  int? shortCodeLength;

  ShortURLSubmission({required this.longUrl, required this.deviceLongUrls, this.validSince, this.validUntil, this.maxVisits, required this.tags, this.title, required this.crawlable, required this.forwardQuery, this.customSlug, required this.findIfExists, this.domain, this.shortCodeLength});

  Map<String, dynamic> toJson() {
    return {
      "longUrl": longUrl,
      "deviceLongUrls": deviceLongUrls?.toJson(),
      "validSince": validSince,
      "validUntil": validUntil,
      "maxVisits": maxVisits,
      "tags": tags,
      "title": title,
      "crawlable": crawlable,
      "forwardQuery": forwardQuery,
      "customSlug": customSlug,
      "findIfExists": findIfExists,
      "domain": domain,
      "shortCodeLength": shortCodeLength
    };
  }
}