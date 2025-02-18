import 'package:flutter/material.dart';

import '../../../Utils/ui_utils.dart';
import '../../../helpers/student_helper.dart';
import '../../../managers/database_manager.dart';

class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key});

  @override
  AddStudentDialogState createState() => AddStudentDialogState();
}

class AddStudentDialogState extends State<AddStudentDialog> {

  String name = '';
  String phone = '';

  late StudentHelper studentHelper;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final firestore = await DatabaseManager.getAdminDatabase();
    studentHelper = StudentHelper(firestore);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Student', style: Theme.of(context).textTheme.bodyMedium,),
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
                phone.isEmpty) {
              UIUtils.showMessage(context, 'Name, email and phone number are required!');
            } else {
              addNewStudent(name, null, phone, null, null);

            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
  void addNewStudent(String name, String? email, String phone, String? address,
      DateTime? dob) async {
    try {
      final newStudent =
      await studentHelper.saveNewStudent(name, email, phone, address, dob, null);
      Navigator.pop(context, newStudent);
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error occurred', '$e');
      }
    }
  }


}