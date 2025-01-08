
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String? id;
  final String name;
  final DateTime dob;
  final String address;
  final String phone;
  final String email;
  final String adminId;

  Student({
    this.id,
    required this.name,
    required this.dob,
    required this.email,
    required this.phone,
    required this.address,
    required this.adminId,
  });

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'name': name,
      'dob': Timestamp.fromDate(dob),
      'address': address,
      'phone' : phone,
      'email': email,
    };
  }

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      adminId: map['adminId'] ?? '',
      name: map['name'] ?? '',
      dob: (map['dob'] as Timestamp).toDate(),
      address: map['address']?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}