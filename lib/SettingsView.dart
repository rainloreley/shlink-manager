import 'package:flutter/material.dart';
import 'package:shlink_app/API/ServerManager.dart';
import 'package:shlink_app/LoginView.dart';
import 'package:shlink_app/OpenSourceLicensesView.dart';
import 'package:url_launcher/url_launcher.dart';
import 'globals.dart' as globals;

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

enum ServerStatus {
  connected,
  connecting,
  disconnected
}

class _SettingsViewState extends State<SettingsView> {

  var _server_version = "---";
  ServerStatus _server_status = ServerStatus.connecting;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getServerHealth());
  }

  void getServerHealth() async {
    final response = await globals.serverManager.getServerHealth();
    response.fold((l) {
      setState(() {
        _server_version = l.version;
        _server_status = ServerStatus.connected;
      });
    }, (r) {
      setState(() {
        _server_status = ServerStatus.disconnected;
      });

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            expandedHeight: 120,
            title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold),),
            actions: [
              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 0,
                      child: Text("Log out...", style: TextStyle(color: Colors.red)),
                    )
                  ];
                },
                onSelected: (value) {
                  if (value == 0) {
                    globals.serverManager.logOut().then((value) => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginView())
                    ));
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
                        color: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.grey[900],
                      ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.dns_outlined, color: (() {
                            switch (_server_status) {
                              case ServerStatus.connected:
                                return Colors.green;
                              case ServerStatus.connecting:
                                return Colors.orange;
                              case ServerStatus.disconnected:
                                return Colors.red;
                            }
                          }())),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Connected to", style: TextStyle(color: Colors.grey)),
                              Text(globals.serverManager.getServerUrl(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Row(
                                children: [
                                  Text("API Version: ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                                  Text("${globals.serverManager.getApiVersion()}", style: TextStyle(color: Colors.grey)),
                                  SizedBox(width: 16),
                                  Text("Server Version: ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                                  Text("${_server_version}", style: TextStyle(color: Colors.grey))
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const OpenSourceLicensesView())
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.grey[900],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.policy_outlined),
                                  SizedBox(width: 8),
                                  Text("Open Source Licenses", style: TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Icon(Icons.chevron_right)
                            ]
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      var url = Uri.parse("https://github.com/rainloreley/shlink-mobile-app");
                      if (await canLaunchUrl(url)) {
                      launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.grey[900],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.code),
                                  SizedBox(width: 8),
                                  Text("GitHub", style: TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Icon(Icons.chevron_right)
                            ]
                        ),
                      ),
                    ),
                  )
                ],
              )
            ),
          )
        ],
      )
    );
  }
}
