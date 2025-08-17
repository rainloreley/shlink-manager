import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CounterController {
  late int? Function() _getCount;

  int? get count => _getCount();
}

class Counter extends StatefulWidget {
  const Counter({
    super.key,
    required this.counterController,
    required this.displayName,
    required this.displayIcon,
    this.count,
  });

  static List<FilteringTextInputFormatter> numberInputFormatters = [
    FilteringTextInputFormatter.allow(RegExp("[0-9]")),
  ];

  final CounterController counterController;
  final String displayName;
  final IconData displayIcon;

  final int? count;

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  final TextEditingController _controller = TextEditingController();

  int? _count;

  @override
  void initState() {
    widget.counterController._getCount = _getCount;

    _count = widget.count;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(_count.toString());
    if (_count == 0) {
      _count = null;
      _controller.clear();
    } else if (_count != null) {
      _controller.text = _count.toString();
    }

    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: Counter.numberInputFormatters,
            onChanged: (_) => applyCounterChange(),
            onEditingComplete: applyCounterChange,
            onTapOutside: (_) => applyCounterChange(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              label: Row(
                children: [
                  Icon(widget.displayIcon),
                  const SizedBox(width: 8),
                  Text(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    widget.displayName,
                  )
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _count == null || _count! < 0 //If counter is zero or below
              ? null
              : () => _incrementCounter(increment: false),
          icon: const Icon(Icons.remove),
          color: _count == null || _count! < 0 //If counter is zero or below
              ? Theme.of(context).colorScheme.outline
              : Theme.of(context).colorScheme.primary,
        ),
        IconButton(
          onPressed: () => _incrementCounter(),
          icon: const Icon(Icons.add),
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  int? _getCount() {
    return _count;
  }

  void _incrementCounter({bool increment = true}) {
    setState(() {
      _count = (_count ?? 0) + (increment ? 1 : -1);
    });
  }

  void applyCounterChange() {
    setState(() {
      if (_controller.text == "") {
        _count = null;
      } else {
        _count = int.parse(_controller.text);
      }
    });
  }
}
