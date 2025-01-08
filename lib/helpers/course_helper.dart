import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_helper.dart';
import '../models/course.dart';
import '../constants.dart';

class CourseHelper {

  static Future<List<Course>> getAllCoursesOffered() async{

    String adminId = await AdminHelper.getLoggedAdminUserId();

    QuerySnapshot courseQuerySnapshot = await FirebaseFirestore.instance
        .collection(K.courseCollection)
        .where(K.adminId, isEqualTo: adminId)
        .get();

    List<Course> courses = [];

    if (courseQuerySnapshot.docs.isNotEmpty) {
      courses = courseQuerySnapshot.docs.map((doc) {
        return Course.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

    }
    return courses;
  }

  static Future<bool> canDeleteCourse(Course course) async {
    QuerySnapshot batchQuerySnapshot = await FirebaseFirestore.instance.collection(K.batchCollection)
    .where(K.courseId, isEqualTo: course.courseId!)
    .where(K.active, isEqualTo: true)
        .get();
    print('course id: ${course.courseId}');
    print('${batchQuerySnapshot.docs.isEmpty}');
    return batchQuerySnapshot.docs.isEmpty;
  }

  static Future<void> deleteCourse(Course course) async {
    final docRef = await FirebaseFirestore.instance.collection(K.courseCollection).doc(course.courseId!);
    docRef.delete();
  }

  static Future<Course> addNewCourse(String courseName, Category category) async{
    String adminId = await AdminHelper.getLoggedAdminUserId();
    Course newCourse = Course(name: courseName, category: category, adminId: adminId);
    await FirebaseFirestore.instance.collection(K.courseCollection).add(newCourse.toMap());
    return newCourse;
  }
}