import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../helpers/course_helper.dart';
import '../../Utils/ui_utils.dart';

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

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  // Method to fetch courses asynchronously
  Future<void> fetchCourses() async {
    isLoading = true;
    final fetchedCourses = await CourseHelper.getAllCoursesOffered();
    setState(() {
      courses = fetchedCourses;
      isLoading = false;
    });
  }


  // Method to add a new course
  void addCourse() async {
    if (nameController.text.isEmpty || selectedCategory == null) {
      if (mounted) {
        UIUtils.showMessage(context, 'All fields are required!');
      }
      return;
    }

    try {
      isLoading  = true;
      final newCourse = await CourseHelper.addNewCourse(
        nameController.text,
        selectedCategory!,
      );
      setState(() {
        courses.add(newCourse);
        nameController.clear(); // Clear the input field
        selectedCategory = Category.academics;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error', 'Error occurred: $e');
      }
    }
  }

  void deleteCourse(int index) async {
    try {

    bool canDelete = await CourseHelper.canDeleteCourse(courses[index]);
      if (canDelete) {
        await CourseHelper.deleteCourse(courses[index]);
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
        UIUtils.showMessage(context, 'Error occurred: $e');
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
      body: isLoading ?
      Center(
        child: CircularProgressIndicator(), // Show loading indicator
      ) :
      Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form to add new course
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Course Name'),
            ),
            SizedBox(height: 20),
            // Dropdown for category selection
            DropdownButton<Category>(
              value: selectedCategory,
              onChanged: (Category? newCategory) {
                setState(() {
                  selectedCategory = newCategory;
                });
              },
              items: Category.values.map((Category category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.toString().split('.').last),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : addCourse, // Disable button if loading
              child: isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white, // Match button text color
                  strokeWidth: 2,
                ),
              )
                  : Text('Add Course'),
            ),
            SizedBox(height: 20),
            // ListView to display the courses
            Expanded(
              child: courses.isEmpty
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
                    title: Text(courses[index].name),
                    subtitle: Text(courses[index].category.toString().split('.').last),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Handle the delete action
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
                      },
                    ),
                  );
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}
