import '../ShortURL/device_long_urls.dart';

/// Data for a short URL which can be submitted to the server
class ShortURLSubmission {
  /// Long URL to redirect to
  String longUrl;

  /// Device-specific long URLs
  DeviceLongUrls? deviceLongUrls;

  /// Date since when this short URL is valid in ISO8601 format
  String? validSince;

  /// Date until when this short URL is valid in ISO8601 format
  String? validUntil;

  /// Amount of maximum visits allowed to this short URLs
  int? maxVisits;

  /// List of tags assigned to this short URL
  List<String> tags;

  /// Title of the page
  String? title;

  /// Whether the short URL is crawlable by web crawlers
  bool crawlable;

  /// Whether to forward query parameters
  bool forwardQuery;

  /// Custom slug (if not provided a random one will be generated)
  String? customSlug;

  /// Whether to use an existing short URL if the slug matches
  bool findIfExists;

  /// Domain to use
  String? domain;

  /// Length of the slug if a custom one is not provided
  int? shortCodeLength;

  ShortURLSubmission(
      {required this.longUrl,
      required this.deviceLongUrls,
      this.validSince,
      this.validUntil,
      this.maxVisits,
      required this.tags,
      this.title,
      required this.crawlable,
      required this.forwardQuery,
      this.customSlug,
      required this.findIfExists,
      this.domain,
      this.shortCodeLength});

  /// Converts class data to a JSON object
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
