import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_helper.dart';
import '../Utils/time_of_day_utils.dart';
import '../models/batch.dart';
import '../models/student.dart';
import '../models/student_batch.dart';
import '../constants.dart';

class StudentBatchHelper {

  final FirebaseFirestore _firestore;

  StudentBatchHelper(this._firestore);

  Future<List<Student>> fetchAllStudentsFor(String batchId) async{

    QuerySnapshot querySnapshot = await _firestore
        .collection(K.studentBatchCollection)
        .where(K.active, isEqualTo: true)
        .where(K.batchId, isEqualTo: batchId)
        .get();

    List<Student> students = await Future.wait(querySnapshot.docs.map((doc) async {
      DocumentSnapshot studentSnapshot = await _firestore
          .collection(K.studentCollection)
          .doc(doc[K.studentId])
          .get();
      return Student.fromFirestore(studentSnapshot);
    }).toList());

    return students;
  }

  Future<List<Student>> fetchAllStudentsOn(String batchId, DateTime onDate) async {
    DateTime normalizedDate = TimeOfDayUtils.normalizeDate(onDate);

    QuerySnapshot querySnapshot = await _firestore
        .collection(K.studentBatchCollection)
        .where(K.active, isEqualTo: true)
        .where(K.joiningDate, isLessThanOrEqualTo: normalizedDate)
        .where(K.batchId, isEqualTo: batchId)
        .get();

    List<Student> students = await Future.wait(querySnapshot.docs.map((doc) async {
      DocumentSnapshot studentSnapshot = await _firestore
          .collection(K.studentCollection)
          .doc(doc[K.studentId])
          .get();
      return Student.fromFirestore(studentSnapshot);
    }).toList());

    return students;
  }

  Future<List<Student>> fetchAllStudentsNotInBatch(String batchId) async {

    List<Student> studentsInBatch = await fetchAllStudentsFor(batchId);
    StudentHelper studentHelper = StudentHelper(_firestore);

    if (studentsInBatch.isEmpty) {
      return studentHelper.fetchAllStudents();
    }

    List<String> studentIdsInBatch = studentsInBatch.map((student) => student.id!).toList();

    Query query = _firestore.collection(K.studentCollection);

    if (studentIdsInBatch.isNotEmpty) {
      query = query.where(FieldPath.documentId, whereNotIn: studentIdsInBatch);
    }

    QuerySnapshot querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
  }

  Future<void> deleteStudentFromBatch(String studentId, String batchId) async {
    final querySnapshot = await _firestore
        .collection(K.studentBatchCollection)
        .where(K.batchId, isEqualTo: batchId)
        .where(K.studentId, isEqualTo: studentId)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<StudentBatch> addStudentToBatch(String studentId, String batchId, DateTime joiningDate) async{

    StudentBatch newStudent = StudentBatch(
      studentId: studentId,
      batchId: batchId,
      joiningDate: joiningDate,
      active: true
    );
    await _firestore.collection(K.studentBatchCollection).add(newStudent.toMap());
    return newStudent;
  }

   Future<List<Batch>> getBatchesForStudent(String studentId) async {
    final querySnapshot = await _firestore
        .collection(K.studentBatchCollection)
        .where(K.studentId, isEqualTo: studentId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return [];
    }

    List<Batch> result = await Future.wait(querySnapshot.docs.map((doc) async {
      DocumentSnapshot batchSnapshot = await _firestore
          .collection(K.batchCollection)
          .doc(doc[K.batchId])
          .get();
      return Batch.fromFirestore(batchSnapshot);
    }).toList());

    return result;
  }

  Future<DateTime> getStudentJoiningDate(String studentId, String batchId) async {
    final querySnapshot = await _firestore
        .collection(K.studentBatchCollection)
        .where(K.studentId, isEqualTo: studentId)
        .where(K.batchId, isEqualTo: batchId)
        .get();

    return (querySnapshot.docs.first[K.joiningDate] as Timestamp).toDate();
  }
}