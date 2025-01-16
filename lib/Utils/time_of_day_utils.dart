import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeOfDayUtils {
  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String dateTimeToString(DateTime date) {
    final DateTime onlyDate = DateTime(date.year, date.month, date.day);
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(onlyDate);
  }
}