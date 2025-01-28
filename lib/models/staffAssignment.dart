import 'package:cloud_firestore/cloud_firestore.dart';

class StaffAssignment {
  String batchId;
  DateTime startDate;
  DateTime? endDate;
  String staffId;
  String adminId;

  StaffAssignment({
    required this.staffId,
    required this.batchId,
    required this.adminId,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'batchId': batchId,
      'adminId': adminId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    };
  }
}