import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shlink_app/API/server_manager.dart';
import 'package:shlink_app/views/login_view.dart';
import 'package:shlink_app/views/opensource_licenses_view.dart';
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
      packageInfo = packageInfo;
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
        body: CustomScrollView(
      slivers: [
        SliverAppBar.medium(
          expandedHeight: 120,
          title: const Text(
            "Settings",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 0,
                    child:
                        Text("Log out...", style: TextStyle(color: Colors.red)),
                  )
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  globals.serverManager.logOut().then((value) =>
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const LoginView())));
                }
              },
            )
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[100]
                          : Colors.grey[900],
                    ),
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
                              const Text("Connected to",
                                  style: TextStyle(color: Colors.grey)),
                              Text(globals.serverManager.getServerUrl(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Row(
                                children: [
                                  const Text("API Version: ",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600)),
                                  Text(globals.serverManager.getApiVersion(),
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  const SizedBox(width: 16),
                                  const Text("Server Version: ",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600)),
                                  Text(_serverVersion,
                                      style:
                                          const TextStyle(color: Colors.grey))
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
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
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[100]
                            : Colors.grey[900],
                      ),
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
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[100]
                            : Colors.grey[900],
                      ),
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
                          "https://abmgrt.dev/shlink-manager/privacy");
                      if (await canLaunchUrl(url)) {
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[100]
                            : Colors.grey[900],
                      ),
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
                        Text(
                          "${packageInfo.appName}, v${packageInfo.version} (${packageInfo.buildNumber})",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                ],
              )),
        )
      ],
    ));
  }
}
