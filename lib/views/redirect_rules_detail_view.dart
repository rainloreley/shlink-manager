import 'package:flutter/material.dart';
import 'package:shlink_app/API/Classes/ShortURL/RedirectRule/condition_device_type.dart';
import 'package:shlink_app/API/Classes/ShortURL/RedirectRule/redirect_rule_condition.dart';
import 'package:shlink_app/API/Classes/ShortURL/RedirectRule/redirect_rule_condition_type.dart';
import 'package:shlink_app/API/Classes/ShortURL/short_url.dart';
import 'package:shlink_app/util/build_api_error_snackbar.dart';
import '../globals.dart' as globals;
import '../API/Classes/ShortURL/RedirectRule/redirect_rule.dart';

class RedirectRulesDetailView extends StatefulWidget {
  const RedirectRulesDetailView({super.key, required this.shortURL});

  final ShortURL shortURL;

  @override
  State<RedirectRulesDetailView> createState() =>
      _RedirectRulesDetailViewState();
}

class _RedirectRulesDetailViewState extends State<RedirectRulesDetailView> {
  List<RedirectRule> redirectRules = [];

  bool redirectRulesLoaded = false;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadRedirectRules());
  }

  Future<void> loadRedirectRules() async {
    final response =
        await globals.serverManager.getRedirectRules(widget.shortURL.shortCode);
    response.fold((l) {
      setState(() {
        redirectRules = l;
        redirectRulesLoaded = true;
      });
      _sortListByPriority();
      return true;
    }, (r) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildApiErrorSnackbar(r, context)
      );
      return false;
    });
  }

  void _saveRedirectRules() async {
    final response = await globals.serverManager
        .setRedirectRules(widget.shortURL.shortCode, redirectRules);
    response.fold((l) {
      Navigator.pop(context);
    }, (r) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildApiErrorSnackbar(r, context)
      );
      return false;
    });
  }

  void _sortListByPriority() {
    setState(() {
      redirectRules.sort((a, b) => a.priority - b.priority);
    });
  }

  void _fixPriorities() {
    for (int i = 0; i < redirectRules.length; i++) {
      setState(() {
        redirectRules[i].priority = i + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Wrap(
        spacing: 16,
        children: [
          FloatingActionButton(
              onPressed: () {
                if (!isSaving & redirectRulesLoaded) {
                  setState(() {
                    isSaving = true;
                  });
                  _saveRedirectRules();
                }
              },
              child: isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                  : const Icon(Icons.save))
        ],
      ),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.medium(
            expandedHeight: 120,
            title: Text(
              "Redirect Rules",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (redirectRulesLoaded && redirectRules.isEmpty)
            SliverToBoxAdapter(
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            const Text(
                              "No Redirect Rules",
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Adding redirect rules will be supported soon!',
                                style: TextStyle(
                                    fontSize: 16, color: Theme.of(context).colorScheme.onSecondary),
                              ),
                            )
                          ],
                        ))))
          else
            SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
              return _ListCell(
                redirectRule: redirectRules[index],
                moveUp: index == 0
                    ? null
                    : () {
                        setState(() {
                          redirectRules[index].priority -= 1;
                          redirectRules[index - 1].priority += 1;
                        });
                        _sortListByPriority();
                      },
                moveDown: index == (redirectRules.length - 1)
                    ? null
                    : () {
                        setState(() {
                          redirectRules[index].priority += 1;
                          redirectRules[index + 1].priority -= 1;
                        });
                        _sortListByPriority();
                      },
                delete: () {
                  setState(() {
                    redirectRules.removeAt(index);
                  });
                  _fixPriorities();
                },
              );
            }, childCount: redirectRules.length))
        ],
      ),
    );
  }
}

class _ListCell extends StatefulWidget {
  const _ListCell(
      {required this.redirectRule,
      required this.moveUp,
      required this.moveDown,
      required this.delete});

  final VoidCallback? moveUp;
  final VoidCallback? moveDown;
  final VoidCallback delete;
  final RedirectRule redirectRule;

  @override
  State<_ListCell> createState() => _ListCellState();
}

class _ListCellState extends State<_ListCell> {
  String _conditionToTagString(RedirectRuleCondition condition) {
    switch (condition.type) {
      case RedirectRuleConditionType.DEVICE:
        return "Device is ${ConditionDeviceType.fromApi(condition.matchValue).humanReadable}";
      case RedirectRuleConditionType.LANGUAGE:
        return "Language is ${condition.matchValue}";
      case RedirectRuleConditionType.QUERY_PARAM:
        return "Query string contains ${condition.matchKey}=${condition.matchValue}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Container(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 16),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Theme.of(context).dividerColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("Long URL ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.redirectRule.longUrl)
                  ],
                ),
                const Text("Conditions:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        children:
                            widget.redirectRule.conditions.map((condition) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4, top: 4),
                            child: Container(
                              padding: const EdgeInsets.only(
                                  top: 4, bottom: 4, left: 12, right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color:
                                    Theme.of(context).colorScheme.tertiary,
                              ),
                              child: Text(_conditionToTagString(condition)),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
                Wrap(
                  children: [
                    IconButton(
                      disabledColor:
                          Theme.of(context).disabledColor,
                      onPressed: widget.moveUp,
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                      disabledColor:
                      Theme.of(context).disabledColor,
                      onPressed: widget.moveDown,
                      icon: const Icon(Icons.arrow_downward),
                    ),
                    IconButton(
                      onPressed: widget.delete,
                      icon: const Icon(Icons.delete, color: Colors.red),
                    )
                  ],
                )
              ],
            )));
  }
}
