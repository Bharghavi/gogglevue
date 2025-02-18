import 'package:Aarambha/managers/database_manager.dart';
import 'package:flutter/material.dart';
import '../../Utils/time_of_day_utils.dart';
import '../../helpers/lesson_plan_helper.dart';
import '../../helpers/student_batch_helper.dart';
import '../../Utils/ui_utils.dart';
import '../../models/batch.dart';
import '../../models/student.dart';

class LessonPlanPage extends StatefulWidget {
  final Batch batch;
  const LessonPlanPage({super.key, required this.batch});

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
  bool isLoading = false;

  List<Student> _students = [];
  late StudentBatchHelper studentBatchHelper;

  @override
  void initState() {
    super.initState();
   initialize();
  }

  Future<void> initialize() async {
    final firestore = await DatabaseManager.getAdminDatabase();
    studentBatchHelper = StudentBatchHelper(firestore);
    _selectedBatch = widget.batch;
    fetchStudents(_selectedBatch!.id!);
  }

  Future<void> fetchStudents(String batchId) async {
    setState(() {
      isLoading = true;
    });
    try {
      final students = await studentBatchHelper.fetchAllStudentsFor(batchId);
      setState(() {
        _students = students;
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      if (mounted) {
        UIUtils.showErrorDialog(context,'Error', 'Failed to fetch students: $e');
      }
    }
  }

  Future<void> fetchLessonPlan() async {
    if (_selectedStudent == null) return;

    setState(() {
      isLoading = true;
    });

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
        UIUtils.showErrorDialog(context,'Error', 'Failed to fetch lesson plan: $e');
      }
    } finally {
      isLoading = false;
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
      appBar: AppBar(
        title: Text('Lesson Plan for ${widget.batch.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Date:', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                TextButton(
                  onPressed: _selectDate,
                  child: Text(
                    TimeOfDayUtils.dateTimeToString(_selectedDate),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_selectedBatch != null) ...[
              DropdownButton<Student>(
                value: _selectedStudent,
                hint: Text('Select Student'),
                isExpanded: true,
                items: _students.map((student) {
                  return DropdownMenuItem(
                    value: student,
                    child: Text(student.name, style: Theme.of(context).textTheme.bodyMedium,),
                  );
                }).toList(),
                onChanged: _onStudentSelected,
              ),
              SizedBox(height: 16),
            ],
            TextField(
              controller: _lessonController,
              decoration: InputDecoration(
                labelText: 'Add Lesson',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addLesson,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _lessons.length,
                itemBuilder: (context, index) => _buildLessonTile(index),
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _isSaveEnabled() ? _saveLessonPlan : null,
                child: Text('Save Lesson Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
      fetchLessonPlan();
    }
  }

  void _onStudentSelected(Student? student) async {
    setState(() {
      _selectedStudent = student;
      _lessons.clear();
    });
    if (student != null) await fetchLessonPlan();
  }

  void _addLesson() {
    if (_lessonController.text.isNotEmpty &&
        !_lessons.contains(_lessonController.text)) {
      setState(() {
        _lessons.add(_lessonController.text);
        _lessonController.clear();
      });
    }
  }

  Widget _buildLessonTile(int index) {
    return ListTile(
      title: Text(_lessons[index], style: Theme.of(context).textTheme.bodySmall,),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => setState(() => _lessons.removeAt(index)),
      ),
    );
  }

  void _saveLessonPlan() async {
    try {
      await LessonPlanHelper.saveLessonPlan(
          _selectedStudent!.id!, _selectedDate, _lessons);
      setState(() {
        _originalLessons = List.from(_lessons);
      });
      if (mounted) {
        UIUtils.showMessage(context, 'Lesson Plan saved successfully');
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showMessage(context, 'Failed to save lesson plan: $e');
      }
    }
  }

}
