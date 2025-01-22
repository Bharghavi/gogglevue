import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../screens/themes/theme.dart';
import '../screens/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import '../managers/login_manager.dart';
import 'screens/admin/admin_home.dart';
import 'screens/login_page.dart';
import 'screens/staff/staff_home.dart';
import 'screens/student/student_home.dart';
import 'firebase_options.dart';
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

  bool login = false;

  try {
    login = await LoginManager.loginWithSavedCredentials();
  } catch (e) {
    return '/login';
  }

  if (login) {
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
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Your App Title',
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

