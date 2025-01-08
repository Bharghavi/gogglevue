import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginManager {

  static final secureStorage = FlutterSecureStorage();

  static Future<bool> login(String email, String password,
      String role, bool rememberMe) async {

        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password
        );

        final result =  credential.user != null;

        if (result) {
          saveCredentials(email, password, role, rememberMe);
        }

        return result;
  }

  static Future<bool> loginWithSavedCredentials() async {
    final savedUsername = await secureStorage.read(key: 'username');
    final savedPassword = await secureStorage.read(key: 'password');

    if (savedUsername != null && savedPassword != null) {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: savedUsername,
          password: savedPassword
      );
      return credential.user != null;
    }

    return false;
  }

  static Future<void> saveCredentials(String username, String password, String role, bool rememberMe) async {
    if (rememberMe) {
      await secureStorage.write(key: 'username', value: username);
      await secureStorage.write(key: 'password', value: password);
      await secureStorage.write(key: 'role', value: role);
    } else {
      await secureStorage.deleteAll(); // Clear saved data if not remembered
    }
  }

  static Future<void> signout() async {
    //await secureStorage.deleteAll();
    await FirebaseAuth.instance.signOut();
  }

  static Future<String?> getSavedUsername() async {
    return await secureStorage.read(key: 'username');
  }

  static Future<String?> getSavedPassword() async{
    return await secureStorage.read(key: 'password');
  }

  static Future<String?> getSavedRole() async {
    return await secureStorage.read(key: 'role');
  }

  static Future<String?> registerNewUser(String email, String password) async {

    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userId = userCredential.user?.uid;
    if (userId == null) {
      return null;
    } else {
      return userId;
    }

  }

  static Future<bool> roleExistsForUser(String email,
      String role) async {
    try {

      final querySnapshot = await FirebaseFirestore.instance
          .collection(role) // Collection based on role
          .where('email', isEqualTo: email) // Search by email
          .get();

      return querySnapshot.docs.isNotEmpty;

    } catch (e) {
      return false;
    }
  }
}