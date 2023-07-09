import 'package:shlink_app/API/Classes/ShortURL/ShortURL_DeviceLongUrls.dart';
import 'package:shlink_app/API/Classes/ShortURL/ShortURL_Meta.dart';
import 'package:shlink_app/API/Classes/ShortURL/ShortURL_VisitsSummary.dart';

class ShortURL {
  String shortCode;
  String shortUrl;
  String longUrl;
  ShortURL_DeviceLongUrls deviceLongUrls;
  DateTime dateCreated;
  ShortURL_VisitsSummary visitsSummary;
  List<dynamic> tags;
  ShortURL_Meta meta;
  String? domain;
  String? title;
  bool crawlable;

  ShortURL(this.shortCode, this.shortUrl, this.longUrl, this.deviceLongUrls, this.dateCreated, this.visitsSummary, this.tags, this.meta, this.domain, this.title, this.crawlable);

  ShortURL.fromJson(Map<String, dynamic> json):
      shortCode = json["shortCode"],
      shortUrl = json["shortUrl"],
      longUrl = json["longUrl"],
      deviceLongUrls = ShortURL_DeviceLongUrls.fromJson(json["deviceLongUrls"]),
      dateCreated = DateTime.parse(json["dateCreated"]),
      visitsSummary = ShortURL_VisitsSummary.fromJson(json["visitsSummary"]),
      tags = json["tags"],
      meta = ShortURL_Meta.fromJson(json["meta"]),
      domain = json["domain"],
      title = json["title"],
      crawlable = json["crawlable"];

}