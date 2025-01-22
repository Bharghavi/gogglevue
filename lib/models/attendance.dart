import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  String? id;
  String batchId;
  String staffId;
  DateTime date;
  bool isSessionCancelled;
  String? cancelReason;
  Map<String, bool> studentAttendance;

  Attendance({this.id,
              required this.staffId,
              required this.batchId,
              required this.date,
              required this.isSessionCancelled,
              this.cancelReason,
              required this.studentAttendance,});

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'batchId': batchId,
      'date': Timestamp.fromDate(date),
      'isSessionCancelled': isSessionCancelled,
      'cancelReason': cancelReason,
      'studentAttendance': studentAttendance,
    };
  }

  factory Attendance.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Attendance(
      id: doc.id,
      staffId: map['staffId'] ?? '',
      batchId: map['batchId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      isSessionCancelled: map['isSessionCancelled'] ?? false,
      cancelReason: map['cancelReason'] ?? '',
      studentAttendance: Map<String, bool>.from(map['studentAttendance'] ?? {}),
    );
  }
}