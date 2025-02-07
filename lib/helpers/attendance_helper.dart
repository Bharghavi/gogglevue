import 'package:cloud_firestore/cloud_firestore.dart';

import '../Utils/time_of_day_utils.dart';
import '../constants.dart';
import '../models/attendance.dart';

class AttendanceHelper {

  static Future<bool?> isStudentPresent(String studentId, String batchId, DateTime date) async{
    final normalizedDate = TimeOfDayUtils.normalizeDate(date);

    final attendanceSnapshot = await FirebaseFirestore.instance
        .collection(K.attendanceCollection)
        .where(K.batchId, isEqualTo: batchId)
        .where(K.date, isEqualTo: normalizedDate)
        .get();

    if (attendanceSnapshot.docs.isNotEmpty) {
      final attendance = Attendance.fromFirestore(attendanceSnapshot.docs.first);

      if (attendance.studentAttendance.containsKey(studentId)) {
        return attendance.studentAttendance[K.studentId];
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<void> saveAttendance(String staffId, String batchId, DateTime date,
      bool isSessionCancelled, String? cancelReason,
      Map<String, bool> studentAttendance) async {

    final normalizedDate = TimeOfDayUtils.normalizeDate(date);

    final attendance = Attendance(staffId: staffId,
                                  batchId: batchId,
                                  date: normalizedDate,
      isSessionCancelled: isSessionCancelled,
    cancelReason: cancelReason,
    studentAttendance: studentAttendance);
    await FirebaseFirestore.instance.collection(K.attendanceCollection).add(attendance.toMap());
  }

  static Future<List<List<DateTime>>> fetchAttendanceBetweenDatesFor(
      String studentId,
      String batchId,
      DateTime startDate,
      DateTime endDate,
      ) async {

      Timestamp startTimestamp = Timestamp.fromDate(TimeOfDayUtils.normalizeDate(startDate));
      Timestamp endTimestamp = Timestamp.fromDate(TimeOfDayUtils.normalizeDate(endDate));

      List<DateTime> presentDays = [];
      List<DateTime> absentDays = [];
      List<DateTime> sessionCanceled = [];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(K.attendanceCollection)
          .where(K.batchId, isEqualTo: batchId)
          .where(K.date, isGreaterThanOrEqualTo: startTimestamp)
          .where(K.date, isLessThanOrEqualTo: endTimestamp)
          .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        DateTime date = (data[K.date] as Timestamp).toDate();
        if (data['isSessionCancelled'] as bool) {
          sessionCanceled.add(date);
        }
        else {
          Map<String, bool> studentAttendance = Map<String, bool>.from(
              data['studentAttendance'] ?? {});
          if (studentAttendance.containsKey(studentId)) {
            if (studentAttendance[studentId] as bool) {
              presentDays.add(date);
            } else {
              absentDays.add(date);
            }
          }
        }
      }

      List<List<DateTime>> result = [];
      result.add(presentDays);
      result.add(sessionCanceled);
      result.add(absentDays);
      return result;

  }

  static Future<Attendance?> fetchAttendanceForBatch(String batchId, DateTime date) async {
    final normalizedDate = TimeOfDayUtils.normalizeDate(date);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.attendanceCollection)
        .where(K.batchId, isEqualTo: batchId)
        .where(K.date, isEqualTo: normalizedDate)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Attendance.fromFirestore(querySnapshot.docs.first);
    }

    return null;
  }
}