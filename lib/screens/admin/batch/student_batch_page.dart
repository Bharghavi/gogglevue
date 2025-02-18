import 'package:Aarambha/Utils/location_utils.dart';
import 'package:Aarambha/managers/database_manager.dart';
import 'package:flutter/material.dart';
import '../../../Utils/time_of_day_utils.dart';
import '../../../helpers/staff_assignment_helper.dart';
import '/screens/admin/batch/batch_details_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Utils/ui_utils.dart';
import '../../../models/batch.dart';
import '../../../models/student.dart';
import '../../../helpers/student_batch_helper.dart';

class StudentBatchPage extends StatefulWidget {
  final Batch batch;

  const StudentBatchPage({super.key, required this.batch});

  @override
  StudentBatchPageState createState() => StudentBatchPageState();
}

class StudentBatchPageState extends State<StudentBatchPage> {
  List<Student> studentsInBatch = [];
  List<Student> studentsNotInBatch = [];
  Student? selectedStudent;
  DateTime? joiningDate;
  bool isLoading = false;
  String staffName = '';
  DateTime firstDate = DateTime(2000);

  late StudentBatchHelper studentBatchHelper;
  late StaffAssignmentHelper staffAssignmentHelper;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final firestore = await DatabaseManager.getAdminDatabase();
    studentBatchHelper = StudentBatchHelper(firestore);
    staffAssignmentHelper = StaffAssignmentHelper(firestore);
    fetchStudentsForBatch();
  }

  Future<void> fetchStudentsForBatch() async {
    try {
      setState(() {
        isLoading = true;
      });
      final studentList = await studentBatchHelper.fetchAllStudentsFor(widget.batch.id!);
      final fetchStudentsNotInBatch = await studentBatchHelper.fetchAllStudentsNotInBatch(widget.batch.id!);
      final fetchedStaff = await staffAssignmentHelper.getStaffFor(widget.batch.id!, DateTime.now());
      setState(() {
        studentsNotInBatch.addAll(fetchStudentsNotInBatch);
        studentsInBatch.addAll(studentList);
        if (fetchedStaff != null) {
          staffName = fetchedStaff.name;
        }
        firstDate = widget.batch.startDate;
        isLoading = false;
      });

    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          UIUtils.showMessage(context, 'Failed to fetch student: $e');
        }
      });
    }
  }

  void _addStudent() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setDialogState) {
            return AlertDialog(
              title: Text(
                'Add Student to Batch',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Student>(
                    value: selectedStudent,
                    items: studentsNotInBatch.map((student) {
                      return DropdownMenuItem<Student>(
                        value: student,
                        child: Text(
                          student.name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
                    onChanged: (student) {
                      setDialogState(() {
                        selectedStudent = student;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Student',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: firstDate,
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          joiningDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      joiningDate == null
                          ? 'Select Joining Date'
                          : 'Joining Date: ${TimeOfDayUtils.dateTimeToString(joiningDate!)}',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedStudent != null && joiningDate != null) {
                      _addStudentAction();
                      Navigator.of(context).pop();
                    } else {
                      UIUtils.showMessage(
                        context, 'Please select a student and joining date.',
                      );
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


  void _addStudentAction() async {
    if (selectedStudent != null && joiningDate != null) {
      setState(() {
        isLoading = true;
      });
      try {
        await studentBatchHelper.addStudentToBatch(
          selectedStudent!.id!,
          widget.batch.id!,
          joiningDate!,
        );
        setState(() {
          widget.batch.studentCount += 1;
          studentsInBatch.add(selectedStudent!);
          studentsNotInBatch.remove(selectedStudent);
          selectedStudent = null;
          joiningDate = null;
          isLoading = false;
        });
        if (mounted) {
          UIUtils.showMessage(context, 'Student added successfully.');
        }

      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          UIUtils.showMessage(context, 'Failed to add student: $e');
        }
      }
    }
  }

  void _removeStudent(Student student) async {
    UIUtils.showConfirmationDialog(context: context,
        title: 'Remove Student',
        content: 'Are you sure you want to remove ${student.name} from batch?',
        onConfirm: () {
        setState(() {
          isLoading = true;
        });
        studentBatchHelper.deleteStudentFromBatch(student.id!, widget.batch.id!).then((_) {
          setState(() {
            studentsInBatch.remove(student);
            studentsNotInBatch.add(student);
            widget.batch.studentCount -= 1;
            isLoading = false;
          });
          if (mounted) {
            UIUtils.showMessage(context, 'Student removed successfully');
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
      appBar: AppBar(
        title: Text('Students in ${widget.batch.name}'),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BatchDetailsCard(batch: widget.batch, staffName: staffName,
                       onEdit: () => openMapLocation(widget.batch)),
              // Students list section
              Expanded(
                child: studentsInBatch.isEmpty
                    ?
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No students added yet.', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                  ],
                )
                    : ListView.builder(
                  itemCount: studentsInBatch.length,
                  itemBuilder: (context, index) {
                    final student = studentsInBatch[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: student.profilePic != null
                            ? CircleAvatar(
                          backgroundImage: NetworkImage(student.profilePic!),
                        )
                            : CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(student.name, style: Theme.of(context).textTheme.bodyMedium,),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // Ensures the row takes up minimal space
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
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeStudent(student),
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
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }

  void openMapLocation(Batch batch) async {
    if (batch.location != null) {
      LocationUtils.openGoogleMaps(batch.location!);
    }
  }
}
