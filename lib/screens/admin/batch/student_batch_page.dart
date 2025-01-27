import 'package:flutter/material.dart';
import 'package:gogglevue/Utils/time_of_day_utils.dart';
import '../../../helpers/staff_assignment_helper.dart';
import '../../../helpers/batch_helper.dart';
import '/screens/admin/batch/batch_details_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Utils/ui_utils.dart';
import '../../../models/batch.dart';
import '../../../models/student.dart';
import '../../../helpers/student_batch_helper.dart';
import 'edit_batch_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    fetchStudentsForBatch();
  }

  Future<void> fetchStudentsForBatch() async {
    try {
      setState(() {
        isLoading = true;
      });
      final studentList = await StudentBatchHelper.fetchAllStudentsFor(widget.batch.id!);
      final fetchStudentsNotInBatch = await StudentBatchHelper.fetchAllStudentsNotInBatch(widget.batch.id!);
      final fetchedStaff = await StaffAssignmentHelper.getStaffFor(widget.batch.id!, DateTime.now());
      final fetchedFirstDate = await StaffAssignmentHelper.getFirstDateForBatch(widget.batch.id!);
      setState(() {
        studentsNotInBatch.addAll(fetchStudentsNotInBatch);
        studentsInBatch.addAll(studentList);
        if (fetchedStaff != null) {
          staffName = fetchedStaff.name;
        }
        firstDate = fetchedFirstDate;
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
        await StudentBatchHelper.addStudentToBatch(
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

  void _removeBatch(Batch batch) async {
    UIUtils.showConfirmationDialog(context: context,
        title: 'Remove Batch',
        content: 'Are you sure you want to delete this batch?',
        onConfirm: () {
          Navigator.pop(context, batch.id);
          BatchHelper.deleteBatch(batch);
        });
  }


  void _removeStudent(Student student) async {
    UIUtils.showConfirmationDialog(context: context,
        title: 'Remove Student',
        content: 'Are you sure you want to remove ${student.name} from batch?',
        onConfirm: () {
        setState(() {
          isLoading = true;
        });
        StudentBatchHelper.deleteStudentFromBatch(student.id!, widget.batch.id!).then((_) {
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
                       onEdit: () => openEditDialog(context, widget.batch)),
              // Students list section
              Expanded(
                child: studentsInBatch.isEmpty
                    ?
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No students added yet.', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _removeBatch(widget.batch);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Batch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
                    : ListView.builder(
                  itemCount: studentsInBatch.length,
                  itemBuilder: (context, index) {
                    final student = studentsInBatch[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(student.name, style: Theme.of(context).textTheme.bodyMedium,),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // Ensures the row takes up minimal space
                          children: [
                            IconButton(
                              icon: Icon(Icons.call, color: Colors.green),
                              onPressed: () => _makeCall(student.phone),
                            ),
                            IconButton(
                              icon: Icon(color: Colors.blue, Icons.message_rounded),
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

  void openEditDialog(BuildContext context, Batch batch) async {
    final updatedBatch = await showDialog<Batch>(
      context: context,
      builder: (context) => EditBatchDialog(batch: batch),
    );

    if (updatedBatch != null) {
      setState(() {
        batch = updatedBatch;
      });
    }
  }
}
