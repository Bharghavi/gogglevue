import 'package:flutter/material.dart';
import '../../../helpers/staff_helper.dart';
import '../../../helpers/attendance_helper.dart';
import '../../../Utils/date_selector.dart';
import '../../../Utils/time_of_day_utils.dart';
import '../../../Utils/ui_utils.dart';
import '../../../helpers/student_batch_helper.dart';
import '../../../models/attendance.dart';
import '../../../models/batch.dart';
import '../../../models/staff.dart';
import '../../../models/student.dart';

class StudentAttendancePage extends StatefulWidget {
  final Batch batch;

  const StudentAttendancePage({super.key, required this.batch});

  @override
  StudentAttendancePageState createState() => StudentAttendancePageState();
}

class StudentAttendancePageState extends State<StudentAttendancePage> {
  List<Student> studentsInBatch = [];
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();
  bool isPresent = false;
  Attendance? attendance;
  Map<String, bool> studentAttendance = {};
  String? _selectedStaffId;
  List<Staff> _staffList = [];
  bool _isSessionCancelled = false;
  String? _cancellationReason;
  Batch? batch;

  @override
  void initState() {
    super.initState();
    batch = widget.batch;
    fetchAndSetAttendance(selectedDate);
    fetchStudentsForBatch();
  }

  Future<void> fetchStudentsForBatch() async {
    try {
      setState(() {
        isLoading = true;
      });
      final studentList =
          await StudentBatchHelper.fetchAllStudentsFor(batch!.id!);
      final staff = await StaffHelper.getStaffForBatch(batch!.id!);
      final List<Staff> list = await StaffHelper.getAllStaff();
      setState(() {
        studentsInBatch.addAll(studentList);
        _selectedStaffId = staff?.id;
        _staffList = list;
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

  Future<void> fetchAndSetAttendance(DateTime date) async{
    final fetchedAttendance =
    await AttendanceHelper.fetchAttendanceForBatch(
        batch!.id!, date);
    setState(() {
      selectedDate = date;
      attendance = fetchedAttendance;
      if (fetchedAttendance != null) {
        _isSessionCancelled = fetchedAttendance.isSessionCancelled;
        _cancellationReason = fetchedAttendance.cancelReason;
        studentAttendance = fetchedAttendance.studentAttendance;
      } else {
        _isSessionCancelled = false;
        _cancellationReason = null;
        studentAttendance = {};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students in ${batch!.name}'),
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
                    // Batch details section
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Batch Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Location: ${batch!.address}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Days: ${batch!.scheduleDays.join(", ")}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Time: ${TimeOfDayUtils.timeOfDayToString(batch!.startTime)} - ${TimeOfDayUtils.timeOfDayToString(batch!.endTime)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Calendar Widget Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DateSelector(
                        initialDate: selectedDate,
                        onDateChanged: (date) async {
                          fetchAndSetAttendance(date);
                        },
                      ),
                    ),

                    // Single checkbox for "Session Cancelled"
                    CheckboxListTile(
                      title: Text(
                        'Session Cancelled',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      value: _isSessionCancelled,
                      onChanged: (isChecked) {
                        setState(() {
                          _isSessionCancelled = isChecked!;
                          if (!_isSessionCancelled) {
                            _cancellationReason = null;
                          }
                        });
                      },
                    ),

                    // Dropdown for Selecting Staff
                    if (!_isSessionCancelled)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Instructor:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(width: 8),

                          // Dropdown for Staff
                          Expanded(
                            child: DropdownButton<String>(
                              value:
                                  _selectedStaffId,
                              hint: Text('Select Instructor'),
                              isExpanded: true,
                              items: _staffList.map((staff) {
                                return DropdownMenuItem(
                                  value: staff.id,
                                  child: Text(
                                    staff.name,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStaffId = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                    if (_isSessionCancelled)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Reason:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          SizedBox(height: 8),

                          // Radio button group
                          Column(
                            children: [
                              ListTile(
                                title: Text('Staff not available', style: Theme.of(context).textTheme.bodySmall),
                                leading: Radio<String>(
                                  value: 'Staff not available',
                                  groupValue: _cancellationReason,
                                  onChanged: (value) {
                                    setState(() {
                                      _cancellationReason = value!;
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                title: Text('Students not available', style: Theme.of(context).textTheme.bodySmall,),
                                leading: Radio<String>(
                                  value: 'Students not available',
                                  groupValue: _cancellationReason,
                                  onChanged: (value) {
                                    setState(() {
                                      _cancellationReason = value!;
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                title: Text('Vacation / public holiday', style: Theme.of(context).textTheme.bodySmall),
                                leading: Radio<String>(
                                  value: 'Vacation / public holiday',
                                  groupValue: _cancellationReason,
                                  onChanged: (value) {
                                    setState(() {
                                      _cancellationReason = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    // Students list section
                    Expanded(
                      child: Column(
                        children: [
                          // Students list section
                          if (!_isSessionCancelled)
                            Expanded(
                              child: studentsInBatch.isEmpty
                                  ? Center(
                                      child: Text(
                                          'No students added in this batch.'))
                                  : ListView.builder(
                                itemCount: studentsInBatch.length,
                                itemBuilder: (context, index) {
                                  final student = studentsInBatch[index];
                                  return Card(
                                    margin: EdgeInsets.all(8),
                                    child: ListTile(
                                      leading: Icon(Icons.person),
                                      title: Text(
                                        student.name,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Absent',
                                            style: TextStyle(
                                              color: studentAttendance[student.id] == false
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                          ),
                                          Switch(
                                            value: studentAttendance[student.id] ?? false,
                                            activeColor: Colors.green,
                                            inactiveThumbColor: Colors.red,
                                            onChanged: (isPresent) {
                                              setState(() {
                                                studentAttendance[student.id!] = isPresent;
                                              });
                                            },
                                          ),
                                          Text(
                                            'Present',
                                            style: TextStyle(
                                              color: studentAttendance[student.id] == true
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                            ),

                          // Save Button
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                _saveAttendance();
                              },
                              child: Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _saveAttendance() async {
    if (!_isSessionCancelled) {
      for (Student student in studentsInBatch) {
        if (!studentAttendance.containsKey(student.id)) {
          UIUtils.showErrorDialog(context, 'Mark Attendance',
              'Kindly mark attendance for the student ${student.name}');
          return;
        }
      }
    } else {
      if(_cancellationReason == null || _cancellationReason == '') {
        UIUtils.showErrorDialog(context, 'Cancel Reason',
            'Please select a reason for session cancellation');
        return;
      }
    }
    try {
      await AttendanceHelper.saveAttendance(_selectedStaffId!,
          batch!.id!,
          selectedDate,
          _isSessionCancelled,
          _cancellationReason,
          studentAttendance);
      if (mounted) {
        UIUtils.showMessage(context, 'Attendance saved successfully');
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error', 'Error occurred while saving attendance: $e');
      }
    }
  }
}
