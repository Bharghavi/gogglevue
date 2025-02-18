import 'package:cloud_firestore/cloud_firestore.dart';
import '../Utils/time_of_day_utils.dart';
import '../models/staff_assignment.dart';
import '../constants.dart';
import '../models/staff.dart';

class StaffAssignmentHelper {

  final FirebaseFirestore _firestore;

  StaffAssignmentHelper(this._firestore);

  Future<void> assignStaff(String batchId, String staffId, DateTime startDate, DateTime? endDate) async {
    DateTime normalizedStartDate = TimeOfDayUtils.normalizeDate(startDate);

    DateTime? normalizedEndDate = endDate != null
        ? TimeOfDayUtils.normalizeDate(endDate)
        : null;

     QuerySnapshot existingAssignmentsSnapshot = await _firestore
        .collection(K.staffAssignmentCollection)
        .where(K.batchId, isEqualTo: batchId)
        .where(K.staffId, isEqualTo: staffId)
        .where(K.startDate, isLessThanOrEqualTo: Timestamp.fromDate(normalizedStartDate))
        .get();

    for (var doc in existingAssignmentsSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      DateTime? endDate = data[K.endDate] != null
          ? (data[K.endDate] as Timestamp).toDate()
          : null;

      if (endDate == null) {
        DateTime updatedEndDate = normalizedStartDate.subtract(Duration(days: 1));

        await _firestore
            .collection(K.staffAssignmentCollection)
            .doc(doc.id)
            .update({K.endDate: Timestamp.fromDate(updatedEndDate)});
        break;
      }
    }

    StaffAssignment newStaff = StaffAssignment(
      staffId: staffId,
      batchId: batchId,
      startDate: normalizedStartDate,
      endDate: normalizedEndDate,
    );

    await _firestore
        .collection(K.staffAssignmentCollection)
        .add(newStaff.toMap());
  }

  Future<Staff?> getStaffFor(String batchId, DateTime date) async {

    DateTime normalizedDate = TimeOfDayUtils.normalizeDate(date);

    QuerySnapshot querySnapshot = await _firestore
        .collection(K.staffAssignmentCollection)
        .where(K.batchId, isEqualTo: batchId)
        .where(K.startDate, isLessThanOrEqualTo: Timestamp.fromDate(normalizedDate))
        .get();

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      DateTime? endDate = data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null;

      if (endDate == null || endDate.isAfter(date) || endDate.isAtSameMomentAs(date)) {
        final staffDoc = await _firestore.collection(K.staffCollection).doc(data[K.staffId]).get();
        if (staffDoc.exists) {
          return Staff
              .fromFirestore(staffDoc.data() as Map<String, dynamic>, staffDoc.id);
        }
      }
    }
    return null;
  }

  Future<DateTime> getFirstDateForBatch(String batchId) async{

    QuerySnapshot querySnapshot = await _firestore
        .collection(K.staffAssignmentCollection)
        .where(K.batchId, isEqualTo: batchId)
        .orderBy(K.startDate)
        .get();

    return (querySnapshot.docs.first['startDate'] as Timestamp).toDate();
  }

}