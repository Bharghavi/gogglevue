import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';
import '../constants.dart';
import 'admin_helper.dart';

class PaymentHelper {

  static Future<Payment> savePayment(double amount, String studentId, String batchId, DateTime paidDate, DateTime validFrom, DateTime validTo) async {
    String adminId = await AdminHelper.getLoggedAdminUserId();
    Payment newPayment = Payment(
        adminId: adminId,
        amount: amount,
        studentId: studentId,
        batchId: batchId,
        paymentDate: paidDate,
        validFrom: validFrom,
        validTo: validTo);

    await FirebaseFirestore.instance.collection(K.paymentCollection).add(newPayment.toMap());
    return newPayment;
  }

  static Future<List<Payment>> fetchPaymentsBetweenDates(DateTime fromDate, DateTime toDate) async {
    List<Payment> result = [];
    String adminId = await AdminHelper.getLoggedAdminUserId();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.paymentCollection)
        .where(K.adminId, isEqualTo: adminId)
        .where(K.paymentDate, isGreaterThanOrEqualTo: fromDate)
        .where(K.paymentDate, isLessThanOrEqualTo: toDate)
        .orderBy(K.paymentDate, descending: true) // Sort by paymentDate in descending order
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      result = querySnapshot.docs.map((doc) {
        return Payment.fromFirestore(doc);
      }).toList();

    }
    return result;
  }

  static Future<List<Payment>> fetchPaymentsBetweenDatesForStudent(String studentId, DateTime fromDate, DateTime toDate) async {
    List<Payment> result = [];
    String adminId = await AdminHelper.getLoggedAdminUserId();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.paymentCollection)
        .where(K.adminId, isEqualTo: adminId)
        .where(K.studentId, isEqualTo: studentId)
        .where(K.paymentDate, isGreaterThanOrEqualTo: fromDate)
        .where(K.paymentDate, isLessThanOrEqualTo: toDate)
        .orderBy(K.paymentDate, descending: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      result = querySnapshot.docs.map((doc) {
        return Payment.fromFirestore(doc);
      }).toList();

    }
    return result;
  }

  static Future<List<Payment>> fetchAllPayments() async {
    List<Payment> result = [];
    String adminId = await AdminHelper.getLoggedAdminUserId();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.paymentCollection)
        .where(K.adminId, isEqualTo: adminId)
        .orderBy(K.paymentDate, descending: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      result = querySnapshot.docs.map((doc) {
        return Payment.fromFirestore(doc);
      }).toList();

    }
    return result;
  }

  static Future<List<Payment>> fetchPaymentsForStudent(String studentId) async {
    List<Payment> result = [];
    String adminId = await AdminHelper.getLoggedAdminUserId();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.paymentCollection)
        .where(K.adminId, isEqualTo: adminId)
        .where(K.studentId, isEqualTo: studentId)
        .orderBy(K.paymentDate, descending: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      result = querySnapshot.docs.map((doc) {
        return Payment.fromFirestore(doc);
      }).toList();

    }
    return result;
  }

  static Future<List<Payment>> getPaymentOverdue() async{
    String adminId = await AdminHelper.getLoggedAdminUserId();
    List<Payment> overduePayments = [];
    final today = DateTime.now();
    final Map<String, Map<String, Payment>> latestPayments = {};

    try {
      final snapshot = await FirebaseFirestore.instance.collection(K.paymentCollection)
                            .where(K.adminId, isEqualTo:adminId)
                            .get();
      final payments = snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList();
       final paymentsByStudentAndBatch = <String, Map<String, List<Payment>>>{};

      for (var payment in payments) {
        paymentsByStudentAndBatch
            .putIfAbsent(payment.studentId, () => {})
            .putIfAbsent(payment.batchId, () => [])
            .add(payment);
      }

      for (var studentId in paymentsByStudentAndBatch.keys) {
        final batchMap = paymentsByStudentAndBatch[studentId]!;
        latestPayments[studentId] = {};

        for (var batchId in batchMap.keys) {
          final batchPayments = batchMap[batchId]!;
          batchPayments.sort((a, b) => b.validTo.compareTo(a.validTo));
          final latestPayment = batchPayments.first;

          if (latestPayment.validTo.isBefore(today)) {
            overduePayments.add(latestPayment);
          }
        }
      }
    } catch (e) {
      print("Error fetching payments: $e");
    }

    return overduePayments;
  }

  static Future<void> savePaymentNote(Payment payment) async {
    var paymentDocRef = FirebaseFirestore.instance.collection(K.paymentCollection).doc(payment.id);
    await paymentDocRef.update({
      'note': payment.note,
    });
  }

}