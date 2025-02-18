import '/Utils/time_of_day_utils.dart';
import 'package:flutter/material.dart';

import '../../../Utils/ui_utils.dart';
import '../../../helpers/staff_helper.dart';
import '../../../managers/database_manager.dart';

class AddStaffDialog extends StatefulWidget {
  const AddStaffDialog({super.key});

  @override
  AddStaffDialogState createState() => AddStaffDialogState();
}

class AddStaffDialogState extends State<AddStaffDialog> {
  String name = '';
  String phone = '';
  DateTime joiningDate = DateTime.now();
  double salary = 0;
  final TextEditingController _dojController = TextEditingController();

  late StaffHelper staffHelper;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final firestore = await DatabaseManager.getAdminDatabase();
    staffHelper = StaffHelper(firestore);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Staff', style: Theme.of(context).textTheme.bodyMedium,),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Phone'),
              onChanged: (value) => phone = value,
            ),
            TextField(
              controller: _dojController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date of Joining',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              decoration: InputDecoration(labelText: 'Monthly salary'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                salary = double.tryParse(value) ?? 0.0;
              },
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
          onPressed: () async {
            if (name.isEmpty || phone.isEmpty) {
              UIUtils.showErrorDialog(context, 'Error','Name and phone number are required!');
            } else if (salary <= 0) {
              UIUtils.showErrorDialog(context, 'Error','Salary should be greater than 0!');
            } else {
              await addNewStaff(name, phone, joiningDate, salary);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  Future<void> addNewStaff(String name, String phone, DateTime joiningDate, double salary) async {
    try {
      final newStaff =
          await staffHelper.addNewStaff(name, null, phone, null, null, joiningDate, salary);

      if (mounted) {
        UIUtils.showMessage(context, 'Staff saved successfully');
        Navigator.pop(context, newStaff);
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error occurred', '$e');
      }
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dojController.text = TimeOfDayUtils.dateTimeToString(pickedDate);
        joiningDate = pickedDate;
      });
    }
  }
}
