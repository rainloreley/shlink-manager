import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:shlink_app/util/string_to_color.dart';

class UrlTagsListWidget extends StatefulWidget {
  const UrlTagsListWidget({super.key, required this.tags});

  final List<String> tags;

  @override
  State<UrlTagsListWidget> createState() => _UrlTagsListWidgetState();
}

class _UrlTagsListWidgetState extends State<UrlTagsListWidget> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: widget.tags.map((tag) {
      var boxColor = stringToColor(tag)
          .harmonizeWith(Theme.of(context).colorScheme.primary);
      return Padding(
        padding: const EdgeInsets.only(right: 4, top: 4),
        child: Container(
          padding:
              const EdgeInsets.only(top: 4, bottom: 4, left: 12, right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: boxColor,
          ),
          child: Text(
            tag,
            style: TextStyle(
                color: boxColor.computeLuminance() < 0.5
                    ? Colors.white
                    : Colors.black),
          ),
        ),
      );
    }).toList());
  }
}
