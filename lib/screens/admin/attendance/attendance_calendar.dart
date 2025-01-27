import 'package:flutter/material.dart';
import '../../../helpers/student_batch_helper.dart';
import '../../../Utils/time_of_day_utils.dart';
import '../../../helpers/attendance_helper.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceCalendar extends StatefulWidget {
  final String studentId;
  final String batchId;

  const AttendanceCalendar({
    super.key,
    required this.studentId,
    required this.batchId,
  });

  @override
  AttendanceCalendarState createState() => AttendanceCalendarState();
}

class AttendanceCalendarState extends State<AttendanceCalendar> {
  late List<DateTime> presentDays;
  late List<DateTime> absentDays;
  late List<DateTime> cancelledDays;
  DateTime? focusedMonth;
  DateTime? firstDate;

  @override
  void initState() {
    super.initState();
    presentDays = [];
    cancelledDays = [];
    absentDays = [];
    focusedMonth = DateTime.now();
    _loadAttendanceForMonth(focusedMonth!);
  }

  void _loadAttendanceForMonth(DateTime month) async {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final listOfDays = await AttendanceHelper.fetchAttendanceBetweenDatesFor(
      widget.studentId,
      widget.batchId,
      firstDayOfMonth,
      lastDayOfMonth,
    );

    final studentJoiningDate = await StudentBatchHelper.getStudentJoiningDate(
        widget.studentId, widget.batchId);

    setState(() {
      presentDays = listOfDays.first;
      absentDays = listOfDays.last;
      cancelledDays = listOfDays.elementAt(1);

      firstDate = studentJoiningDate.isBefore(firstDayOfMonth)
          ? firstDayOfMonth
          : studentJoiningDate;

      focusedMonth = focusedMonth!.isBefore(firstDate!) ? firstDate! : focusedMonth!;
      focusedMonth = DateTime(focusedMonth!.year, focusedMonth!.month, 1);

      if (focusedMonth!.isBefore(firstDate!)) {
        focusedMonth = firstDate!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: firstDate == null ? DateTime.utc(2000) : firstDate!,
      lastDay: DateTime.utc(2100),
      focusedDay: focusedMonth!,
      onPageChanged: (focusedDay) {
        focusedMonth = DateTime(focusedDay.year, focusedDay.month, 1);
        _loadAttendanceForMonth(focusedMonth!);
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          DateTime normalizedDay = TimeOfDayUtils.normalizeDate(day);

          if (TimeOfDayUtils.normalizeDate(DateTime.now()) == normalizedDay) {
            return null;
          }

          if (presentDays.any((d) => TimeOfDayUtils.normalizeDate(d) == normalizedDay)) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          } else if (absentDays.any((d) => TimeOfDayUtils.normalizeDate(d) == normalizedDay)) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }else if (cancelledDays.any((d) => TimeOfDayUtils.normalizeDate(d) == normalizedDay)) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          return null;
        },
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(fontSize: 14),
      ),
      selectedDayPredicate: (day) => TimeOfDayUtils.normalizeDate(day) == TimeOfDayUtils.normalizeDate(DateTime.now()), // Highlight today
    );
  }
}



