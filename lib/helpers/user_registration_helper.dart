import '../managers/login_manager.dart';
import '../constants.dart';
import '../models/admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationHelper {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerAdmin(String name, String email, String phone, String address, DateTime dob, String password) async {
    final roleExists = await LoginManager.roleExistsForUser(email, K.roleAdmin);
    if (roleExists) {
      throw Exception('Admin user with the $email is already registered. Please login');
    } else {
      final admin = Admin(name: name, email: email, phone: phone, address: address, dob: dob);
       final uid = await LoginManager.registerNewUser(email, password);

       if (uid != null) {
         await _firestore.collection(K.adminCollection).doc(uid).set(admin.toMap());
       } else {
         throw Exception('Failed to create user in authentication');
       }
    }
  }
}