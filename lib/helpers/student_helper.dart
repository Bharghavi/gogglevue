import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_helper.dart';
import '../models/student.dart';
import '../constants.dart';

class StudentHelper {

  final FirebaseFirestore _firestore;

  StudentHelper(this._firestore);

  Future<List<Student>> fetchAllStudents() async{

    QuerySnapshot querySnapshot = await _firestore.collection(K.studentCollection).get();

    List<Student> students = [];

    if (querySnapshot.docs.isNotEmpty) {
      students = querySnapshot.docs.map((doc) {
        return Student.fromFirestore(doc);
      }).toList();

    }
    return students;
  }

  Future<void> deleteStudent(Student student) async {
    final studentDocRef = _firestore.collection(K.studentCollection).doc(student.id);
    await studentDocRef.delete();
  }

  Future<Map<String, Student>> fetchStudentsByIds(List<String> studentIds) async {
    if (studentIds.isEmpty) return {};
    final snapshot = await _firestore
        .collection(K.studentCollection)
        .where(FieldPath.documentId, whereIn: studentIds)
        .get();

    return {
      for (var doc in snapshot.docs) doc.id: Student.fromFirestore(doc)
    };
  }

  Future<Student> saveNewStudent(String name, String? email, String phone, String? address, DateTime? dob, String? profilePic) async{
   QuerySnapshot querySnapshot = await _firestore.collection(K.studentCollection)
    .where('name', isEqualTo: name)
    .where('phone', isEqualTo: phone)
    .get();

   if (querySnapshot.docs.isNotEmpty) {
     throw Exception('Student with name $name and phone $phone already exist');
   }
    Student newStudent = Student(
        name: name,
        dob: dob,
        email: email,
        phone: phone,
        address: address,
        profilePic: profilePic,
       );
    await _firestore.collection(K.studentCollection).add(newStudent.toMap());
    return newStudent;
  }

  Future<Student?> getStudentForId(String studentId) async{

    final docSnapshot = await _firestore
        .collection(K.studentCollection)
        .doc(studentId).get();

    if (docSnapshot.exists) {
      return Student.fromFirestore(docSnapshot);
    } else {
      return null;
    }
  }
}