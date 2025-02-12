import 'package:flutter/material.dart';
import '../../../managers/database_manager.dart';
import '../../../models/course.dart';
import '../../../helpers/course_helper.dart';
import '../../../Utils/ui_utils.dart';

class AddCourseDialog extends StatefulWidget {
  const AddCourseDialog({super.key});

  @override
  AddCourseDialogState createState() => AddCourseDialogState();
}

class AddCourseDialogState extends State<AddCourseDialog> {
  final TextEditingController nameController = TextEditingController();
  Category? selectedCategory = Category.academics;
  late CourseHelper courseHelper;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final firestore = await DatabaseManager.getAdminDatabase();
    courseHelper = CourseHelper(firestore);
  }

  void addCourse() async {
    if (nameController.text.isEmpty || selectedCategory == null) {
      UIUtils.showErrorDialog(context, 'Missing data', 'All fields are required!');
      return;
    }

    try {
      final newCourse = await courseHelper.addNewCourse(
        nameController.text,
        selectedCategory!,
      );
      if (mounted) {
        UIUtils.showMessage(context, 'Course saved successfully');
        Navigator.pop(context, newCourse);
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error', 'Error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Course', style: Theme.of(context).textTheme.bodyMedium,),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Course Name'),
          ),
          SizedBox(height: 20),
          Column(
            children: Category.values.map((Category category) {
              return RadioListTile<Category>(
                title: Text(category.toString().split('.').last, style: Theme.of(context).textTheme.bodySmall,),
                value: category,
                groupValue: selectedCategory,
                onChanged: (Category? newCategory) {
                  setState(() {
                    selectedCategory = newCategory;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: addCourse,
          child: Text('Add Course'),
        ),
      ],
    );
  }
}
