import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shlink_app/API/Classes/ShortURLSubmission/ShortURLSubmission.dart';
import 'package:shlink_app/API/ServerManager.dart';
import 'globals.dart' as globals;

class ShortURLEditView extends StatefulWidget {
  const ShortURLEditView({super.key});

  @override
  State<ShortURLEditView> createState() => _ShortURLEditViewState();
}

class _ShortURLEditViewState extends State<ShortURLEditView> with SingleTickerProviderStateMixin {

  final longUrlController = TextEditingController();
  final customSlugController = TextEditingController();
  final titleController = TextEditingController();
  final randomSlugLengthController = TextEditingController(text: "5");

  bool randomSlug = true;
  bool isCrawlable = true;
  bool forwardQuery = true;
  bool copyToClipboard = true;

  String longUrlError = "";
  String randomSlugLengthError = "";

  bool isSaving = false;

  late AnimationController _customSlugDiceAnimationController;

  @override
  void initState() {
    _customSlugDiceAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
  }

  @override
  void dispose() {
    longUrlController.dispose();
    customSlugController.dispose();
    titleController.dispose();
    randomSlugLengthController.dispose();
    super.dispose();
  }

  void _submitShortUrl() async {
    var newSubmission = ShortURLSubmission(
        longUrl: longUrlController.text,
        deviceLongUrls: null, tags: [],
        crawlable: isCrawlable,
        forwardQuery: forwardQuery,
        findIfExists: true,
        title: titleController.text != "" ? titleController.text : null,
        customSlug: customSlugController.text != "" && !randomSlug ? customSlugController.text : null,
        shortCodeLength: randomSlug ? int.parse(randomSlugLengthController.text) : null);
    var response = await globals.serverManager.submitShortUrl(newSubmission);

    response.fold((l) async {
      setState(() {
        isSaving = false;
      });

      if (copyToClipboard) {
        await Clipboard.setData(ClipboardData(text: l));
        final snackBar = SnackBar(content: Text("Copied to clipboard!"), backgroundColor: Colors.green[400], behavior: SnackBarBehavior.floating);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else {
        final snackBar = SnackBar(content: Text("Short URL created!"), backgroundColor: Colors.green[400], behavior: SnackBarBehavior.floating);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      Navigator.pop(context);

      return true;
    }, (r) {
      setState(() {
        isSaving = false;
      });

      var text = "";

      if (r is RequestFailure) {
        text = r.description;
      }
      else {
        text = (r as ApiFailure).detail;
        if ((r as ApiFailure).invalidElements != null) {
          text = text + ": " + (r as ApiFailure).invalidElements.toString();
        }
      }

      final snackBar = SnackBar(content: Text(text), backgroundColor: Colors.red[400], behavior: SnackBarBehavior.floating);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text("New Short URL", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: longUrlController,
                    decoration: InputDecoration(
                      errorText: longUrlError != "" ? longUrlError : null,
                      border: OutlineInputBorder(),
                      label: Row(
                        children: [
                          Icon(Icons.public),
                          SizedBox(width: 8),
                          Text("Long URL")
                        ],
                      )
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customSlugController,
                          style: TextStyle(color: randomSlug ? Colors.grey : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                          onChanged: (_) {
                            if (randomSlug) setState(() {
                              randomSlug = false;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            label: Row(
                              children: [
                                Icon(Icons.link),
                                SizedBox(width: 8),
                                Text("${randomSlug ? "Random" : "Custom"} slug", style: TextStyle(fontStyle: randomSlug ? FontStyle.italic : FontStyle.normal),)
                              ],
                            )
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 3.0).animate(CurvedAnimation(parent: _customSlugDiceAnimationController, curve: Curves.easeInOutExpo)),
                        child: IconButton(
                            onPressed: () {
                              if (randomSlug) {
                                _customSlugDiceAnimationController.reverse(from: 1);
                              }
                              else {
                                _customSlugDiceAnimationController.forward(from: 0);
                              }
                              setState(() {
                                randomSlug = !randomSlug;
                              });

                            },
                            icon: Icon(randomSlug ? Icons.casino : Icons.casino_outlined, color: randomSlug ? Colors.green : Colors.grey)
                        ),
                      )
                    ],
                  ),
                  if (randomSlug)
                    SizedBox(height: 16),

                  if (randomSlug)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Random slug length"),
                        SizedBox(
                            width: 100,
                            child: TextField(
                          controller: randomSlugLengthController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            errorText: randomSlugLengthError != "" ? "" : null,
                              border: OutlineInputBorder(),
                              label: Row(
                                children: [
                                  Icon(Icons.tag),
                                  SizedBox(width: 8),
                                  Text("Length")
                                ],
                              )
                          ),
                        ))
                      ],
                    ),
                  SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Row(
                        children: [
                          Icon(Icons.badge),
                          SizedBox(width: 8),
                          Text("Title")
                        ],
                      )
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Crawlable"),
                      Switch(
                        value: isCrawlable,
                        onChanged: (_) {
                          setState(() {
                            isCrawlable = !isCrawlable;
                          });
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Forward query params"),
                      Switch(
                        value: forwardQuery,
                        onChanged: (_) {
                          setState(() {
                            forwardQuery = !forwardQuery;
                          });
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Copy to clipboard"),
                      Switch(
                        value: copyToClipboard,
                        onChanged: (_) {
                          setState(() {
                            copyToClipboard = !copyToClipboard;
                          });
                        },
                      )
                    ],
                  ),
                ],
              ),
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!isSaving) {
            setState(() {
              isSaving = true;
              longUrlError = "";
              randomSlugLengthError = "";
            });
            if (longUrlController.text == "") {
              setState(() {
                longUrlError = "URL cannot be empty";
                isSaving = false;
              });
              return;
            }
            else if (int.tryParse(randomSlugLengthController.text) == null || int.tryParse(randomSlugLengthController.text)! < 1 || int.tryParse(randomSlugLengthController.text)! > 50) {
              setState(() {
                randomSlugLengthError = "invalid number";
                isSaving = false;
              });
              return;
            }
            else {
              _submitShortUrl();
            }
          }
        },
        child: isSaving ? Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 3)) : Icon(Icons.save)
      ),
    );
  }
}
