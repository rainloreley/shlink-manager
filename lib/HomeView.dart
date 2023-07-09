import 'package:flutter/material.dart';
import 'package:shlink_app/API/Classes/ShlinkStats/ShlinkStats.dart';
import 'package:shlink_app/API/ServerManager.dart';
import 'package:shlink_app/ShortURLEditView.dart';
import 'globals.dart' as globals;

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  ShlinkStats? shlinkStats;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadShlinkStats());
  }

  void loadShlinkStats() async {
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
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShortURLEditView()));
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
