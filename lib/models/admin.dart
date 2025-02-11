import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  late String name;
  late String id;
  late DateTime dob;
  late String address;
  late String phone;
  late String instituteName;
  late String instituteId;
  late String instituteAddress;
  late String? logo;
  late String? profilePic;
  late GeoPoint? location;

  Admin({
    required this.name,
    required this.phone,
    required this.address,
    required this.dob,
    required this.instituteName,
    required this.instituteAddress,
    required this.instituteId,
    this.logo,
    this.profilePic,
    this.location,
    });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'dob': dob.toIso8601String(),
      'instituteName': instituteName,
      'instituteId' : instituteId,
      'instituteAddress' : instituteAddress,
      'logo': logo,
      'profilePic': profilePic,
      'location': location,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      dob: DateTime.parse(map['dob']),
      instituteName: map['instituteName'],
      instituteId: map['instituteId'],
      instituteAddress: map['instituteAddress'],
      logo: map['logo'],
      profilePic: map['profilePic'],
      location: map['location'] != null
          ? map['location'] as GeoPoint
          : null,
    );
  }
}