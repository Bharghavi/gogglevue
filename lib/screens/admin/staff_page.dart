import 'package:flutter/material.dart';
import '../../Utils/time_of_day_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/staff.dart';
import '../../helpers/staff_helper.dart';
import '../../Utils/ui_utils.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  StaffPageState createState() => StaffPageState();
}

class StaffPageState extends State<StaffPage> {
  List<Staff> staffList = [];

  @override
  void initState() {
    super.initState();
    fetchStaff();
  }

  Future<void> fetchStaff() async {
    try {
      final fetchedStaff = await StaffHelper.getAllStaff();
      setState(() {
        staffList = fetchedStaff;
      });
    } catch (e) {
      if (mounted) {
      UIUtils.showMessage(context, 'Failed to fetch staff: $e');
      }
    }
  }

  void addNewStaff(String name, String email, String phone, String address,
      DateTime dob) async {
    try {
      final newStaff =
          await StaffHelper.addNewStaff(name, email, phone, address, dob);
      setState(() {
        staffList.add(newStaff);
      });
    } catch (e) {
      if (mounted) {
        UIUtils.showMessage(context, 'Error occurred: $e');
      }
    }
  }

  void showAddStaffDialog() {
    String name = '';
    String email = '';
    String phone = '';
    String address = '';
    DateTime? dob;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Staff'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Name'),
                      onChanged: (value) => name = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Email'),
                      onChanged: (value) => email = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Phone'),
                      onChanged: (value) => phone = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Address'),
                      onChanged: (value) => address = value,
                    ),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        hintText: dob == null
                            ? 'Select Date'
                            : dob.toString().split(' ')[0],
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            DateTime? selectedDate = await _selectDate();
                            if (selectedDate != null) {
                              setState(() => dob = selectedDate);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (name.isEmpty ||
                        email.isEmpty ||
                        phone.isEmpty ||
                        address.isEmpty ||
                        dob == null) {
                      UIUtils.showMessage(context, 'All fields are required!');
                    } else {
                      addNewStaff(name, email, phone, address, dob!);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<DateTime?> _selectDate() async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
  }

  void _removeStaff(Staff staff) async {
    UIUtils.showConfirmationDialog(context: context,
        title: 'Remove Staff',
        content: 'Are you sure you want to delete ${staff.name}?',
        onConfirm: () {
          StaffHelper.deleteStaff(staff).then((_) {
            setState(() {
              staffList.remove(staff);
            });
            if (mounted) {
              UIUtils.showMessage(context, 'Staff deleted successfully');
            }
          });
        });
  }

  void _makeCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if(mounted) {
        UIUtils.showErrorDialog(context, 'Error', 'Error occurred, please try later');
      }
    }
  }

  void _sendMessage(String phoneNumber) async {
    final uri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if(mounted) {
        UIUtils.showErrorDialog(context, 'Error', 'Error occurred, please try later');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Staff',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Content
          Expanded(
            child: staffList.isEmpty
                ? Center(
              child: Text(
                'No staff available',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
                : ListView.builder(
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return ListTile(
                  title: Text(staff.name, style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${staff.email}', style: Theme.of(context).textTheme.bodySmall),
                      Text('Address: ${staff.address}', style: Theme.of(context).textTheme.bodySmall),
                      Text('DOB: ${TimeOfDayUtils.dateTimeToString(staff.dob)}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  isThreeLine: true,
                  leading: Icon(Icons.person),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Ensures the row takes up minimal space
                    children: [
                      IconButton(
                        icon: Icon(Icons.call, color: Colors.green),
                        onPressed: () => _makeCall(staff.phone),
                      ),
                      IconButton(
                        icon: Icon(color: Colors.blue, Icons.message_rounded),
                        onPressed: () => _sendMessage(staff.phone),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeStaff(staff),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddStaffDialog,
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
