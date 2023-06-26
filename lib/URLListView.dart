import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shlink_app/API/Classes/ShortURL.dart';
import 'package:shlink_app/API/ServerManager.dart';
import 'globals.dart' as globals;

class URLListView extends StatefulWidget {
  const URLListView({Key? key}) : super(key: key);

  @override
  State<URLListView> createState() => _URLListViewState();
}

class _URLListViewState extends State<URLListView> {

  List<ShortURL> shortUrls = [];
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadAllShortUrls());
  }



  void loadAllShortUrls() async {
    final response = await globals.serverManager.getShortUrls();
    response.fold((l) {
      setState(() {
        shortUrls = l;
      });
    }, (r) {
      var text = "";
      if (r is RequestFailure) {
        text = r.description;
      }
      else {
        text = (r as ApiFailure).detail;
      }

      final snackBar = SnackBar(content: Text(text), behavior: SnackBarBehavior.floating);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text("All short URLs", style: TextStyle(fontWeight: FontWeight.bold))
          ),
          SliverList(delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final shortURL = shortUrls[index];
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("${shortURL.title ?? shortURL.shortCode}", textScaleFactor: 1.4, style: TextStyle(fontWeight: FontWeight.bold),),
                                Text("${shortURL.longUrl}",maxLines: 1, overflow: TextOverflow.ellipsis, textScaleFactor: 0.9, style: TextStyle(color: Colors.grey[600]),)
                              ],
                            ),
                          ),
                          IconButton(onPressed: () {

                          }, icon: Icon(Icons.qr_code))
                        ],
                      )
                    ),
                  ),
                );
              },
            childCount: shortUrls.length
          ))
        ],
      ),
    );
  }
}
