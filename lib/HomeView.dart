import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            expandedHeight: 160,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Shlink", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(globals.serverManager.getServerUrl(), style: TextStyle(fontSize: 16, color: Colors.grey[600]))
              ],
            ),
          )
        ],
      ),
    );
  }
}
