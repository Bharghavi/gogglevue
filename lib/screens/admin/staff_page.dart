import 'package:flutter/material.dart';
import '../../models/staff.dart';
import '../../helpers/staff_helper.dart';
import '../../Utils/ui_utils.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({Key? key}) : super(key: key);

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
      UIUtils.showMessage(context, 'Failed to fetch staff: $e');
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
      UIUtils.showMessage(context, 'Error occurred: $e');
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

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Staff Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Content
          Expanded(
            child: staffList.isEmpty
                ? Center(
              child: Text(
                'No staff available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return ListTile(
                  title: Text(staff.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${staff.email}'),
                      Text('Phone: ${staff.phone}'),
                      Text('Address: ${staff.address}'),
                      Text('DOB: ${staff.dob.toLocal().toString().split(' ')[0]}'),
                    ],
                  ),
                  isThreeLine: true,
                  leading: Icon(Icons.person),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddStaffDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
