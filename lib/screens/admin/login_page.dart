import 'package:flutter/material.dart';
import 'admin_home.dart';
import '../staff/staff_home.dart';
import '../student/student_home.dart';
import '../../managers/login_manager.dart';
import '../../constants.dart';
import 'registration_page.dart';

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

    // Invoke login method from LoginManager
    try {
      final loginSuccess = await LoginManager.login(username, password, role, rememberMe);
      if (loginSuccess) {
        _navigateToHomePage(role);
      } else {
        _showMessage('Login Failed. Please check your credentials.');
      }
    } catch (e) {
      _showMessage('Unable to Login:');
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

// Function to display messages using Snackbar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

// Navigate to Home Page based on role
  void _navigateToHomePage(String role) {
    if (role == 'Admin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminHomePage()),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(K.loginPageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add logo here
            Center(
              child: Image.asset(
                K.logoImagePath, // Make sure the image path is correct
                height: 120, // Adjust the size as needed
              ),
            ),
            const SizedBox(height: 24.0),
            DropdownButton<String>(
              value: _selectedRole,
              items: [K.roleAdmin, K.roleStaff, K.roleStudent]
                  .map((role) =>
                  DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            const SizedBox(height: 16.0),
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
              ],
            ),

            if (_selectedRole == K.roleAdmin) ...[
              ElevatedButton(
                onPressed: _login,
                child: const Text(K.loginButton),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _register,
                child: const Text(K.registerButton),
              ),
            ] else
              ...[
                ElevatedButton(
                  onPressed: _login,
                  child: const Text(K.loginButton),
                ),
              ],
          ],
        ),
      ),
    );
  }
}