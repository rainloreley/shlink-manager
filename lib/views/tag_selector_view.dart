import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:shlink_app/API/Classes/ShortURL/visits_summary.dart';
import 'package:shlink_app/API/Classes/Tag/tag_with_stats.dart';
import 'package:shlink_app/util/build_api_error_snackbar.dart';
import 'package:shlink_app/util/string_to_color.dart';
import '../globals.dart' as globals;

class TagSelectorView extends StatefulWidget {
  const TagSelectorView({super.key, this.alreadySelectedTags = const []});

  final List<String> alreadySelectedTags;

  @override
  State<TagSelectorView> createState() => _TagSelectorViewState();
}

class _TagSelectorViewState extends State<TagSelectorView> {
  final FocusNode searchTagFocusNode = FocusNode();
  final searchTagController = TextEditingController();

  List<TagWithStats> availableTags = [];
  List<TagWithStats> selectedTags = [];
  List<TagWithStats> filteredTags = [];

  bool tagsLoaded = false;

  @override
  void initState() {
    super.initState();
    selectedTags = [];
    searchTagController.text = "";
    filteredTags = [];
    searchTagFocusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadTags());
  }

  @override
  void dispose() {
    searchTagFocusNode.dispose();
    searchTagController.dispose();
    super.dispose();
  }

  Future<void> loadTags() async {
    final response = await globals.serverManager.getTags();
    response.fold((l) {
      List<TagWithStats> mappedAlreadySelectedTags =
          widget.alreadySelectedTags.map((e) {
        return l.firstWhere((t) => t.tag == e, orElse: () {
          // account for newly created tags
          return TagWithStats(e, 0, VisitsSummary(0, 0, 0));
        });
      }).toList();

      setState(() {
        availableTags = (l + [...mappedAlreadySelectedTags]).toSet().toList();
        selectedTags = [...mappedAlreadySelectedTags];
        filteredTags = availableTags;
        tagsLoaded = true;
      });

      _sortLists();
      return true;
    }, (r) {
      ScaffoldMessenger.of(context)
          .showSnackBar(buildApiErrorSnackbar(r, context));
      return false;
    });
  }

  void _sortLists() {
    setState(() {
      availableTags.sort((a, b) => a.tag.compareTo(b.tag));
      filteredTags.sort((a, b) => a.tag.compareTo(b.tag));
    });
  }

  void _searchTextChanged(String text) {
    if (text == "") {
      setState(() {
        filteredTags = availableTags;
      });
    } else {
      setState(() {
        filteredTags = availableTags
            .where((t) => t.tag.toLowerCase().contains(text.toLowerCase()))
            .toList();
      });
    }
    _sortLists();
  }

  void _addNewTag(String tag) {
    bool tagExists =
        availableTags.where((t) => t.tag == tag).toList().isNotEmpty;
    if (tag != "" && !tagExists) {
      TagWithStats tagWithStats = TagWithStats(tag, 0, VisitsSummary(0, 0, 0));
      setState(() {
        availableTags.add(tagWithStats);
        selectedTags.add(tagWithStats);
        _searchTextChanged(tag);
      });
      _sortLists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: searchTagController,
            focusNode: searchTagFocusNode,
            onChanged: _searchTextChanged,
            decoration: const InputDecoration(
              hintText: "Start typing...",
              border: InputBorder.none,
              icon: Icon(Icons.label_outline),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context, selectedTags.map((t) => t.tag).toList());
              },
              icon: const Icon(Icons.check),
            )
          ],
        ),
        body: CustomScrollView(
          slivers: [
            if (!tagsLoaded)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              )
            else if (tagsLoaded && availableTags.isEmpty)
              SliverToBoxAdapter(
                  child: Center(
                      child: Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Column(
                            children: [
                              const Text(
                                "No Tags",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Start typing to add new tags!',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary),
                                ),
                              )
                            ],
                          ))))
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  bool _isSelected = selectedTags.contains(filteredTags[index]);
                  TagWithStats _tag = filteredTags[index];
                  return GestureDetector(
                      onTap: () {
                        if (_isSelected) {
                          setState(() {
                            selectedTags.remove(_tag);
                          });
                        } else {
                          setState(() {
                            selectedTags.add(_tag);
                          });
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            color: _isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            border: Border(
                                bottom: BorderSide(
                                    color: Theme.of(context).dividerColor)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                spacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        color: stringToColor(_tag.tag)
                                            .harmonizeWith(Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                  Text(_tag.tag)
                                ],
                              ),
                              Text(
                                "${_tag.shortUrlsCount} short URL"
                                "${_tag.shortUrlsCount == 1 ? "" : "s"}",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                    fontSize: 12),
                              )
                            ],
                          )));
                }, childCount: filteredTags.length),
              ),
            if (searchTagController.text != "" &&
                !availableTags.contains(searchTagController.text))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8, bottom: 8, left: 16, right: 16),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        _addNewTag(searchTagController.text);
                      },
                      child: Text('Add tag "${searchTagController.text}"'),
                    ),
                  ),
                ),
              )
          ],
        ));
  }
}
