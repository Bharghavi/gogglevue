import 'package:Aarambha/managers/database_manager.dart';
import 'package:flutter/material.dart';
import '../batch/batch_details_card.dart';
import '../../../helpers/staff_assignment_helper.dart';
import '../../../helpers/staff_helper.dart';
import '../../../helpers/attendance_helper.dart';
import '../../../Utils/date_selector.dart';
import '../../../Utils/ui_utils.dart';
import '../../../helpers/student_batch_helper.dart';
import '../../../models/attendance.dart';
import '../../../models/batch.dart';
import '../../../models/staff.dart';
import '../../../models/student.dart';
import 'attendance_calendar.dart';

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
  DateTime? batchStartDate;
  bool isPresent = false;
  Attendance? attendance;
  Map<String, bool> studentAttendance = {};
  String? _selectedStaffId;
  List<Staff> _staffList = [];
  bool _isSessionCancelled = false;
  String? _cancellationReason;
  Batch? batch;
  String staffName = '';

  late StaffHelper staffHelper;
  late StudentBatchHelper studentBatchHelper;
  late StaffAssignmentHelper staffAssignmentHelper;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    batch = widget.batch;
    final firestore = await DatabaseManager.getAdminDatabase();
    staffHelper = StaffHelper(firestore);
    studentBatchHelper = StudentBatchHelper(firestore);
    staffAssignmentHelper = StaffAssignmentHelper(firestore);
    fetchAndSetAttendance(selectedDate);
    fetchStudentsForBatch(selectedDate);
  }

  Future<void> fetchStudentsForBatch(DateTime date) async {
    try {
      setState(() {
        isLoading = true;
      });
      final studentList =
          await studentBatchHelper.fetchAllStudentsOn(batch!.id!, date);
      final staff = await staffAssignmentHelper.getStaffFor(widget.batch.id!, date);
      final List<Staff> list = await staffHelper.getAllStaff();
      setState(() {
        studentsInBatch = [];
        studentsInBatch.addAll(studentList);
        _staffList = list;
        if (staff != null) {
          _selectedStaffId = staff.id;
          staffName = staff.name;
        }
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
    final startDate = await staffAssignmentHelper.getFirstDateForBatch(batch!.id!);
    setState(() {
      selectedDate = date;
      attendance = fetchedAttendance;
      batchStartDate = startDate;
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
        title: Text('Attendance for ${batch!.name}'),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BatchDetailsCard(
                batch: batch!,
                staffName: staffName,
                onEdit: () {},
              ),

              // Calendar Widget Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DateSelector(
                  firstDate: batchStartDate,
                  initialDate: selectedDate,
                  onDateChanged: (date) async {
                    fetchAndSetAttendance(date);
                    fetchStudentsForBatch(date);
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
                        value: _selectedStaffId,
                        hint: Text('Select Instructor'),
                        isExpanded: true,
                        items: _staffList.map((staff) {
                          return DropdownMenuItem(
                            value: staff.id,
                            child: Text(
                              staff.name,
                              style: Theme.of(context).textTheme.bodySmall,
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

              // Show a loading spinner or content
              if (isLoading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      if (_isSessionCancelled)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Reason:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            SizedBox(height: 8),
                            Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    'Staff not available',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
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
                                  title: Text(
                                    'Students not available',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
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
                                  title: Text(
                                    'Vacation / public holiday',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
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

                      if (!_isSessionCancelled)
                        Expanded(
                          child: studentsInBatch.isEmpty
                              ? Center(
                            child: Text('No students added in this batch.'),
                          )
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
                                      IconButton(
                                        icon: Icon(Icons.calendar_month, color: Colors.blue),
                                        onPressed: () {
                                          _showCalendarDialog(context, student.id!);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

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

  Future<void> _showCalendarDialog(BuildContext context, String studentId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 300, // Explicit width
            height: 400, // Explicit height
            child: AttendanceCalendar(studentId: studentId, batchId: batch!.id!),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
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
      if (selectedDate.isAfter(DateTime.now())) {
        if (studentAttendance.containsValue(true)) {
          UIUtils.showErrorDialog(
            context,
            'Invalid Date Selection',
            'You cannot mark attendance as present for a future date. Please choose a valid date.',
          );
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
