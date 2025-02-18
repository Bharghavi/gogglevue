
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentBatch {

  final String studentId;
  final String batchId;
  final DateTime joiningDate;
  bool active;

  StudentBatch({
    required this.studentId,
    required this.batchId,
    required this.joiningDate,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'batchId': batchId,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'active': active,
    };
  }
}