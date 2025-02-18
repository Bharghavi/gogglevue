import 'add_student_dialog.dart';

import '../../../Utils/image_utils.dart';
import '/managers/database_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/models/student.dart';
import '/helpers/student_helper.dart';
import '/Utils/ui_utils.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  StudentPageState createState() => StudentPageState();
}

class StudentPageState extends State<StudentPage> {
  List<Student> students = [];

  late StudentHelper studentHelper;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final firestore = await DatabaseManager.getAdminDatabase();
    studentHelper = StudentHelper(firestore);
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final studentList = await studentHelper.fetchAllStudents();
      setState(() {
        students = studentList;
      });
    } catch (e) {
      if (mounted) {
        UIUtils.showMessage(context, 'Failed to fetch student: $e');
      }
    }
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
                'No student added',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(student.name, style: Theme.of(context).textTheme.bodyMedium,),
                        subtitle:
                            Text('Phone: ${student.phone}', style: Theme.of(context).textTheme.bodySmall,),
                        leading:student.profilePic == null || student.profilePic!.isEmpty
                            ? const Icon(Icons.person, size: 50)  // Default icon for missing profile pic
                            : ImageUtils.getClipRRectImage(student.profilePic!),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.call, color: Colors.green),
                            onPressed: () => _makeCall(student.phone),
                          ),
                          IconButton(
                            icon: Image.asset(
                              'assets/icon/WhatsApp_icon.png',
                              width: 24,
                              height: 24,
                            ),
                            onPressed: () => _sendMessage(student.phone),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              showEditStudentDialog(student, index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteStudent(index);
                            },
                          ),
                        ],
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
        onPressed: () async {
          final newStudent = await showDialog(
            context: context,
            builder: (context) => AddStudentDialog(),
          );
          if (newStudent != null) {
            setState(() {
              students.add(newStudent);
            });
          }
        },
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
  void deleteStudent(int index) {
    UIUtils.showConfirmationDialog(
      context: context,
      title: 'Delete Student',
      content: 'Are you sure you want to delete ${students[index].name}?',
      onConfirm: () async {
            await studentHelper.deleteStudent(students[index]);
            setState(() {
              students.removeAt(index);
            });

            UIUtils.showMessage(context, 'Student deleted successfully');
          }
    );
  }

  void showEditStudentDialog(Student student, int index) {
    // Open a dialog or navigate to an edit screen to update student details.
    // After editing, update the `students` list and call `setState()`.
  }

}
