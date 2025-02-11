import 'dart:io';

import '../../Utils/time_of_day_utils.dart';
import '../../Utils/ui_utils.dart';

import '../../Utils/image_utils.dart';
import '../../Utils/location_utils.dart';
import '../../managers/database_manager.dart';
import '../../managers/login_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:place_picker_google/place_picker_google.dart';
import '../../Utils/text_utils.dart';
import '../../constants.dart';
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
  final TextEditingController _instituteNameController =
      TextEditingController();
  final TextEditingController _instituteIdController = TextEditingController();
  final TextEditingController _instituteAddressController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _errorText;
  bool _isChecking = false;

  final helper = RegistrationHelper();

  GeoPoint? location;
  String? _logoPath;
  String? _profilePicPath;

  File? logoFile;
  File? dpFile;
  DateTime dateOfBirth = DateTime.now();

  @override
  void dispose() {
    _instituteIdController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setUserName();
  }

  Future<void> setUserName() async {
    final userName = await LoginManager.getLoggedInUserName();
    if (userName != null) {
      setState(() {
        _usernameController.text = userName;
      });
    }
  }

  void _validateInstituteId(String id) async {
    setState(() {
      _errorText = null;
      _isChecking = true;
    });

    // Ensure exactly 6 characters
    if (id.length != 6) {
      setState(() {
        _errorText = 'Institute ID must be exactly 6 characters.';
        _isChecking = false;
      });
      return;
    }

    final canCreate = await DatabaseManager.canCreateInstituteId(id);
    if (!canCreate) {
      setState(() {
        _errorText = 'Institute ID already exists. Please select a new ID';
      });
    }

    setState(() {
      _isChecking = false;
    });
  }

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
        _dobController.text = TimeOfDayUtils.dateTimeToString(pickedDate);
        dateOfBirth = pickedDate;
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
    final instituteId = _instituteIdController.text;

    if (username.isEmpty || dob.isEmpty || address.isEmpty || phone.isEmpty) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Input required', 'All fields are required!');
      }
      return;
    }

    try {
      await helper.registerAdmin(username, phone, address, dateOfBirth,
          instituteName, instituteId, instituteAddress, _logoPath, _profilePicPath, location);
      if (mounted) {
        UIUtils.showMessage(context, 'Admin user registered successfully!');
      }
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/adminHome');
        }
      });
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error occurred', 'Registration failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Details Section
            const Text(
              'Personal Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),

            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),

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
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),

            Row (
              children: [
                ElevatedButton.icon(
                  onPressed: () async => {
                    await _pickProfilePic()
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Profile pic'),
                ),
                const SizedBox(height: 20.0),

                if (_profilePicPath != null || dpFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Optional styling
                    child: _profilePicPath == null ?  Image.file(dpFile!, width: 100, height: 100, fit: BoxFit.cover)
                    : Image.network(
                      _profilePicPath!,
                      width: 100, // Adjust size
                      height: 100,
                      fit: BoxFit.cover, // Crop to fit
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
              ],
            ),


            // Institute Details Section
            const Text(
              'Institute Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _instituteNameController,
              decoration: const InputDecoration(
                labelText: 'Institute Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _instituteIdController,
              decoration: InputDecoration(
                labelText: 'Institute ID (6 char)',
                border: OutlineInputBorder(),
                errorText: _errorText,
                suffixIcon: _isChecking
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                UpperCaseTextFormatter(),
              ],
              onChanged: (value) {
                _validateInstituteId(value);
              },
            ),
            const SizedBox(height: 12.0),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _instituteAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Institute Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0), // Space between TextField and button
                ElevatedButton(
                  onPressed: _getLocation,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.location_pin),
                ),
              ],
            ),

        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async => {
                 await _pickLogo()
              },
              icon: const Icon(Icons.image),
              label: const Text('Upload Logo'),
            ),
            const SizedBox(height: 20.0),

            // Show image preview if available
            if (_logoPath != null || logoFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Optional styling
                child: _logoPath == null ? Image.file(logoFile!, width: 100, height: 100, fit: BoxFit.cover)
                : Image.network(
                  _logoPath!,
                  width: 100, // Adjust size
                  height: 100,
                  fit: BoxFit.cover, // Crop to fit
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator();
                  },
                ),
              ),
          ],
        ),

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

  Future<void> _pickLogo() async{
    File? pic = await ImageUtils.pickImage();
    if (pic == null) {
      return;
    }
    setState(() {
      logoFile = pic;
    });
    String? logoPath = await _pickImage(pic, K.logo);
    if (logoPath != null) {
      setState(() {
        _logoPath = logoPath;
      });
    }
  }

  Future<void> _pickProfilePic() async {
    File? pic = await ImageUtils.pickImage();
    if (pic == null) {
      return;
    }
    setState(() {
      dpFile = pic;
    });
    String? dpPath = await _pickImage(pic, K.profilePic);
    if( dpPath != null) {
      setState(() {
        _profilePicPath = dpPath;
      });
    }
  }

  Future<String?> _pickImage(File image, String type) async {
    String? adminId = await LoginManager.getLoggedInUserId();
    String? imagePath;
    if (adminId != null) {
      imagePath =  await ImageUtils.uploadImage(image, adminId, type);
    }
    return imagePath;
  }

  Future<void> _getLocation() async {
    LocationResult? locationResult = await LocationUtils.pickLocation(
      context,
      _locationController.text,
    );

    if (locationResult == null) {
      return;
    }

    if (locationResult.formattedAddress != null &&
        locationResult.latLng != null) {
      setState(() {
        _instituteAddressController.text = locationResult.formattedAddress!;
        location = GeoPoint(
            locationResult.latLng!.latitude, locationResult.latLng!.longitude);
      });
    }
  }
}