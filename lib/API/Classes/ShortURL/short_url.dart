import 'package:shlink_app/API/Classes/ShortURL/device_long_urls.dart';
import 'package:shlink_app/API/Classes/ShortURL/short_url_meta.dart';
import 'package:shlink_app/API/Classes/ShortURL/visits_summary.dart';

/// Data about a short URL
class ShortURL {
  /// Slug of the short URL used in the URL
  String shortCode;

  /// Entire short URL
  String shortUrl;

  /// Long URL where the user gets redirected to
  String longUrl;

  /// Device-specific long URLs
  DeviceLongUrls deviceLongUrls;

  /// Creation date of the short URL
  DateTime dateCreated;

  /// Visitor data
  VisitsSummary visitsSummary;

  /// List of tags assigned to this short URL
  List<String> tags;

  /// Metadata
  ShortURLMeta meta;

  /// Associated domain
  String? domain;

  /// Optional title
  String? title;

  /// Whether the short URL is crawlable by a web crawler
  bool crawlable;

  ShortURL(
      this.shortCode,
      this.shortUrl,
      this.longUrl,
      this.deviceLongUrls,
      this.dateCreated,
      this.visitsSummary,
      this.tags,
      this.meta,
      this.domain,
      this.title,
      this.crawlable);

  /// Converts the JSON data from the API to an instance of [ShortURL]
  ShortURL.fromJson(Map<String, dynamic> json)
      : shortCode = json["shortCode"],
        shortUrl = json["shortUrl"],
        longUrl = json["longUrl"],
        deviceLongUrls = DeviceLongUrls.fromJson(json["deviceLongUrls"]),
        dateCreated = DateTime.parse(json["dateCreated"]),
        visitsSummary = VisitsSummary.fromJson(json["visitsSummary"]),
        tags = (json["tags"] as List<dynamic>).map((e) => e.toString()).toList(),
        meta = ShortURLMeta.fromJson(json["meta"]),
        domain = json["domain"],
        title = json["title"],
        crawlable = json["crawlable"];
  ShortURL.empty()
    : shortCode = "",
      shortUrl = "",
      longUrl = "",
      deviceLongUrls = DeviceLongUrls("", "", ""),
      dateCreated = DateTime.now(),
      visitsSummary = VisitsSummary(0, 0, 0),
      tags = [],
      meta = ShortURLMeta(DateTime.now(), DateTime.now(), 0),
      domain = "",
      title = "",
      crawlable = false;
}
