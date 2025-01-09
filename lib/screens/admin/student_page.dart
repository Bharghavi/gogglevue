import 'package:flutter/material.dart';
import '../../models/student.dart';
import '../../helpers/student_helper.dart';
import '../../Utils/ui_utils.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  StudentPageState createState() => StudentPageState();
}

class StudentPageState extends State<StudentPage> {
  List<Student> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final studentList = await StudentHelper.fetchAllStudents();
      //print('NO of students = ${studentList.length}');
      setState(() {
        students = studentList;
      });
    } catch (e) {
      if (mounted) {
        UIUtils.showMessage(context, 'Failed to fetch student: $e');
      }
    }
  }

  void addNewStudent(String name, String email, String phone, String address,
      DateTime dob) async {
    try {
      final newStudent =
      await StudentHelper.saveNewStudent(name, dob, phone, address, email );
      setState(() {
        students.add(newStudent);
      });
    } catch (e) {
      if (mounted) {
        UIUtils.showMessage(context, 'Error occurred: $e');
      }
    }
  }

  void showAddStudentDialog() {
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
              title: Text('Add New Student'),
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
                      addNewStudent(name, email, phone, address, dob!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Students',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Content
          Expanded(
            child: students.isEmpty
                ? Center(
              child: Text(
                'Add new students',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(student.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${student.email}'),
                        Text('Phone: ${student.phone}'),
                        Text('Address: ${student.address}'),
                        Text('DOB: ${student.dob.toLocal().toString().split(' ')[0]}'),
                      ],
                    ),
                    isThreeLine: true,
                    leading: Icon(Icons.person),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Call the edit function
                            showEditStudentDialog(student, index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Call the delete function
                            deleteStudent(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddStudentDialog,
        child: Icon(Icons.add),
      ),
    );
  }
  void deleteStudent(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Student'),
          content: Text('Are you sure you want to delete ${students[index].name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                StudentHelper.deleteStudent(students[index]);
                setState(() {
                  students.removeAt(index);
                });
                Navigator.of(context).pop(); // Close the dialog
                UIUtils.showMessage(context, 'Student deleted successfully');
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void showEditStudentDialog(Student student, int index) {
    // Open a dialog or navigate to an edit screen to update student details.
    // After editing, update the `students` list and call `setState()`.
  }

}
