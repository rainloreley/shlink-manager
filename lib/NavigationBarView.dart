import 'package:flutter/material.dart';
import 'package:shlink_app/HomeView.dart';
import 'package:shlink_app/URLListView.dart';

class NavigationBarView extends StatefulWidget {
  const NavigationBarView({Key? key}) : super(key: key);

  @override
  State<NavigationBarView> createState() => _NavigationBarViewState();
}

class _NavigationBarViewState extends State<NavigationBarView> {

  final List<Widget> views = [HomeView(), URLListView()];
  int _selectedView = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: views.elementAt(_selectedView),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.link), label: "Short URLs")
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
