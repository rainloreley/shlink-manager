import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shlink_app/util/build_api_error_snackbar.dart';
import 'package:shlink_app/views/opensource_licenses_view.dart';
import 'package:shlink_app/widgets/available_servers_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart' as globals;

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

enum ServerStatus { connected, connecting, disconnected }

class _SettingsViewState extends State<SettingsView> {
  var _serverVersion = "---";
  ServerStatus _serverStatus = ServerStatus.connecting;
  PackageInfo packageInfo =
      PackageInfo(appName: "", packageName: "", version: "", buildNumber: "");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getServerHealth());
  }

  void getServerHealth() async {
    var packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      this.packageInfo = packageInfo;
    });
    final response = await globals.serverManager.getServerHealth();
    response.fold((l) {
      setState(() {
        _serverVersion = l.version;
        _serverStatus = ServerStatus.connected;
      });
    }, (r) {
      setState(() {
        _serverStatus = ServerStatus.disconnected;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(buildApiErrorSnackbar(r, context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        const SliverAppBar.medium(
          expandedHeight: 120,
          title: Text(
            "Settings",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return const AvailableServerBottomSheet();
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              Theme.of(context).colorScheme.surfaceContainer),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.dns_outlined,
                                color: (() {
                                  switch (_serverStatus) {
                                    case ServerStatus.connected:
                                      return Colors.green;
                                    case ServerStatus.connecting:
                                      return Colors.orange;
                                    case ServerStatus.disconnected:
                                      return Colors.red;
                                  }
                                }())),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Connected to",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary)),
                                Text(globals.serverManager.getServerUrl(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Row(
                                  children: [
                                    Text("API Version: ",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary,
                                            fontWeight: FontWeight.w600)),
                                    Text(globals.serverManager.getApiVersion(),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary)),
                                    const SizedBox(width: 16),
                                    Text("Server Version: ",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary,
                                            fontWeight: FontWeight.w600)),
                                    Text(_serverVersion,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary))
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const OpenSourceLicensesView()));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              Theme.of(context).colorScheme.surfaceContainer),
                      child: const Padding(
                        padding: EdgeInsets.only(
                            left: 12, right: 12, top: 20, bottom: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.policy_outlined),
                                  SizedBox(width: 8),
                                  Text("Open Source Licenses",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Icon(Icons.chevron_right)
                            ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      var url = Uri.parse(
                          "https://github.com/rainloreley/shlink-mobile-app");
                      if (await canLaunchUrl(url)) {
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              Theme.of(context).colorScheme.surfaceContainer),
                      child: const Padding(
                        padding: EdgeInsets.only(
                            left: 12, right: 12, top: 20, bottom: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.code),
                                  SizedBox(width: 8),
                                  Text("GitHub",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Icon(Icons.chevron_right)
                            ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      var url = Uri.parse(
                          "https://wiki.abmgrt.dev/de/projects/shlink-manager/privacy");
                      if (await canLaunchUrl(url)) {
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              Theme.of(context).colorScheme.surfaceContainer),
                      child: const Padding(
                        padding: EdgeInsets.only(
                            left: 12, right: 12, top: 20, bottom: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lock),
                                  SizedBox(width: 8),
                                  Text("Privacy Policy",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Icon(Icons.chevron_right)
                            ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (packageInfo.appName != "")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, top: 4, bottom: 4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer),
                          child: Text(
                            "${packageInfo.appName}, v${packageInfo.version} (${packageInfo.buildNumber})",
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          ),
                        )
                      ],
                    )
                ],
              )),
        )
      ],
    ));
  }
}
