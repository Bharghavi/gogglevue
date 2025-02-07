import '/managers/database_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import '../constants.dart';
import '../models/admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationHelper {

  Future<void> registerAdmin(String name, String phone, String address, DateTime dob, String instituteName, String instituteAddress, String? logo, String? profilePic) async {
    var admin = Admin(name: name, phone: phone, address: address, dob: dob, instituteName: instituteName, instituteAddress: instituteAddress);
    if (logo != null) {
      admin.logo = logo;
    }
    if (profilePic != null) {
      admin.profilePic = profilePic;
    }

    String? databaseId = await DatabaseManager.getAdminDatabaseId();

    if (databaseId != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );
      await firestore.collection(K.adminCollection).add(admin.toMap());
    } else {
      FirebaseFirestore firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: "aarambha-15705",
      );
      await firestore.collection(K.adminCollection).add(admin.toMap());
    }


  }
}