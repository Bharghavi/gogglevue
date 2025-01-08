class Admin {
  late String name;
  late String id;
  late DateTime dob;
  late String address;
  late String email;
  late String phone;

  Admin({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.dob});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'dob': dob.toIso8601String(),
    };
  }
}