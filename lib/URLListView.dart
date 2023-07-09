import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shlink_app/API/Classes/ShortURL/ShortURL.dart';
import 'package:shlink_app/API/ServerManager.dart';
import 'package:shlink_app/URLDetailView.dart';
import 'globals.dart' as globals;
import 'package:flutter/services.dart';

class URLListView extends StatefulWidget {
  const URLListView({Key? key}) : super(key: key);

  @override
  State<URLListView> createState() => _URLListViewState();
}

class _URLListViewState extends State<URLListView> {

  List<ShortURL> shortUrls = [];
  bool _qrCodeShown = false;
  String _qrUrl = "";
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadAllShortUrls());
  }

  Future<void> loadAllShortUrls() async {
    final response = await globals.serverManager.getShortUrls();
    response.fold((l) {
      setState(() {
        shortUrls = l;
      });
      return true;
    }, (r) {
      var text = "";
      if (r is RequestFailure) {
        text = r.description;
      }
      else {
        text = (r as ApiFailure).detail;
      }

      final snackBar = SnackBar(content: Text(text), backgroundColor: Colors.red[400], behavior: SnackBarBehavior.floating);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(_qrCodeShown ? 0.4 : 0), BlendMode.srcOver),
            child: RefreshIndicator(
              onRefresh: () async {
                //loadAllShortUrls();
                return loadAllShortUrls();
                //Future.value(true);
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar.medium(
                      title: Text("Short URLs", style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                  SliverList(delegate: SliverChildBuilderDelegate(
                          (BuildContext _context, int index) {
                        final shortURL = shortUrls[index];
                        return GestureDetector(
                            onTap: () async {
                              final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => URLDetailView(shortURL: shortURL)));

                              if (result == "reload") {
                                loadAllShortUrls();
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Container(
                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!)),
                                ),
                                child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text("${shortURL.title ?? shortURL.shortCode}", textScaleFactor: 1.4, style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text("${shortURL.longUrl}",maxLines: 1, overflow: TextOverflow.ellipsis, textScaleFactor: 0.9, style: TextStyle(color: Colors.grey[600]),),
                                              // List tags in a row
                                              Wrap(
                                                  children: shortURL.tags.map((tag) {
                                                    var randomColor = ([...Colors.primaries]..shuffle()).first.harmonizeWith(Theme.of(context).colorScheme.primary);
                                                    return Padding(
                                                      padding: EdgeInsets.only(right: 4, top: 4),
                                                      child: Container(
                                                        padding: EdgeInsets.only(top: 4, bottom: 4, left: 12, right: 12),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(4),
                                                          color: randomColor,
                                                        ),
                                                        child: Text(tag, style: TextStyle(color: randomColor.computeLuminance() < 0.5 ? Colors.white : Colors.black),),
                                                      ),
                                                    );
                                                  }).toList()

                                              )
                                            ],
                                          ),
                                        ),
                                        IconButton(onPressed: () async {
                                          await Clipboard.setData(ClipboardData(text: shortURL.shortUrl));
                                          final snackBar = SnackBar(content: Text("Copied to clipboard!"), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green[400]);
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }, icon: Icon(Icons.copy)),
                                        IconButton(onPressed: () {
                                          setState(() {
                                            _qrUrl = shortURL.shortUrl;
                                            _qrCodeShown = true;
                                          });
                                        }, icon: Icon(Icons.qr_code))
                                      ],
                                    )
                                ),
                              ),
                            )
                        );
                      },
                      childCount: shortUrls.length
                  ))
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
                      version: QrVersions.auto,
                      size: 200.0,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    )
                  )
                ),
              ),
            )
        ],
      )
    );
  }
}
