import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gogglevue/Utils/time_of_day_utils.dart';

import '../constants.dart';
import '../models/lesson_plan.dart';

class LessonPlanHelper {

  static Future<LessonPlan?> fetchLessonPlanFor(String studentId, DateTime date) async {
      final normalizedDate = TimeOfDayUtils.normalizeDate(date);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(K.lessonPlanCollection)
          .where(K.studentId, isEqualTo: studentId)
          .where(K.date, isEqualTo: normalizedDate)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return LessonPlan.fromFirestore(querySnapshot.docs.first);
      } else {
        return null;
      }
  }

  static Future<void> saveLessonPlan(String studentId, DateTime date, List<String> lessons) async {
    final normalizedDate = TimeOfDayUtils.normalizeDate(date);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.lessonPlanCollection)
        .where(K.studentId, isEqualTo: studentId)
        .where(K.date, isEqualTo: normalizedDate)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      String docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection(K.lessonPlanCollection)
          .doc(docId)
          .update({
        K.lessons: lessons,
      });
    } else {
      await FirebaseFirestore.instance.collection(K.lessonPlanCollection).add({
        K.studentId: studentId,
        K.date: normalizedDate,
        K.lessons: lessons,
      });
    }
  }
}