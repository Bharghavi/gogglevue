class Admin {
  late String name;
  late String id;
  late DateTime dob;
  late String address;
  late String phone;
  late String instituteName;
  late String instituteAddress;
  late String? logo;
  late String? profilePic;

  Admin({
    required this.name,
    required this.phone,
    required this.address,
    required this.dob,
    required this.instituteName,
    required this.instituteAddress,
    this.logo,
    this.profilePic,
    });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'dob': dob.toIso8601String(),
      'instituteName': instituteName,
      'instituteAddress' : instituteAddress,
      'logo': logo,
      'profilePic': profilePic,
    };
  }
}