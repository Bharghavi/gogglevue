import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  String? id;
  String adminId;
  double amount;
  String studentId;
  String batchId;
  DateTime paymentDate;
  DateTime validFrom;
  DateTime validTo;

  Payment({
    this.id,
    required this.adminId,
    required this.amount,
    required this.studentId,
    required this.batchId,
    required this.paymentDate,
    required this.validFrom,
    required this.validTo,
});

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'amount': amount,
      'studentId': studentId,
      'batchId': batchId,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'validFrom': Timestamp.fromDate(validFrom),
      'validTo': Timestamp.fromDate(validTo),
    };
  }

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    return Payment(
        id: doc.id,
        adminId: map['adminId'] ?? '',
        amount: map['amount'] ?? 0,
        studentId: map['studentId'] ?? '',
        batchId: map['batchId'] ?? '',
        paymentDate: (map['paymentDate'] as Timestamp).toDate(),
        validFrom: (map['validFrom'] as Timestamp).toDate(),
        validTo: (map['validTo'] as Timestamp).toDate());
  }
}