import 'package:flutter/material.dart';
import 'package:shlink_app/API/Classes/ShortURL/short_url.dart';
import 'package:intl/intl.dart';
import 'package:shlink_app/API/server_manager.dart';
import 'package:shlink_app/views/short_url_edit_view.dart';
import 'package:shlink_app/widgets/url_tags_list_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart' as globals;

class URLDetailView extends StatefulWidget {
  const URLDetailView({super.key, required this.shortURL});

  final ShortURL shortURL;

  @override
  State<URLDetailView> createState() => _URLDetailViewState();
}

class _URLDetailViewState extends State<URLDetailView> {
  ShortURL shortURL = ShortURL.empty();
  @override
  void initState() {
    super.initState();
    setState(() {
      shortURL = widget.shortURL;
    });
  }

  Future showDeletionConfirmation() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Short URL"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  const Text("You're about to delete"),
                  const SizedBox(height: 4),
                  Text(
                    shortURL.title ?? shortURL.shortCode,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  const Text("It'll be gone forever! (a very long time)")
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => {Navigator.of(context).pop()},
                  child: const Text("Cancel")),
              TextButton(
                onPressed: () async {
                  var response = await globals.serverManager
                      .deleteShortUrl(shortURL.shortCode);

                  response.fold((l) {
                    Navigator.pop(context);
                    Navigator.pop(context);

                    final snackBar = SnackBar(
                        content: const Text("Short URL deleted!"),
                        backgroundColor: Colors.green[400],
                        behavior: SnackBarBehavior.floating);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return true;
                  }, (r) {
                    var text = "";
                    if (r is RequestFailure) {
                      text = r.description;
                    } else {
                      text = (r as ApiFailure).detail;
                    }

                    final snackBar = SnackBar(
                        content: Text(text),
                        backgroundColor: Colors.red[400],
                        behavior: SnackBarBehavior.floating);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return false;
                  });
                },
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text(shortURL.title ?? shortURL.shortCode,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                  onPressed: () async {
                    ShortURL updatedUrl = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                ShortURLEditView(shortUrl: shortURL)));
                    setState(() {
                      shortURL = updatedUrl;
                    });
                  },
                  icon: const Icon(Icons.edit)),
              IconButton(
                  onPressed: () {
                    showDeletionConfirmation();
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ))
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: UrlTagsListWidget(tags: shortURL.tags)),
          ),
          _ListCell(title: "Short Code", content: shortURL.shortCode),
          _ListCell(
              title: "Short URL", content: shortURL.shortUrl, isUrl: true),
          _ListCell(title: "Long URL", content: shortURL.longUrl, isUrl: true),
          _ListCell(title: "Creation Date", content: shortURL.dateCreated),
          const _ListCell(title: "Visits", content: ""),
          _ListCell(
              title: "Total", content: shortURL.visitsSummary.total, sub: true),
          _ListCell(
              title: "Non-Bots",
              content: shortURL.visitsSummary.nonBots,
              sub: true),
          _ListCell(
              title: "Bots", content: shortURL.visitsSummary.bots, sub: true),
          const _ListCell(title: "Meta", content: ""),
          _ListCell(
              title: "Valid Since",
              content: shortURL.meta.validSince,
              sub: true),
          _ListCell(
              title: "Valid Until",
              content: shortURL.meta.validUntil,
              sub: true),
          _ListCell(
              title: "Max Visits", content: shortURL.meta.maxVisits, sub: true),
          _ListCell(title: "Domain", content: shortURL.domain),
          _ListCell(title: "Crawlable", content: shortURL.crawlable, last: true)
        ],
      ),
    );
  }
}

class _ListCell extends StatefulWidget {
  const _ListCell(
      {required this.title,
      required this.content,
      this.sub = false,
      this.last = false,
      this.isUrl = false});

  final String title;
  final dynamic content;
  final bool sub;
  final bool last;
  final bool isUrl;

  @override
  State<_ListCell> createState() => _ListCellState();
}

class _ListCellState extends State<_ListCell> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: Padding(
            padding: EdgeInsets.only(top: 16, bottom: widget.last ? 30 : 0),
            child: GestureDetector(
              onTap: () async {
                Uri? parsedUrl = Uri.tryParse(widget.content);
                if (widget.isUrl &&
                    parsedUrl != null &&
                    await canLaunchUrl(parsedUrl)) {
                  launchUrl(parsedUrl);
                }
              },
              child: Container(
                padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Colors.grey[800]!
                              : Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (widget.sub)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: SizedBox(
                              width: 20,
                              height: 6,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[700]
                                      : Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                        Text(
                          widget.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    if (widget.content is bool)
                      Icon(widget.content ? Icons.check : Icons.close,
                          color: widget.content ? Colors.green : Colors.red)
                    else if (widget.content is int)
                      Text(widget.content.toString())
                    else if (widget.content is String)
                      Expanded(
                        child: Text(
                          widget.content,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                    else if (widget.content is DateTime)
                      Text(DateFormat('yyyy-MM-dd - HH:mm')
                          .format(widget.content))
                    else
                      const Text("N/A")
                  ],
                ),
              ),
            )));
  }
}
