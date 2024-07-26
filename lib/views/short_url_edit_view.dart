import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shlink_app/API/Classes/ShortURL/short_url.dart';
import 'package:shlink_app/API/Classes/ShortURLSubmission/short_url_submission.dart';
import 'package:shlink_app/API/server_manager.dart';
import 'package:shlink_app/util/build_api_error_snackbar.dart';
import '../globals.dart' as globals;

class ShortURLEditView extends StatefulWidget {
  const ShortURLEditView({super.key, this.shortUrl, this.longUrl});

  final ShortURL? shortUrl;
  final String? longUrl;

  @override
  State<ShortURLEditView> createState() => _ShortURLEditViewState();
}

class _ShortURLEditViewState extends State<ShortURLEditView>
    with SingleTickerProviderStateMixin {
  final longUrlController = TextEditingController();
  final customSlugController = TextEditingController();
  final titleController = TextEditingController();
  final randomSlugLengthController = TextEditingController(text: "5");

  bool randomSlug = true;
  bool isCrawlable = true;
  bool forwardQuery = true;
  bool copyToClipboard = true;

  bool disableSlugEditor = false;

  String longUrlError = "";
  String randomSlugLengthError = "";

  bool isSaving = false;

  late AnimationController _customSlugDiceAnimationController;

  @override
  void initState() {
    _customSlugDiceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    loadExistingUrl();
    if (widget.longUrl != null) {
      longUrlController.text = widget.longUrl!;
    }
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

  void loadExistingUrl() {
    if (widget.shortUrl != null) {
      longUrlController.text = widget.shortUrl!.longUrl;
      isCrawlable = widget.shortUrl!.crawlable;
      // for some reason this attribute is not returned by the api
      forwardQuery = true;
      titleController.text = widget.shortUrl!.title ?? "";
      customSlugController.text = widget.shortUrl!.shortCode;
      disableSlugEditor = true;
      randomSlug = false;
    }
  }

  void _saveButtonPressed() {
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
      } else if (int.tryParse(randomSlugLengthController.text) ==
          null ||
          int.tryParse(randomSlugLengthController.text)! < 1 ||
          int.tryParse(randomSlugLengthController.text)! > 50) {
        setState(() {
          randomSlugLengthError = "invalid number";
          isSaving = false;
        });
        return;
      } else {
        _submitShortUrl();
      }
    }
  }

  void _submitShortUrl() async {
    var newSubmission = ShortURLSubmission(
        longUrl: longUrlController.text,
        tags: [],
        crawlable: isCrawlable,
        forwardQuery: forwardQuery,
        findIfExists: true,
        title: titleController.text != "" ? titleController.text : null,
        customSlug: customSlugController.text != "" && !randomSlug
            ? customSlugController.text
            : null,
        shortCodeLength:
            randomSlug ? int.parse(randomSlugLengthController.text) : null);
    dartz.Either<ShortURL, Failure> response;
    if (widget.shortUrl != null) {
      response = await globals.serverManager.updateShortUrl(newSubmission);
    } else {
      response = await globals.serverManager.submitShortUrl(newSubmission);
    }

    response.fold((l) async {
      setState(() {
        isSaving = false;
      });

      if (copyToClipboard) {
        await Clipboard.setData(ClipboardData(text: l.shortUrl));
        final snackBar = SnackBar(
            content: const Text("Copied to clipboard!"),
            backgroundColor: Colors.green[400],
            behavior: SnackBarBehavior.floating);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = SnackBar(
            content: const Text("Short URL created!"),
            backgroundColor: Colors.green[400],
            behavior: SnackBarBehavior.floating);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      Navigator.pop(context, l);

      return true;
    }, (r) {
      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        buildApiErrorSnackbar(r, context)
      );
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text("${disableSlugEditor ? "Edit" : "New"} Short URL",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 16, left: 8, right: 8),
              child: Wrap(
                runSpacing: 16,
                children: [
                  TextField(
                    controller: longUrlController,
                    decoration: InputDecoration(
                        errorText: longUrlError != "" ? longUrlError : null,
                        border: const OutlineInputBorder(),
                        label: const Row(
                          children: [
                            Icon(Icons.public),
                            SizedBox(width: 8),
                            Text("Long URL")
                          ],
                        )),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: !disableSlugEditor,
                          controller: customSlugController,
                          style: TextStyle(
                              color: randomSlug
                                  ? Theme.of(context).colorScheme.onTertiary
                                  : Theme.of(context).colorScheme.onPrimary),
                          onChanged: (_) {
                            if (randomSlug) {
                              setState(() {
                                randomSlug = false;
                              });
                            }
                          },
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              label: Row(
                                children: [
                                  const Icon(Icons.link),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${randomSlug ? "Random" : "Custom"} slug",
                                    style: TextStyle(
                                        fontStyle: randomSlug
                                            ? FontStyle.italic
                                            : FontStyle.normal),
                                  )
                                ],
                              )),
                        ),
                      ),
                      const SizedBox(width: 8),
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 3.0).animate(
                            CurvedAnimation(
                                parent: _customSlugDiceAnimationController,
                                curve: Curves.easeInOutExpo)),
                        child: IconButton(
                            onPressed: disableSlugEditor
                                ? null
                                : () {
                              if (randomSlug) {
                                _customSlugDiceAnimationController.reverse(
                                    from: 1);
                              } else {
                                _customSlugDiceAnimationController.forward(
                                    from: 0);
                              }
                              setState(() {
                                randomSlug = !randomSlug;
                              });
                            },
                            icon: Icon(
                                randomSlug ? Icons.casino : Icons.casino_outlined,
                                color: randomSlug ? Colors.green : Colors.grey)),
                      )
                    ],
                  ),
                  if (randomSlug)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Random slug length"),
                        SizedBox(
                            width: 100,
                            child: TextField(
                              controller: randomSlugLengthController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  errorText:
                                  randomSlugLengthError != "" ? "" : null,
                                  border: const OutlineInputBorder(),
                                  label: const Row(
                                    children: [
                                      Icon(Icons.tag),
                                      SizedBox(width: 8),
                                      Text("Length")
                                    ],
                                  )),
                            ))
                      ],
                    ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Row(
                          children: [
                            Icon(Icons.badge),
                            SizedBox(width: 8),
                            Text("Title")
                          ],
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Crawlable"),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Forward query params"),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Copy to clipboard"),
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
            _saveButtonPressed();
          },
          child: isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 3))
              : const Icon(Icons.save)),
    );
  }
}
