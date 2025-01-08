import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_helper.dart';
import '../models/student.dart';
import '../constants.dart';

class StudentHelper {

  static Future<List<Student>> fetchAllStudents() async{

    String adminId = await AdminHelper.getLoggedAdminUserId();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.studentCollection)
        .where(K.adminId, isEqualTo: adminId)
        .get();

    List<Student> students = [];

    if (querySnapshot.docs.isNotEmpty) {
      students = querySnapshot.docs.map((doc) {
        return Student.fromFirestore(doc);
      }).toList();

    }
    return students;
  }

  static Future<void> deleteStudent(Student student) async {
    final studentDocRef = FirebaseFirestore.instance.collection(K.studentCollection).doc(student.id);
    studentDocRef.delete();
  }

  static Future<Student> saveNewStudent(String name,DateTime dob, String address, String phone, String email) async{
    String adminId = await AdminHelper.getLoggedAdminUserId();
    Student newStudent = Student(
        adminId: adminId,
        name: name,
        dob: dob,
        email: email,
        phone: phone,
        address: address,
       );
    await FirebaseFirestore.instance.collection(K.studentCollection).add(newStudent.toMap());
    return newStudent;
  }

  static Future<Student?> getStudentForId(String studentId) async{

    final docSnapshot = await FirebaseFirestore.instance
        .collection(K.studentCollection)
        .doc(studentId).get();

    if (docSnapshot.exists) {
      return Student.fromFirestore(docSnapshot);
    } else {
      return null;
    }
  }
}