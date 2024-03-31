import 'package:flutter/material.dart';

// stats card widget
class ShlinkStatsCardWidget extends StatefulWidget {
  const ShlinkStatsCardWidget(
      {super.key, required this.text, required this.icon, this.borderColor});

  final IconData icon;
  final Color? borderColor;
  final String text;

  @override
  State<ShlinkStatsCardWidget> createState() => ShlinkStatsCardWidgetState();
}

class ShlinkStatsCardWidgetState extends State<ShlinkStatsCardWidget> {
  @override
  Widget build(BuildContext context) {
    var randomColor = ([...Colors.primaries]..shuffle()).first;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border.all(color: widget.borderColor ?? randomColor),
              borderRadius: BorderRadius.circular(8)),
          child: SizedBox(
            child: Wrap(
              children: [
                Icon(widget.icon),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(widget.text,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )),
    );
  }
}
