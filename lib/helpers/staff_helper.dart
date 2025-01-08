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
}