import 'package:flutter/material.dart';
import '/Utils/time_of_day_utils.dart';

class DateSelector extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateSelector({
    super.key,
    required this.initialDate,
    this.firstDate,
    required this.onDateChanged,
  });

  @override
  DateSelectorState createState() => DateSelectorState();
}

class DateSelectorState extends State<DateSelector> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      widget.onDateChanged(pickedDate);
    }
  }

  void _changeDate(int days) {
    final updatedDate = selectedDate.add(Duration(days: days));
    if (widget.firstDate == null || updatedDate.isAfter(widget.firstDate!)) {
      setState(() {
        selectedDate = updatedDate;
      });
      widget.onDateChanged(updatedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = widget.firstDate == null || selectedDate.isAfter(widget.firstDate!);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: canGoBack ? () => _changeDate(-1) : null,
        ),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Row(
            children: [
              Text(
                TimeOfDayUtils.dateTimeToString(selectedDate),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_right),
          onPressed: () => _changeDate(1),
        ),
      ],
    );
  }
}

