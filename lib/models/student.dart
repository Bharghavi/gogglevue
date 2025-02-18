
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String? id;
  String name;
  DateTime? dob;
  String? address;
  String phone;
  String? email;
  String? profilePic;

  Student({
    this.id,
    required this.name,
    this.dob,
    this.email,
    required this.phone,
    this.address,
    this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'profilePic': profilePic,
      'name': name,
      'dob': dob == null ? null : Timestamp.fromDate(dob!),
      'address': address,
      'phone' : phone,
      'email': email,
    };
  }

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      profilePic: map['profilePic'],
      name: map['name'] ?? '',
      dob: map['dob'] == null ? null : (map['dob'] as Timestamp).toDate(),
      address: map['address'],
      email: map['email'],
      phone: map['phone'] ?? '',
    );
  }
}