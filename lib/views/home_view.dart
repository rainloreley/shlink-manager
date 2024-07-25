import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shlink_app/API/Classes/ShlinkStats/shlink_stats.dart';
import 'package:shlink_app/API/server_manager.dart';
import 'package:shlink_app/main.dart';
import 'package:shlink_app/views/login_view.dart';
import 'package:shlink_app/views/short_url_edit_view.dart';
import 'package:shlink_app/views/url_list_view.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../API/Classes/ShortURL/short_url.dart';
import '../globals.dart' as globals;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ShlinkStats? shlinkStats;

  List<ShortURL> shortUrls = [];
  bool shortUrlsLoaded = false;
  bool _qrCodeShown = false;
  String _qrUrl = "";

  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    initializeActionProcessText();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAllData();
    });
  }

  Future<void> initializeActionProcessText() async {
    _intentDataStreamSubscription =
        FlutterSharingIntent.instance.getMediaStream().listen(_handleIntentUrl);

    FlutterSharingIntent.instance.getInitialSharing().then(_handleIntentUrl);
  }

  Future<void> _handleIntentUrl(List<SharedFile> value) async {
    String inputUrlText = value.firstOrNull?.value ?? "";
    if (await canLaunchUrlString(inputUrlText)) {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ShortURLEditView(longUrl: inputUrlText)));
      await loadAllData();
    }
  }

  Future<void> loadAllData() async {
    await loadShlinkStats();
    await loadRecentShortUrls();
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
      } else {
        text = (r as ApiFailure).detail;
      }

      final snackBar = SnackBar(
          content: Text(text),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating);
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
      } else {
        text = (r as ApiFailure).detail;
      }

      final snackBar = SnackBar(
          content: Text(text),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(_qrCodeShown ? 0.4 : 0),
                  BlendMode.srcOver),
              child: RefreshIndicator(
                onRefresh: () async {
                  return loadAllData();
                },
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar.medium(
                        automaticallyImplyLeading: false,
                        expandedHeight: 160,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Shlink",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AvailableServerBottomSheet();
                                    });
                              },
                              child: Text(globals.serverManager.getServerUrl(),
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600])),
                            )
                          ],
                        )),
                    SliverToBoxAdapter(
                      child: Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        children: [
                          _ShlinkStatsCardWidget(
                              icon: Icons.link,
                              text:
                                  "${shlinkStats?.shortUrlsCount.toString() ?? "0"} Short URLs",
                              borderColor: Colors.blue),
                          _ShlinkStatsCardWidget(
                              icon: Icons.remove_red_eye,
                              text:
                                  "${shlinkStats?.nonOrphanVisits.total ?? "0"} Visits",
                              borderColor: Colors.green),
                          _ShlinkStatsCardWidget(
                              icon: Icons.warning,
                              text:
                                  "${shlinkStats?.orphanVisits.total ?? "0"} Orphan Visits",
                              borderColor: Colors.red),
                          _ShlinkStatsCardWidget(
                              icon: Icons.sell,
                              text:
                                  "${shlinkStats?.tagsCount.toString() ?? "0"} Tags",
                              borderColor: Colors.purple),
                        ],
                      ),
                    ),
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
                        if (index == 0) {
                          return const Padding(
                            padding:
                                EdgeInsets.only(top: 16, left: 12, right: 12),
                            child: Text("Recent Short URLs",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          );
                        } else {
                          final shortURL = shortUrls[index - 1];
                          return ShortURLCell(
                              shortURL: shortURL,
                              reload: () {
                                loadRecentShortUrls();
                              },
                              showQRCode: (String url) {
                                setState(() {
                                  _qrUrl = url;
                                  _qrCodeShown = true;
                                });
                              },
                              isLast: index == shortUrls.length);
                        }
                      }, childCount: shortUrls.length + 1))
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ShortURLEditView()));
            loadRecentShortUrls();
          },
          child: const Icon(Icons.add),
        ));
  }
}

// stats card widget
class _ShlinkStatsCardWidget extends StatefulWidget {
  const _ShlinkStatsCardWidget(
      {required this.text, required this.icon, this.borderColor});

  final IconData icon;
  final Color? borderColor;
  final String text;

  @override
  State<_ShlinkStatsCardWidget> createState() => _ShlinkStatsCardWidgetState();
}

class _ShlinkStatsCardWidgetState extends State<_ShlinkStatsCardWidget> {
  @override
  Widget build(BuildContext context) {
    var randomColor = ([...Colors.primaries]..shuffle()).first;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border.all(color: widget.borderColor ?? randomColor),
              borderRadius: BorderRadius.circular(8)),
          child: SizedBox(
            child: Wrap(
              children: [
                Icon(widget.icon),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(widget.text,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )),
    );
  }
}

class AvailableServerBottomSheet extends StatefulWidget {
  const AvailableServerBottomSheet({super.key});

  @override
  State<AvailableServerBottomSheet> createState() => _AvailableServerBottomSheetState();
}

class _AvailableServerBottomSheetState extends State<AvailableServerBottomSheet> {

  List<String> availableServers = [];

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    List<String> _availableServers = await globals.serverManager.getAvailableServers();
    setState(() {
      availableServers = _availableServers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar.medium(
          expandedHeight: 120,
          automaticallyImplyLeading: false,
          title: Text(
            "Available Servers",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString("lastusedserver", availableServers[index]);
                      await Navigator.of(context)
                          .pushAndRemoveUntil(MaterialPageRoute(
                          builder: (context) =>
                              InitialPage()),
                          (Route<dynamic> route) => false);
                    },
                    child: Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Container(
                            padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 16),
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
                                Wrap(
                                  spacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(Icons.dns_outlined),
                                    Text(availableServers[index])
                                  ],
                                ),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    if (availableServers[index] == globals.serverManager.serverUrl)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(4)
                                        ),
                                      ),
                                    IconButton(
                                      onPressed: () async {
                                        globals.serverManager.logOut(availableServers[index]);
                                        if (availableServers[index] == globals.serverManager.serverUrl) {
                                          await Navigator.of(context)
                                              .pushAndRemoveUntil(MaterialPageRoute(
                                              builder: (context) =>
                                                  InitialPage()),
                                                  (Route<dynamic> route) => false);
                                        } else {
                                          Navigator.pop(context);
                                        }
                                      },
                                      icon: Icon(Icons.logout, color: Colors.red),
                                    )
                                  ],
                                )
                              ],
                            )
                        )),
                  );
                }, childCount: availableServers.length
            )),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context)
                      .push(MaterialPageRoute(
                      builder: (context) =>
                          LoginView()));
                },
                child: Text("Add server..."),
              ),
            ),
          )
        )
      ],
    );
  }
}
