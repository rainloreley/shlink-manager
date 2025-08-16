import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeSelectorController {
  static final DateFormat dateTimeFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');

  late DateTime? Function() _getDateTime;

  DateTime? get dateTime => _getDateTime();

  String? get dateTimeString {
    if (dateTime != null) {
      //Converts time to UTC and adds mandatory suffix
      return "${dateTimeFormat.format(dateTime!.toUtc())}+00:00";
    }
    return null;
  }
}

class DateTimeSelector extends StatefulWidget {
  const DateTimeSelector({
    super.key,
    required this.dateTimeSelectorController,
    required this.displayName,
    this.date,
  });

  static const IconData dateSetIcon = Icons.calendar_month;
  static const IconData dateUnsetIcon = Icons.calendar_today;

  final String displayName;
  final DateTimeSelectorController dateTimeSelectorController;

  final DateTime? date;

  @override
  State<DateTimeSelector> createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  final TextEditingController _controller = TextEditingController();

  DateTime? _dateTime;

  late bool isDateSet;

  @override
  void initState() {
    _dateTime = widget.date;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.dateTimeSelectorController._getDateTime = _getDateTime;

    isDateSet = _dateTime != null;

    if (isDateSet) {
      _controller.text = DateFormat('yyyy.MM.dd HH:mm').format(_dateTime!);
    } else {
      _controller.clear();
    }

    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(context),
            child: TextField(
              enabled: false,
              controller: _controller,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                )),
                label: Row(
                  children: [
                    Icon(
                      isDateSet
                          ? DateTimeSelector.dateSetIcon
                          : DateTimeSelector.dateUnsetIcon,
                    ),
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
        ),
        IconButton(
          onPressed: () => _selectDate(context),
          icon: Icon(
            isDateSet
                ? DateTimeSelector.dateSetIcon
                : DateTimeSelector.dateUnsetIcon,
          ),
          color: isDateSet ? Theme.of(context).colorScheme.primary : null,
        ),
      ],
    );
  }

  DateTime? _getDateTime() {
    return _dateTime;
  }

  void _selectDate(BuildContext context) async {
    //Opening a date picker dialog
    final result = await showDatePicker(
      context: context,
      initialDate: _dateTime ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    ).then((DateTime? dateSelected) async {
      //If context isn't mounted or date selection was cancelled,
      // return null
      if (dateSelected == null || !context.mounted) return null;

      final initialTime = _dateTime != null
          ? TimeOfDay(
              hour: _dateTime!.hour,
              minute: _dateTime!.minute,
            )
          : TimeOfDay.now();

      //Opening a time picker dialog
      final DateTime? result = await showTimePicker(
        context: context,
        initialTime: initialTime,
      ).then((TimeOfDay? timeSelected) {
        late DateTime dateTimeSelected;

        // If time was selected, set the date and time
        if (timeSelected != null && context.mounted) {
          dateTimeSelected = DateTime(
            dateSelected.year,
            dateSelected.month,
            dateSelected.day,
            timeSelected.hour,
            timeSelected.minute,
          );
        }

        return dateTimeSelected;
      });

      return result;
    });

    setState(() {
      _dateTime = result;
    });
  }
}
