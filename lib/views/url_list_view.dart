import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shlink_app/API/Classes/ShortURL/short_url.dart';
import 'package:shlink_app/API/server_manager.dart';
import 'package:shlink_app/views/short_url_edit_view.dart';
import 'package:shlink_app/views/url_detail_view.dart';
import 'package:shlink_app/widgets/url_tags_list_widget.dart';
import '../globals.dart' as globals;
import 'package:flutter/services.dart';

class URLListView extends StatefulWidget {
  const URLListView({super.key});

  @override
  State<URLListView> createState() => _URLListViewState();
}

class _URLListViewState extends State<URLListView> {
  List<ShortURL> shortUrls = [];
  bool _qrCodeShown = false;
  String _qrUrl = "";

  bool shortUrlsLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadAllShortUrls());
  }

  Future<void> loadAllShortUrls() async {
    final response = await globals.serverManager.getShortUrls();
    response.fold((l) {
      setState(() {
        shortUrls = l;
        shortUrlsLoaded = true;
      });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ShortURLEditView()));
            loadAllShortUrls();
          },
          child: const Icon(Icons.add),
        ),
        body: Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(_qrCodeShown ? 0.4 : 0),
                  BlendMode.srcOver),
              child: RefreshIndicator(
                onRefresh: () async {
                  return loadAllShortUrls();
                },
                child: CustomScrollView(
                  slivers: [
                    const SliverAppBar.medium(
                        title: Text("Short URLs",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    if (shortUrlsLoaded && shortUrls.isEmpty)
                      SliverToBoxAdapter(
                          child: Center(
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 50),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "No Short URLs",
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Create one by tapping the "+" button below',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600]),
                                        ),
                                      )
                                    ],
                                  ))))
                    else
                      SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                        final shortURL = shortUrls[index];
                        return ShortURLCell(
                            shortURL: shortURL,
                            reload: () {
                              loadAllShortUrls();
                            },
                            showQRCode: (String url) {
                              setState(() {
                                _qrUrl = url;
                                _qrCodeShown = true;
                              });
                            },
                            isLast: index == shortUrls.length - 1);
                      }, childCount: shortUrls.length))
                  ],
                ),
              ),
            ),
            if (_qrCodeShown)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _qrCodeShown = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0),
                ),
              ),
            if (_qrCodeShown)
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.7,
                  height: MediaQuery.of(context).size.width / 1.7,
                  child: Card(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: QrImageView(
                            data: _qrUrl,
                            size: 200.0,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ))),
                ),
              )
          ],
        ));
  }
}

class ShortURLCell extends StatefulWidget {
  const ShortURLCell(
      {super.key,
      required this.shortURL,
      required this.reload,
      required this.showQRCode,
      required this.isLast});

  final ShortURL shortURL;
  final Function() reload;
  final Function(String url) showQRCode;
  final bool isLast;

  @override
  State<ShortURLCell> createState() => _ShortURLCellState();
}

class _ShortURLCellState extends State<ShortURLCell> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) =>
                      URLDetailView(shortURL: widget.shortURL)))
              .then((a) => {widget.reload()});
        },
        child: Padding(
          padding: EdgeInsets.only(
              left: 8, right: 8, bottom: widget.isLast ? 90 : 0),
          child: Container(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, bottom: 16, top: 16),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Colors.grey[800]!
                            : Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.shortURL.title ?? widget.shortURL.shortCode,
                          textScaleFactor: 1.4,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.shortURL.longUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaleFactor: 0.9,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        // List tags in a row
                        UrlTagsListWidget(tags: widget.shortURL.tags)
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: widget.shortURL.shortUrl));
                        final snackBar = SnackBar(
                            content: const Text("Copied to clipboard!"),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green[400]);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      icon: const Icon(Icons.copy)),
                  IconButton(
                      onPressed: () {
                        widget.showQRCode(widget.shortURL.shortUrl);
                      },
                      icon: const Icon(Icons.qr_code))
                ],
              )),
        ));
  }
}
