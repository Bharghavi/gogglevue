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

}