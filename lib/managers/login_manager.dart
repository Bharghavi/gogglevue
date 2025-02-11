import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginManager {

  static final secureStorage = FlutterSecureStorage();
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<UserCredential?> signInWithGoogle(String role) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser
        .authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await secureStorage.write(key: 'idToken', value: googleAuth.idToken);
    await secureStorage.write(key: 'accessToken', value: googleAuth.accessToken);
    await secureStorage.write(key: 'role', value: role);

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    return userCredential;
  }

  static Future<String?> getLoggedInUserId() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    }
    return null;
  }

  static Future<String?> getLoggedInUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.displayName;
    }
    return null;
  }

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

    final savedIdToken =  await secureStorage.read(key: 'idToken');
    final savedAccessToken =  await secureStorage.read(key: 'accessToken');

    if (savedIdToken != null && savedAccessToken != null) {
      return true;
    }

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
      await secureStorage.deleteAll();
    }
  }

  static Future<void> signout() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    await secureStorage.deleteAll();
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

  static Future<void> resetPassword(String email) async{
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email);
  }
}