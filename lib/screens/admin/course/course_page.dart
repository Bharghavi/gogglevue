import 'add_course.dart';
import 'package:flutter/material.dart';
import '../../../managers/database_manager.dart';
import '../../../models/course.dart';
import '../../../helpers/course_helper.dart';
import '../../../Utils/ui_utils.dart';

// CoursePage.dart
class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  CoursePageState createState() => CoursePageState();
}

class CoursePageState extends State<CoursePage> {
  List<Course> courses = [];
  final TextEditingController nameController = TextEditingController();
  Category? selectedCategory = Category.academics;
  bool isLoading = false;
  late CourseHelper courseHelper;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final firestore = await DatabaseManager.getAdminDatabase();
    courseHelper = CourseHelper(firestore);
    fetchCourses();
  }

  // Method to fetch courses asynchronously
  Future<void> fetchCourses() async {
    setState(() {
      isLoading = true;
    });
    final fetchedCourses = await courseHelper.getAllCoursesOffered();
    setState(() {
      courses = fetchedCourses;
      isLoading = false;
    });
  }

  void deleteCourse(int index) async {
    try {

    bool canDelete = await courseHelper.canDeleteCourse(courses[index]);
      if (canDelete) {
        await courseHelper.deleteCourse(courses[index]);
        setState(() {
          courses.removeAt(index);
        });
      } else {
        if (mounted) {
          UIUtils.showErrorDialog(
            context,
            'Delete Error',
            "The course '${courses[index]
                .name}' cannot be deleted because there is one or more active batch with the course.",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error occurred', '$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Page'),
        leading: const SizedBox(),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : courses.isEmpty
          ? Center(
        child: Text(
          'No course available',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(courses[index].name, style: Theme.of(context).textTheme.bodyMedium,),
            subtitle: Text(courses[index].category.toString().split('.').last, style: Theme.of(context).textTheme.bodySmall,),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCourse(context, index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCourse = await showDialog(
            context: context,
            builder: (context) => AddCourseDialog(),
          );
          if (newCourse != null) {
            setState(() {
              courses.add(newCourse);
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  Future<void> _deleteCourse(BuildContext context, int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Course'),
        content: Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteCourse(index);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
