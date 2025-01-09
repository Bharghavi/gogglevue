import 'package:flutter/material.dart';
import '../../helpers/lesson_plan_helper.dart';
import '../../helpers/student_batch_helper.dart';

import '../../Utils/ui_utils.dart';
import '../../helpers/batch_helper.dart';
import '../../models/batch.dart';
import '../../models/student.dart';

class LessonPlanPage extends StatefulWidget {
  const LessonPlanPage({super.key});

  @override
  LessonPlanPageState createState() => LessonPlanPageState();
}

class LessonPlanPageState extends State<LessonPlanPage> {
  DateTime _selectedDate = DateTime.now();
  Batch? _selectedBatch;
  Student? _selectedStudent;
  List<String> _lessons = [];
  List<String> _originalLessons = [];
  final TextEditingController _lessonController = TextEditingController();

  List<Batch> _batches = [];
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    fetchBatches();
  }

  Future<void> fetchBatches() async {
    try {
      final batchList = await BatchHelper.fetchActiveBatches();
      setState(() {
        _batches = batchList;
      });
    } catch (e) {
      if (mounted) {
        UIUtils.showMessage(context, 'Failed to fetch batches: $e');
      }
    }
  }

  Future<void> fetchStudents(String batchId) async {
    try {
      final students = await StudentBatchHelper.fetchAllStudentsFor(batchId);
      setState(() {
        _students = students;
      });
    } catch (e) {
      if (mounted) {
        print(e);
        UIUtils.showMessage(context, 'Failed to fetch students: $e');
      }
    }
  }

  Future<void> fetchLessonPlan() async {
    if (_selectedStudent == null) return;

    try {
      final lessonPlan = await LessonPlanHelper.fetchLessonPlanFor(
          _selectedStudent!.id!, _selectedDate);

      if (lessonPlan != null) {
        setState(() {
          _originalLessons = List.from(lessonPlan.lessons);
          _lessons = List.from(lessonPlan.lessons);
        });
      } else {
        setState(() {
          _originalLessons = [];
          _lessons = [];
        });
      }
    } catch (e) {
      if (mounted) {
        print(e);
        UIUtils.showMessage(context, 'Failed to fetch lesson plan: $e');
      }
    }
  }

  bool _isSaveEnabled() {
    return _selectedBatch != null &&
        _selectedStudent != null &&
        _lessons.isNotEmpty &&
        !_listEquals(_lessons, _originalLessons);
  }

  bool _listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Lesson Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Date Picker
            Row(
              children: [
                Text('Date:', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                      fetchLessonPlan();
                    }
                  },
                  child: Text(
                    '${_selectedDate.toLocal()}'.split(' ')[0],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            // Dropdown for Batches
            DropdownButton<Batch>(
              value: _selectedBatch,
              hint: Text('Select Batch'),
              isExpanded: true,
              items: _batches.map((batch) {
                return DropdownMenuItem(
                  value: batch,
                  child: Text(batch.name),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() {
                  _selectedBatch = value;
                  _selectedStudent = null;
                  _students.clear();
                  _lessons.clear();
                });
                if (_selectedBatch != null) {
                  await fetchStudents(_selectedBatch!.id!);
                }
              },
            ),

            SizedBox(height: 16),

            // Dropdown for Students
            if (_selectedBatch != null)
              DropdownButton<Student>(
                value: _selectedStudent,
                hint: Text('Select Student'),
                isExpanded: true,
                items: _students.map((student) {
                  return DropdownMenuItem(
                    value: student,
                    child: Text(student.name),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedStudent = value;
                    _lessons.clear();
                  });
                  await fetchLessonPlan();
                },
              ),

            SizedBox(height: 16),

            // Lessons Input
            TextField(
              controller: _lessonController,
              decoration: InputDecoration(
                labelText: 'Add Lesson',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_lessonController.text.isNotEmpty) {
                      setState(() {
                        _lessons.add(_lessonController.text);
                        _lessonController.clear();
                      });
                    }
                  },
                ),
              ),
            ),

            // List of Lessons
            Expanded(
              child: ListView.builder(
                itemCount: _lessons.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_lessons[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _lessons.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Save Button
            ElevatedButton(
              onPressed: _isSaveEnabled()
                  ? () async {
                      try {
                        await LessonPlanHelper.saveLessonPlan(
                            _selectedStudent!.id!, _selectedDate, _lessons);
                        setState(() {
                          _originalLessons = List.from(_lessons);
                        });
                        if (mounted) {
                          UIUtils.showMessage(
                              context, 'Lesson Plan saved successfully');
                        }
                      } catch (e) {
                        if (mounted) {
                          UIUtils.showMessage(
                              context, 'Failed to save lesson plan: $e');
                        }
                      }
                    }
                  : null,
              // style: ButtonStyle(
              //   backgroundColor: WidgetStateProperty.resolveWith<Color>(
              //     (states) => _isSaveEnabled()
              //         ? Theme.of(context).primaryColor
              //         : Colors.grey, // Gray out button when disabled
              //   ),
              // ),
              child: Text('Save Lesson Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
