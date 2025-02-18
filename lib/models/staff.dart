import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  String name;
  final String? id;
  DateTime? dob;
  String? address;
  String? email;
  String phone;
  String? profilePic;
  DateTime joiningDate;
  double monthlyPayment;


  Staff({
    required this.name,
    this.id,
    this.email,
    required this.phone,
    this.address,
    this.dob,
    this.profilePic,
    required this.joiningDate,
    required this.monthlyPayment,
  });

  factory Staff.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Staff(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address']?? '',
      dob: data['dob'] == null ? null : (data['dob'] as Timestamp).toDate(),
      profilePic: data['profilePic']?? '',
      joiningDate: (data['joiningDate'] as Timestamp).toDate(),
      monthlyPayment: data['monthlyPayment']?? 0.0 ,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'dob': dob == null ? null : Timestamp.fromDate(dob!),
      'profilePic': profilePic,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'monthlyPayment': monthlyPayment,
    };
  }
}