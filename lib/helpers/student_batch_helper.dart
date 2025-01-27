import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_helper.dart';
import '../Utils/time_of_day_utils.dart';
import 'admin_helper.dart';
import 'batch_helper.dart';
import '../models/batch.dart';
import '../models/student.dart';
import '../models/student_batch.dart';
import '../constants.dart';

class StudentBatchHelper {

  static Future<List<Student>> fetchAllStudentsFor(String batchId) async{
    final adminId = await AdminHelper.getLoggedAdminUserId();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.studentBatchCollection)
        .where(K.active, isEqualTo: true)
        .where(K.adminId, isEqualTo: adminId)
        .where(K.batchId, isEqualTo: batchId)
        .get();

    List<Student> students = await Future.wait(querySnapshot.docs.map((doc) async {
      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection(K.studentCollection)
          .doc(doc[K.studentId])
          .get();
      return Student.fromFirestore(studentSnapshot);
    }).toList());

    return students;
  }

  static Future<List<Student>> fetchAllStudentsOn(String batchId, DateTime onDate) async {
    final adminId = await AdminHelper.getLoggedAdminUserId();

    DateTime normalizedDate = TimeOfDayUtils.normalizeDate(onDate);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.studentBatchCollection)
        .where(K.active, isEqualTo: true)
        .where(K.adminId, isEqualTo: adminId)
        .where(K.joiningDate, isLessThanOrEqualTo: normalizedDate)
        .where(K.batchId, isEqualTo: batchId)
        .get();

    List<Student> students = await Future.wait(querySnapshot.docs.map((doc) async {
      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection(K.studentCollection)
          .doc(doc[K.studentId])
          .get();
      return Student.fromFirestore(studentSnapshot);
    }).toList());

    return students;
  }

  static Future<List<Student>> fetchAllStudentsNotInBatch(String batchId) async {

    final adminId = await AdminHelper.getLoggedAdminUserId();

    List<Student> studentsInBatch = await fetchAllStudentsFor(batchId);

    if (studentsInBatch.isEmpty) {
      return StudentHelper.fetchAllStudents();
    }

    List<String> studentIdsInBatch = studentsInBatch.map((student) => student.id!).toList();

    Query query = FirebaseFirestore.instance.collection(K.studentCollection)
                  .where(K.adminId, isEqualTo: adminId);

    if (studentIdsInBatch.isNotEmpty) {
      query = query.where(FieldPath.documentId, whereNotIn: studentIdsInBatch);
    }

    QuerySnapshot querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
  }

  static Future<void> deleteStudentFromBatch(String studentId, String batchId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(K.studentBatchCollection)
        .where(K.batchId, isEqualTo: batchId)
        .where(K.studentId, isEqualTo: studentId)
        .get();

    await BatchHelper.updateStudentCount(batchId, -1);
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  static Future<StudentBatch> addStudentToBatch(String studentId, String batchId, DateTime joiningDate) async{

    final adminId = await AdminHelper.getLoggedAdminUserId();

    StudentBatch newStudent = StudentBatch(
      studentId: studentId,
      batchId: batchId,
      adminId: adminId,
      joiningDate: joiningDate,
      active: true
    );
    await BatchHelper.updateStudentCount(batchId, 1);
    await FirebaseFirestore.instance.collection(K.studentBatchCollection).add(newStudent.toMap());
    return newStudent;
  }

  static Future<List<Batch>> getBatchesForStudent(String studentId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(K.studentBatchCollection)
        .where(K.studentId, isEqualTo: studentId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return [];
    }

    List<Batch> result = await Future.wait(querySnapshot.docs.map((doc) async {
      DocumentSnapshot batchSnapshot = await FirebaseFirestore.instance
          .collection(K.batchCollection)
          .doc(doc[K.batchId])
          .get();
      return Batch.fromFirestore(batchSnapshot);
    }).toList());

    return result;
  }

  static Future<DateTime> getStudentJoiningDate(String studentId, String batchId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(K.studentBatchCollection)
        .where(K.studentId, isEqualTo: studentId)
        .where(K.batchId, isEqualTo: batchId)
        .get();

    return (querySnapshot.docs.first[K.joiningDate] as Timestamp).toDate();
  }
}