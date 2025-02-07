import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../screens/themes/theme.dart';
import '../screens/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import '../managers/login_manager.dart';
import 'managers/database_manager.dart';
import 'screens/admin/admin_home.dart';
import 'screens/login_page.dart';
import 'screens/staff/staff_home.dart';
import 'screens/student/student_home.dart';
import 'firebase_options.dart';
import 'screens/admin/registration_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

 /* await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );*/

  final initialRoute = await determineInitialRoute();

  runApp(Aarambha(initialRoute: initialRoute));
}

Future<String> determineInitialRoute() async {
  bool login = false;

  try {
    login = await LoginManager.loginWithSavedCredentials();
  } catch (e) {
    print (e);
    return '/login';
  }

  if (login) {
    final savedRole = await LoginManager.getSavedRole();
    if (savedRole != null) {
      switch (savedRole) {
        case 'Admin':
          final adminDatabase = await DatabaseManager.getAdminDatabaseId();
          return adminDatabase != null ? '/adminHome' : '/register';
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

class Aarambha extends StatelessWidget {
  final String initialRoute;

  const Aarambha({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Aarambha',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            routes: {
              '/login': (context) => LoginPage(),
              '/register': (context) => RegistrationPage(),
              '/adminHome': (context) => AdminHomePage(),
              '/staffHome': (context) => StaffHomePage(),
              '/studentHome': (context) => StudentHomePage(),
            },
            initialRoute: initialRoute,
          );
        },
      ),
    );
  }
}

