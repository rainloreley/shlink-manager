import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shlink_app/API/Classes/ShlinkStats/shlink_stats.dart';
import 'package:shlink_app/util/build_api_error_snackbar.dart';
import 'package:shlink_app/views/short_url_edit_view.dart';
import 'package:shlink_app/views/url_list_view.dart';
import 'package:shlink_app/widgets/available_servers_bottom_sheet.dart';
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

  @override
  void initState() {
    super.initState();
    initializeActionProcessText();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAllData();
    });
  }

  Future<void> initializeActionProcessText() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        buildApiErrorSnackbar(r, context)
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        buildApiErrorSnackbar(r, context)
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Colors.black.withAlpha(_qrCodeShown ? 100 : 0),
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
                                      return const AvailableServerBottomSheet();
                                    });
                              },
                              child: Text(globals.serverManager.getServerUrl(),
                                  style: TextStyle(
                                      fontSize: 16, color: Theme.of(context).colorScheme.onTertiary)),
                            )
                          ],
                        )),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          spacing: 4,
                          children: [
                            Row(
                              spacing: 4,
                              children: [
                                _ShlinkStatsCardWidget(
                                  icon: Icons.link,
                                  text: "${shlinkStats?.shortUrlsCount.toString() ?? "0"} Short URLs",
                                  borderColor: Colors.blue
                                ),
                                _ShlinkStatsCardWidget(
                                  icon: Icons.remove_red_eye,
                                  text: "${shlinkStats?.nonOrphanVisits.total ?? "0"} Visits",
                                  borderColor: Colors.green
                                ),
                              ],
                            ),
                            Row(
                              spacing: 4,
                              children: [
                                _ShlinkStatsCardWidget(
                                  icon: Icons.warning,
                                  text: "${shlinkStats?.orphanVisits.total ?? "0"} Orphan Visits",
                                  borderColor: Colors.red
                                ),
                                _ShlinkStatsCardWidget(
                                  icon: Icons.sell,
                                  text: "${shlinkStats?.tagsCount.toString() ?? "0"} Tags",
                                  borderColor: Colors.purple
                                ),
                              ],
                            ),
                          ],
                          ),
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
                                              color: Theme.of(context).colorScheme.onSecondary),
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
                  color: Colors.black.withAlpha(0),
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
                                  Theme.of(context).colorScheme.onPrimary
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color:
                              Theme.of(context).colorScheme.onPrimary
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
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: widget.borderColor ?? randomColor),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
