import 'package:cloud_firestore/cloud_firestore.dart';

class LessonPlan {
  String? id;
  final String studentId;
  final DateTime date;
  List<String> lessons;

  LessonPlan({
    this.id,
    required this.studentId,
    required this.date,
    required this.lessons,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'lessons': lessons,
    };
  }

  factory LessonPlan.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return LessonPlan(
      id: doc.id,
      studentId: map['studentId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      lessons: List<String>.from(map['lessons']),
    );
  }
}