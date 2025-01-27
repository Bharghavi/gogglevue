import 'package:cloud_firestore/cloud_firestore.dart';
import '../Utils/time_of_day_utils.dart';
import '../models/staffAssignment.dart';

import '../constants.dart';
import '../models/staff.dart';
import 'admin_helper.dart';

class StaffAssignmentHelper {

  static Future<void> assignStaff(String batchId, String staffId, DateTime startDate, DateTime? endDate) async {
    final adminId = await AdminHelper.getLoggedAdminUserId();

    DateTime normalizedStartDate = TimeOfDayUtils.normalizeDate(startDate);
    DateTime? normalizedEndDate = endDate != null
        ? TimeOfDayUtils.normalizeDate(endDate)
        : null;

     QuerySnapshot existingAssignmentsSnapshot = await FirebaseFirestore.instance
        .collection(K.staffAssignmentCollection)
        .where(K.batchId, isEqualTo: batchId)
        .where(K.staffId, isEqualTo: staffId)
         .where(K.adminId, isEqualTo: adminId)
        .where(K.startDate, isLessThanOrEqualTo: Timestamp.fromDate(normalizedStartDate))
        .get();

    for (var doc in existingAssignmentsSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      DateTime? endDate = data[K.endDate] != null
          ? (data[K.endDate] as Timestamp).toDate()
          : null;

      if (endDate == null) {
        DateTime updatedEndDate = normalizedStartDate.subtract(Duration(days: 1));

        await FirebaseFirestore.instance
            .collection(K.staffAssignmentCollection)
            .doc(doc.id)
            .update({K.endDate: Timestamp.fromDate(updatedEndDate)});
        break;
      }
    }

    StaffAssignment newStaff = StaffAssignment(
      staffId: staffId,
      batchId: batchId,
      adminId: adminId,
      startDate: normalizedStartDate,
      endDate: normalizedEndDate,
    );

    await FirebaseFirestore.instance
        .collection(K.staffAssignmentCollection)
        .add(newStaff.toMap());
  }

  static Future<Staff?> getStaffFor(String batchId, DateTime date) async {

    DateTime normalizedDate = TimeOfDayUtils.normalizeDate(date);
    final adminId = await AdminHelper.getLoggedAdminUserId();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.staffAssignmentCollection)
        .where(K.batchId, isEqualTo: batchId)
        .where(K.adminId, isEqualTo: adminId)
        .where(K.startDate, isLessThanOrEqualTo: Timestamp.fromDate(normalizedDate))
        .get();

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      DateTime? endDate = data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null;

      if (endDate == null || endDate.isAfter(date) || endDate.isAtSameMomentAs(date)) {
        final staffDoc = await FirebaseFirestore.instance.collection(K.staffCollection).doc(data[K.staffId]).get();
        if (staffDoc.exists) {
          return Staff
              .fromFirestore(staffDoc.data() as Map<String, dynamic>, staffDoc.id);
        }
      }
    }
    return null;
  }

  static Future<DateTime> getFirstDateForBatch(String batchId) async{
    final adminId = await AdminHelper.getLoggedAdminUserId();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.staffAssignmentCollection)
        .where(K.batchId, isEqualTo: batchId)
        .where(K.adminId, isEqualTo: adminId)
        .orderBy(K.startDate)
        .get();

    return (querySnapshot.docs.first['startDate'] as Timestamp).toDate();
  }

}