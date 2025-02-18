import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker_google/place_picker_google.dart';

import '../../../Utils/location_utils.dart';
import '/managers/database_manager.dart';
import 'package:flutter/material.dart';
import '../../../Utils/time_of_day_utils.dart';
import '../../../helpers/staff_assignment_helper.dart';

import '../../../Utils/ui_utils.dart';
import '../../../helpers/batch_helper.dart';
import '../../../helpers/course_helper.dart';
import '../../../helpers/staff_helper.dart';
import '../../../models/course.dart';
import '../../../models/staff.dart';

class AddBatchPage extends StatefulWidget {
  const AddBatchPage({super.key});

  @override
  AddBatchPageState createState() => AddBatchPageState();
}

class AddBatchPageState extends State<AddBatchPage> {
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  DateTime _startDate = DateTime.now();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? selectedInstructorId;
  String? selectedCourseId;
  Staff? selectedInstructor;
  List<String> instructors = [];
  List<String> courses = [];
  List<Course> fetchedCourses = [];
  List<Staff> fetchedInstructors = [];
  List<String> selectedDays = [];
  final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  GeoPoint? location;

  late BatchHelper batchHelper;
  late CourseHelper courseHelper;
  late StaffHelper staffHelper;
  late StaffAssignmentHelper staffAssignmentHelper;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final firestore = await DatabaseManager.getAdminDatabase();
    batchHelper = BatchHelper(firestore);
    courseHelper = CourseHelper(firestore);
    staffHelper = StaffHelper(firestore);
    staffAssignmentHelper = StaffAssignmentHelper(firestore);
    fetchCourses();
    fetchInstructors();
  }

  Future<void> fetchCourses() async {
    try {
      fetchedCourses = await courseHelper.getAllCoursesOffered();
      setState(() {
        courses = fetchedCourses.map((course) => course.name).toList();
      });
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(
            context, 'Error', 'Error occurred while fetching courses: $e');
      }
    }
  }

  Future<void> fetchInstructors() async {
    try {
      fetchedInstructors = await staffHelper.getAllStaff();
      setState(() {
        instructors = fetchedInstructors.map((staff) => staff.name).toList();
      });
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(
            context, 'Error occurred', 'while fetching instructors $e');
      }
    }
  }

  void _selectStartTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        startTime = pickedTime;
        _startTimeController.text = pickedTime.format(context);
      });
    }
  }

  void _selectEndTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        endTime = pickedTime;
        _endTimeController.text = pickedTime.format(context);
      });
    }
  }

  void _saveBatch() async {
    if (_batchNameController.text.isEmpty) {
      UIUtils.showErrorDialog(context,'Error', 'Batch name is required');
      return;
    }
    if (selectedCourseId == null) {
      UIUtils.showErrorDialog(context,'Error',  'Please select a course.');
      return;
    }
    if (selectedInstructorId == null && selectedInstructor == null) {
      UIUtils.showErrorDialog(context,'Error',  'Please select an instructor.');
      return;
    }
    if (selectedDays.isEmpty) {
      UIUtils.showErrorDialog(context,'Error', 'Please select a schedule.');
      return;
    }

    if(_startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty) {
      UIUtils.showErrorDialog(context,'Error', 'Please select start and end time for the batch');
      return;
    }
    if (_startDate.isBefore(selectedInstructor!.joiningDate)) {
      UIUtils.showErrorDialog(context, 'Error',
          'Batch start date cannot be before staff joining date ${TimeOfDayUtils.dateTimeToString(selectedInstructor!.joiningDate)}');
      return;
    }

    final startDateTime = DateTime(0, 1, 1, startTime!.hour, startTime!.minute);
    final endDateTime = DateTime(0, 1, 1, endTime!.hour, endTime!.minute);

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      UIUtils.showErrorDialog(context, 'Error', 'End time must be after start time.');
      return;
    }
    if (_fromDateController.text.isEmpty) {
      UIUtils.showErrorDialog(context, 'Error', 'Please enter start date');
      return;
    }

    try {
      final newBatch = await batchHelper.createNewBatch(
          _batchNameController.text,
          true,
          selectedCourseId!,
          '',
          selectedDays,
          startTime!,
          endTime!,
          _addressController.text,
          _startDate,
          null,
          location);

      await staffAssignmentHelper.assignStaff(newBatch.id!, selectedInstructorId!, _startDate, null);

      if (mounted) {
        UIUtils.showMessage(context, 'Batch saved successfully');
        Navigator.pop(context, newBatch);
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error saving batch', '$e');
        debugPrint('$e');
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Batch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Batch Name Input
              TextField(
                controller: _batchNameController,
                decoration: InputDecoration(
                  labelText: 'Batch Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Course Dropdown
              DropdownButtonFormField<String>(
                value: selectedCourseId,
                decoration: InputDecoration(
                  labelText: 'Select Course',
                  border: OutlineInputBorder(),
                ),
                items: fetchedCourses.map((course) {
                  return DropdownMenuItem(
                    value: course.courseId,
                    child: Text(course.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCourseId = value;
                  });
                },
              ),
              SizedBox(height: 16),

              Row (
                children: [
                  Expanded (
                    child:  TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _getLocation,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.location_pin),
                      ),
                ],
              ),


              // Schedule Days
              Text('Select Days of the Week', style: Theme.of(context).textTheme.bodyMedium),
              Wrap(
                spacing: 8.0,
                children: daysOfWeek.map((day) {
                  final isSelected = selectedDays.contains(day);
                  return ChoiceChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Start Time Picker
              TextField(
                controller: _startTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectStartTime(_startTimeController),
              ),
              SizedBox(height: 16),

              // End Time Picker
              TextField(
                controller: _endTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'End Time',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectEndTime(_endTimeController),
              ),
              SizedBox(height: 16),

              Text('Instructor Details', style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 8),

              // Instructor Dropdown
              DropdownButtonFormField<Staff>(
                value: selectedInstructor,
                decoration: InputDecoration(
                  labelText: 'Select Coach/Instructor',
                  border: OutlineInputBorder(),
                ),
                items: fetchedInstructors.map((staff) {
                  return DropdownMenuItem(
                    value: staff,
                    child: Text(staff.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      selectedInstructorId = value.id;
                      selectedInstructor = value;
                    }
                  });
                },
              ),
              SizedBox(height: 16),

              // From Date Picker
              TextField(
                controller: _fromDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectFromDate(_fromDateController),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: _saveBatch,
                child: Text('Save Batch'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectFromDate(TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
        controller.text = TimeOfDayUtils.dateTimeToString(selectedDate);
      });
    }
  }

  Future<void> _getLocation() async {

    LocationResult? locationResult = await LocationUtils.pickLocation(
      context, location);

    if (locationResult == null) {
      return;
    }

    if (locationResult.formattedAddress != null &&
        locationResult.latLng != null)  {
      if (!mounted) {
        return;
      }
      setState(() {
        _addressController.text = locationResult.formattedAddress!;
        location = GeoPoint(
            locationResult.latLng!.latitude, locationResult.latLng!.longitude);
      });
    }
  }

}