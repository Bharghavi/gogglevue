import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Utils/time_of_day_utils.dart';

class Batch {
  String? id;
  final String adminId;
  String name;
  int studentCount;
  final String courseId;
  bool active;
  String notes;
  List<String> scheduleDays;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String address;


  Batch({
    this.id,
    required this.adminId,
    required this.name,
    required this.studentCount,
    required this.courseId,
    this.active = true,
    this.notes = '',
    required this.scheduleDays,
    required this.startTime,
    required this.endTime,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'name': name,
      'studentCount': studentCount,
      'courseId': courseId,
      'active' : active,
      'notes': notes,
      'scheduleDays': scheduleDays,
      'startTime': TimeOfDayUtils.timeOfDayToString(startTime),
      'endTime': TimeOfDayUtils.timeOfDayToString(endTime),
      'address': address,
    };
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
      notes: map['notes'] ?? '',
      scheduleDays: List<String>.from(map['scheduleDays']),
      startTime: TimeOfDayUtils.stringToTimeOfDay(map['startTime']),
      endTime: TimeOfDayUtils.stringToTimeOfDay(map['endTime']),
      address: map['address'],
    );
  }
}
