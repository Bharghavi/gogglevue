import '/managers/database_manager.dart';
import 'package:flutter/material.dart';
import '../Utils/ui_utils.dart';
import 'admin/admin_home.dart';
import 'staff/staff_home.dart';
import 'student/student_home.dart';
import '../managers/login_manager.dart';
import '../constants.dart';
import 'admin/registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String _selectedRole = K.roleAdmin;
  bool rememberMe = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final role = _selectedRole;

    try {
      final loginSuccess = await LoginManager.login(username, password, role, rememberMe);
      if (loginSuccess) {
        _navigateToHomePage(role);
      } else {
        if (mounted) {
          UIUtils.showErrorDialog(context, 'Unable to Login', 'Please check your credentials.');
        }
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Unable to Login', '$e');
      }
    }
  }

  Future<void> loadSavedCredentials() async {
    final username = await LoginManager.getSavedUsername();
    final password = await LoginManager.getSavedPassword();
    final role = await LoginManager.getSavedRole();
    if (username != null && password != null && role != null) {
      setState(() {
        _usernameController.text = username;
        _passwordController.text = password;
        _selectedRole = role;
        rememberMe = true;
      });
    }
  }

  void _navigateToHomePage(String role) async {
    if (role == 'Admin') {
      String? adminDb = await DatabaseManager.getAdminDatabaseId();

      if (adminDb != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegistrationPage()),
        );
      }
    } else if (role == 'Staff') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StaffHomePage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StudentHomePage()),
      );
    }
  }


  void _register() {
    // Navigate to the Registration Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(K.loginPageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - appBarHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButton<String>(
                    value: _selectedRole,
                    items: [K.roleAdmin, K.roleStaff, K.roleStudent]
                        .map(
                          (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role, style: Theme.of(context).textTheme.bodySmall,),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),

                  Center(
                    child: Image.asset(
                      'assets/images/aarambha.png',
                      height: 150,
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  if (_selectedRole != K.roleAdmin) ...[
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: K.usernameLabel,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: K.passwordLabel,
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) {
                        _login();
                      },
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value!;
                            });
                          },
                        ),
                        const Text("Remember Me"),
                        const Spacer(),
                        TextButton(
                          onPressed: _forgotPassword,
                          child: const Text("Forgot Password?"),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text(K.loginButton),
                    ),
                    const SizedBox(height: 8.0),
                    if (_selectedRole == K.roleStudent || _selectedRole == K.roleStaff)
                      ElevatedButton(
                        onPressed: _register,
                        child: const Text(K.registerButton),
                      ),
                  ],

                  // Google Sign-in button (always visible for Admin, optional for others)
                  ElevatedButton(
                    onPressed: () async {
                      final userCredential = await LoginManager.signInWithGoogle(_selectedRole);
                      if (userCredential != null) {
                        _navigateToHomePage(_selectedRole);
                      }
                    },
                    child: const Text("Sign in with Google"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String email = "";

        return AlertDialog(
          title: const Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please enter your email address to receive a password reset link."),
              const SizedBox(height: 16.0),
              TextField(
                onChanged: (value) {
                  email = value;
                },
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (email.isNotEmpty) {
                  try {
                    await LoginManager.resetPassword(email);
                    if (mounted) {
                      Navigator.of(context).pop();
                      UIUtils.showMessage(context, 'A reset link has been sent to $email.');
                    }
                  } catch (e) {
                    if (mounted) {
                      UIUtils.showErrorDialog(context, 'Failed to send reset link. Please try again.', '$e');
                    }
                  }
                } else {
                  UIUtils.showMessage(context, 'Please enter a valid email address.');
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

}