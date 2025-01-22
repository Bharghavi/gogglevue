import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_helper.dart';
import '../models/staff.dart';
import '../constants.dart';

class StaffHelper {

  static Future<List<Staff>> getAllStaff() async{

    String adminId = await AdminHelper.getLoggedAdminUserId();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.staffCollection)
        .where(K.adminId, isEqualTo: adminId)
        .get();

    List<Staff> staffList = [];

    if (querySnapshot.docs.isNotEmpty) {
      staffList = querySnapshot.docs.map((doc) {
        return Staff.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

    }
    return staffList;
  }

  static Future<Staff> addNewStaff(String name, String email, String phone, String address, DateTime dob) async{
    String adminId = await AdminHelper.getLoggedAdminUserId();
    Staff newStaff = Staff(name: name, email: email, phone: phone, address: address, dob: dob, adminId: adminId);
    await FirebaseFirestore.instance.collection(K.staffCollection).add(newStaff.toMap());
    return newStaff;
  }

  static Future<void> deleteStaff(Staff staff) async {
    final staffDocRef = FirebaseFirestore.instance.collection(K.staffCollection).doc(staff.id);
    staffDocRef.delete();
  }

  static Future<Staff?> getStaffForBatch(String batchId) async {
    try {
      final batchDoc = await FirebaseFirestore.instance
          .collection(K.batchCollection)
          .doc(batchId)
          .get();

      if (!batchDoc.exists || !batchDoc.data()!.containsKey('instructor')) {
        print('Batch not found or instructor not specified');
        return null;
      }

      final instructorId = batchDoc['instructor'];

      final staffDoc = await FirebaseFirestore.instance
          .collection(K.staffCollection)
          .doc(instructorId)
          .get();

      if (staffDoc.exists) {
        return Staff.fromFirestore(staffDoc.data()!, staffDoc.id);
      } else {
        print('Instructor not found');
      }
    } catch (e) {
      print('Error fetching staff for batch: $e');
    }
    return null;
  }
}