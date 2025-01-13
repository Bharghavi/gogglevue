import 'package:flutter/material.dart';
import '../../helpers/course_helper.dart';
import '../../helpers/staff_helper.dart';
import '../../models/batch.dart';
import '../../helpers/batch_helper.dart';
import '../../Utils/ui_utils.dart';
import '../../models/course.dart';
import '../../models/staff.dart';
import 'student_batch_page.dart';

class BatchPage extends StatefulWidget {
  const BatchPage({super.key});

  @override
  BatchPageState createState() => BatchPageState();

}

class BatchPageState extends State<BatchPage> {
  List<Batch> batches = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBatch();
  }

  Future<void> fetchBatch() async {
    setState(() {
      isLoading = true;
    });
    try {
      final batchList = await BatchHelper.fetchActiveBatches();
      setState(() {
        batches = batchList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error while fetching batch', '$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  isLoading
        ? Center(
        child: CircularProgressIndicator(), // Show loading indicator
          )
        : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Batches',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Content
          Expanded(
            child: batches.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _navigateToAddBatch(context),
                    child: Text('Add Your First Batch'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: batches.length,
              itemBuilder: (context, index) {
                final batch = batches[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(batch.name),
                    subtitle: Text('${batch.studentCount} students'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editBatch(context, batch),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteBatch(index),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentBatchPage(batch: batch),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddBatch(context),
        child: Icon(Icons.add),
      ),
    );
  }


  void _navigateToAddBatch(BuildContext context) async {
    final newBatch = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddBatchPage()),
    );

    if (newBatch != null) {
      setState(() {
        batches.add(newBatch);
      });
    }
  }

  void _editBatch(BuildContext context, Batch batch) {
    // Implement edit batch logic
  }

  void _deleteBatch(int index) {
    UIUtils.showConfirmationDialog(context: context,
        title: 'Delete batch',
        content: 'Are you sure you want to delete the batch ${batches[index].name}',
        onConfirm: () {
          if (batches[index].studentCount > 0) {
            if (mounted) {
              UIUtils.showErrorDialog(
                  context, 'Delete Error',
                  'Cannot delete batch with existing students.');
            }
            return;
          }
          BatchHelper.deleteBatch(batches[index]).then((_) {
            setState(() {
              batches.removeAt(index);
            });
            if (mounted) {
              UIUtils.showMessage(context, 'Batch deleted successfully');
            }
          }).catchError((e) {
            if (mounted) {
              UIUtils.showErrorDialog(context, 'Error occurred', '$e');
            }
          });
        }
    );
  }
}

class AddBatchPage extends StatefulWidget {
  const AddBatchPage({super.key});

  @override
  AddBatchPageState createState() => AddBatchPageState();
}

class AddBatchPageState extends State<AddBatchPage> {
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController _addressController = TextEditingController();

  String? selectedInstructorId;
  String? selectedCourseId;
  List<String> instructors = [];
  List<String> courses = [];
  List<Course> fetchedCourses = [];
  List<Staff> fetchedInstructors = [];
  List<String> selectedDays = [];
  final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchInstructors();
  }

  Future<void> fetchCourses() async {
    try {
      fetchedCourses = await CourseHelper.getAllCoursesOffered();
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
      fetchedInstructors = await StaffHelper.getAllStaff();
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
      UIUtils.showMessage(context, 'Batch name is required');
      return;
    }
    if (selectedCourseId == null) {
      UIUtils.showMessage(context, 'Please select a course.');
      return;
    }
    if (selectedInstructorId == null) {
      UIUtils.showMessage(context, 'Please select an instructor.');
      return;
    }
    if (selectedDays.isEmpty) {
      UIUtils.showMessage(context, 'Please select a schedule.');
      return;
    }

    if(_startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty) {
      UIUtils.showMessage(context, 'Please select start and end time for the batch');
      return;
    }

    final startDateTime = DateTime(0, 1, 1, startTime!.hour, startTime!.minute);
    final endDateTime = DateTime(0, 1, 1, endTime!.hour, endTime!.minute);

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      UIUtils.showMessage(context, 'End time must be after start time.');
      return;
    }

    try {
      final newBatch = await BatchHelper.saveBatch(
          _batchNameController.text,
          true,
          selectedInstructorId!,
          selectedCourseId!,
          '',
          selectedDays,
          startTime!,
          endTime!,
          _addressController.text);

      if (mounted) {
        UIUtils.showMessage(context, 'Batch saved successfully');
        Navigator.pop(context, newBatch);
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error saving batch', '$e');
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

              // Instructor Dropdown
              DropdownButtonFormField<String>(
                value: selectedInstructorId,
                decoration: InputDecoration(
                  labelText: 'Select Coach/Instructor',
                  border: OutlineInputBorder(),
                ),
                items: fetchedInstructors.map((staff) {
                  return DropdownMenuItem(
                    value: staff.id,
                    child: Text(staff.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedInstructorId = value;
                  });
                },
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

              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Schedule Days
              Text('Select Days of the Week', style: TextStyle(fontWeight: FontWeight.bold)),
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
}