import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shlink_app/API/Classes/ShlinkStats/ShlinkStats.dart';
import 'package:shlink_app/API/ServerManager.dart';
import 'package:shlink_app/LoginView.dart';
import 'package:shlink_app/ShortURLEditView.dart';
import 'package:shlink_app/URLListView.dart';
import 'API/Classes/ShortURL/ShortURL.dart';
import 'globals.dart' as globals;

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  ShlinkStats? shlinkStats;

  List<ShortURL> shortUrls = [];
  bool shortUrlsLoaded = false;
  bool _qrCodeShown = false;
  String _qrUrl = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
          loadAllData();
    });
  }

  Future<void> loadAllData() async {
    var resultStats = await loadShlinkStats();
    var resultShortUrls = await loadRecentShortUrls();
    return;
  }

  Future<void> loadShlinkStats() async {
    final response = await globals.serverManager.getShlinkStats();
    response.fold((l) {
      setState(() {
        shlinkStats = l;
      });
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
    });
  }

  Future<void> loadRecentShortUrls() async {
    final response = await globals.serverManager.getRecentShortUrls();
    response.fold((l) {
      setState(() {
        shortUrls = l;
        shortUrlsLoaded = true;
      });
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
                return loadAllData();
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar.medium(
                      expandedHeight: 160,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Shlink", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(globals.serverManager.getServerUrl(), style: TextStyle(fontSize: 16, color: Colors.grey[600]))
                        ],
                      )
                  ),
                  SliverToBoxAdapter(
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        _ShlinkStatsCardWidget(icon: Icons.link, text: "${shlinkStats?.shortUrlsCount.toString() ?? "0"} Short URLs", borderColor: Colors.blue),
                        _ShlinkStatsCardWidget(icon: Icons.remove_red_eye, text: "${shlinkStats?.nonOrphanVisits.total ?? "0"} Visits", borderColor: Colors.green),
                        _ShlinkStatsCardWidget(icon: Icons.warning, text: "${shlinkStats?.orphanVisits.total ?? "0"} Orphan Visits", borderColor: Colors.red),
                        _ShlinkStatsCardWidget(icon: Icons.sell, text: "${shlinkStats?.tagsCount.toString() ?? "0"} Tags", borderColor: Colors.purple),
                      ],
                    ),
                  ),
                  if (shortUrlsLoaded && shortUrls.isEmpty)
                    SliverToBoxAdapter(
                        child: Center(
                            child: Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: Column(
                                  children: [
                                    Text("No Short URLs", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text('Create one by tapping the "+" button below', style: TextStyle(fontSize: 16, color: Colors.grey[600]),),
                                    )
                                  ],
                                )
                            )
                        )
                    )
                  else
                    SliverList(delegate: SliverChildBuilderDelegate(
                            (BuildContext _context, int index) {
                              if (index == 0) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 16, left: 12, right: 12),
                                  child: Text("Recent Short URLs", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                );
                              }
                              else {
                                final shortURL = shortUrls[index - 1];
                                return ShortURLCell(shortURL: shortURL, reload: () {
                                  loadRecentShortUrls();
                                }, showQRCode: (String url) {
                                  setState(() {
                                    _qrUrl = url;
                                    _qrCodeShown = true;
                                  });
                                }, isLast: index == shortUrls.length);
                              }
                        },
                        childCount: shortUrls.length + 1
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ShortURLEditView()));
          loadRecentShortUrls();
        },
        child: Icon(Icons.add),
      )
    );
  }
}

// stats card widget
class _ShlinkStatsCardWidget extends StatefulWidget {
  const _ShlinkStatsCardWidget({this.text, this.icon, this.borderColor});

  final icon;
  final borderColor;
  final text;

  @override
  State<_ShlinkStatsCardWidget> createState() => _ShlinkStatsCardWidgetState();
}

class _ShlinkStatsCardWidgetState extends State<_ShlinkStatsCardWidget> {
  @override
  Widget build(BuildContext context) {
    var randomColor = ([...Colors.primaries]..shuffle()).first;
    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border.all(color: widget.borderColor ?? randomColor),
              borderRadius: BorderRadius.circular(8)
          ),
          child: SizedBox(
            child: Wrap(
              children: [
                Icon(widget.icon),
                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(widget.text, style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
      ),
    );
  }
}
