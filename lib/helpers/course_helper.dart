import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../constants.dart';

class CourseHelper {

  final FirebaseFirestore _firestore;
  CourseHelper(this._firestore);

  Future<List<Course>> getAllCoursesOffered() async{

    QuerySnapshot courseQuerySnapshot = await _firestore
        .collection(K.courseCollection)
        .get();

    List<Course> courses = [];

    if (courseQuerySnapshot.docs.isNotEmpty) {
      courses = courseQuerySnapshot.docs.map((doc) {
        return Course.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

    }
    return courses;
  }

  Future<bool> canDeleteCourse(Course course) async {
    QuerySnapshot batchQuerySnapshot = await _firestore.collection(K.batchCollection)
    .where(K.courseId, isEqualTo: course.courseId!)
    .where(K.active, isEqualTo: true)
        .get();
    return batchQuerySnapshot.docs.isEmpty;
  }

  Future<void> deleteCourse(Course course) async {
    final docRef = _firestore.collection(K.courseCollection).doc(course.courseId!);
    await docRef.delete();
  }

  Future<Course> addNewCourse(String courseName, Category category) async{
    Course newCourse = Course(name: courseName, category: category);
    DocumentReference docRef = await _firestore.collection(K.courseCollection).add(newCourse.toMap());
    newCourse = Course(courseId: docRef.id, name: courseName, category: category);
    return newCourse;
  }
}