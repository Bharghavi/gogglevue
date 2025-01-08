import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class AdminHelper {

  static Future<String> getLoggedAdminUserId() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User is not logged in");
    }
    if (user.email == null) {
      throw Exception("User email not found");
    }

    String email = user.email ?? "No email found";

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.adminCollection)
        .where(K.email, isEqualTo: email)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Admin profile not found for the email: $email');
    }

    String adminId = querySnapshot.docs[0].id; // adminId is the document ID

    return adminId;

  }
}