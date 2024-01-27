import 'package:flutter/material.dart';
import 'package:shlink_app/views/settings_view.dart';
import 'package:shlink_app/views/home_view.dart';
import 'package:shlink_app/views/url_list_view.dart';

class NavigationBarView extends StatefulWidget {
  const NavigationBarView({super.key});

  @override
  State<NavigationBarView> createState() => _NavigationBarViewState();
}

class _NavigationBarViewState extends State<NavigationBarView> {
  final List<Widget> views = [
    const HomeView(),
    const URLListView(),
    const SettingsView()
  ];
  int _selectedView = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: views.elementAt(_selectedView),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.link), label: "Short URLs"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings")
        ],
        selectedIndex: _selectedView,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedView = index;
          });
        },
      ),
    );
  }
}
