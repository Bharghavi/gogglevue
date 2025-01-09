import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../managers/login_manager.dart';
import 'screens/admin/admin_home.dart';
import 'screens/admin/login_page.dart';
import 'screens/staff/staff_home.dart';
import 'screens/student/student_home.dart';
import 'firebase_options.dart';
import 'constants.dart';
import 'screens/admin/registration_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final initialRoute = await determineInitialRoute();

  runApp(GoggleVue(initialRoute: initialRoute));
}

Future<String> determineInitialRoute() async {

  if (await LoginManager.loginWithSavedCredentials()) {
    final savedRole = await LoginManager.getSavedRole();
    if (savedRole != null) {
      switch (savedRole) {
        case 'Admin':
          return '/adminHome';
        case 'Staff':
          return '/staffHome';
        case 'Student':
          return '/studentHome';
        default:
          return '/login';
      }
    }
  }

  return '/login';
}

class GoggleVue extends StatelessWidget {
  final String initialRoute;

  const GoggleVue({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: K.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/adminHome': (context) => AdminHomePage(),
        '/staffHome': (context) => StaffHomePage(),
        '/studentHome': (context) => StudentHomePage(),
      },
      initialRoute: initialRoute,
    );
  }
}

