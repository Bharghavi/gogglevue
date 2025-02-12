import '/managers/database_manager.dart';
import '../constants.dart';
import '../models/admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationHelper {

  Future<void> registerAdmin(String name, String phone, String address, DateTime dob, String instituteName, String instituteId, String instituteAddress, String? logo, String? profilePic, GeoPoint? location) async {
    var admin = Admin(name: name,
        phone: phone,
        address: address,
        dob: dob,
        instituteName: instituteName,
        instituteId: instituteId,
        instituteAddress: instituteAddress);
    if (logo != null) {
      admin.logo = logo;
    }
    if (profilePic != null) {
      admin.profilePic = profilePic;
    }

    if (location != null) {
      admin.location = location;
    }

    FirebaseFirestore firestore = await DatabaseManager.getAdminDatabase();
    await firestore.collection(K.adminCollection).add(admin.toMap());
    await DatabaseManager.updateInstituteIdAndAdminId(instituteId, admin.id);
  }
}