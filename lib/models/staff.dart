import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  final String name;
  final String? id;
  final DateTime dob;
  final String address;
  final String email;
  final String phone;
  final String adminId;

  Staff({
    required this.name,
    this.id,
    required this.email,
    required this.phone,
    required this.address,
    required this.dob,
    required this.adminId
  });

  factory Staff.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Staff(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address']?? '',
      dob: (data['dob'] as Timestamp).toDate(),
      adminId: data['adminId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'dob': Timestamp.fromDate(dob),
      'adminId': adminId,
    };
  }
}