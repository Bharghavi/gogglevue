import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Batch {
  final String? id;
  final String adminId;
  final String name;
  int studentCount;
  final String courseId;
  final bool active;
  final String instructor;
  final String notes;
  final List<String> scheduleDays;
  final TimeOfDay startTime;
  final TimeOfDay endTime;


  Batch({
    this.id,
    required this.adminId,
    required this.name,
    required this.studentCount,
    required this.courseId,
    this.active = true,
    required this.instructor,
    this.notes = '',
    required this.scheduleDays,
    required this.startTime,
    required this.endTime
  });

  // Method to convert Batch to a Map for database storage (e.g., Firebase)
  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'name': name,
      'studentCount': studentCount,
      'courseId': courseId,
      'active' : active,
      'instructor': instructor,
      'notes': notes,
      'scheduleDays': scheduleDays,
      'startTime': timeOfDayToString(startTime),
      'endTime': timeOfDayToString(endTime),
    };
  }

  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Factory method to create a Batch instance from a Map
  factory Batch.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Batch(
      id: doc.id,
      adminId: map['adminId'] ?? '',
      name: map['name'] ?? '',
      studentCount: map['studentCount'] ?? 0,
      courseId: map['courseId']?? '',
      active: map['active'] ?? true,
      instructor: map['instructor'] ?? '',
      notes: map['notes'] ?? '',
      scheduleDays: List<String>.from(map['scheduleDays']),
      startTime: stringToTimeOfDay(map['startTime']),
      endTime: stringToTimeOfDay(map['endTime']),
    );
  }
}
