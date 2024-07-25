import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shlink_app/main.dart';
import 'package:shlink_app/views/login_view.dart';
import '../globals.dart' as globals;

class AvailableServerBottomSheet extends StatefulWidget {
  const AvailableServerBottomSheet({super.key});

  @override
  State<AvailableServerBottomSheet> createState() =>
      _AvailableServerBottomSheetState();
}

class _AvailableServerBottomSheetState
    extends State<AvailableServerBottomSheet> {
  List<String> availableServers = [];

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    List<String> availableServers =
        await globals.serverManager.getAvailableServers();
    setState(() {
      availableServers = availableServers;
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
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString("lastusedserver", availableServers[index]);
              await Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const InitialPage()),
                  (Route<dynamic> route) => false);
            },
            child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Container(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 16),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color:
                                  MediaQuery.of(context).platformBrightness ==
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
                            const Icon(Icons.dns_outlined),
                            Text(availableServers[index])
                          ],
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (availableServers[index] ==
                                globals.serverManager.serverUrl)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            IconButton(
                              onPressed: () async {
                                globals.serverManager
                                    .logOut(availableServers[index]);
                                if (availableServers[index] ==
                                    globals.serverManager.serverUrl) {
                                  await Navigator.of(context)
                                      .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const InitialPage()),
                                          (Route<dynamic> route) => false);
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.logout, color: Colors.red),
                            )
                          ],
                        )
                      ],
                    ))),
          );
        }, childCount: availableServers.length)),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Center(
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => const LoginView()));
              },
              child: const Text("Add server..."),
            ),
          ),
        ))
      ],
    );
  }
}
