import 'package:flutter/material.dart';
import '../../../helpers/staff_helper.dart';
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
      final fetchedStaff = await StaffHelper.getStaffForBatch(widget.batch.id!);
      setState(() {
        studentsNotInBatch.addAll(fetchStudentsNotInBatch);
        studentsInBatch.addAll(studentList);
        staffName = fetchedStaff!.name;
        isLoading = false;
      });

    } catch (e) {
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
        return AlertDialog(
          title: Text('Add Student to Batch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Student>(
                items: studentsNotInBatch.map((student) {
                  return DropdownMenuItem<Student>(
                    value: student,
                    child: Text('${student.name} '),
                  );
                }).toList(),
                onChanged: (student) {
                  selectedStudent = student;
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
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      joiningDate = pickedDate;
                    });
                  }
                },
                child: Text(joiningDate == null
                    ? 'Select Joining Date'
                    : 'Joining Date: ${joiningDate.toString().split(' ')[0]}'),
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
                  Navigator.of(context).pop();
                } else {
                  UIUtils.showMessage(
                      context, 'Please select a student and joining date.');
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

   _addStudentAction();
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
        StudentBatchHelper.deleteStudentFromBatch(student.id!, widget.batch.id!).then((_) {
          setState(() {
            studentsInBatch.remove(student);
            studentsNotInBatch.add(student);
            widget.batch.studentCount -= 1;
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
                        //subtitle: Text('Address: ${student.address}'),
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
