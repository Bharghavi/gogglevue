import 'package:flutter/material.dart';
import '../../helpers/user_registration_helper.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Controllers to get user input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _instituteNameController = TextEditingController();
  final TextEditingController _instituteAddressController = TextEditingController();


  final helper = RegistrationHelper();

  // Date Picker Function
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // Registration Logic
  void _registerUser() async {
    final username = _usernameController.text;
    final dob = _dobController.text;
    final address = _addressController.text;
    final phone = _phoneController.text;
    final instituteName = _instituteNameController.text;
    final instituteAddress = _instituteAddressController.text;

    if (username.isEmpty ||
        dob.isEmpty ||
        address.isEmpty ||
        phone.isEmpty) {
      if (mounted) {
        _showMessage('All fields are required!');
      }
      return;
    }

   try {
     final parsedDob = DateTime.parse(dob);
     await helper.registerAdmin(
         username, phone, address, parsedDob, instituteName, instituteAddress, null, null);
    _showMessage('Admin user registered successfully!');
     Future.delayed(Duration(seconds: 2), () {
       if (mounted) {
         Navigator.pushReplacementNamed(context, '/login');
       }
     });

   } catch (e) {
     if (mounted) {
       _showMessage('Registration failed: $e');
     }
   }
  }

  // Display Messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Enter name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),

            // Date of Birth
            TextField(
              controller: _dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
            ),
            const SizedBox(height: 12.0),

            // Address
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),

            // Phone Number
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),

            // Register Button
            Center(
              child: ElevatedButton(
                onPressed: _registerUser,
                child: const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
