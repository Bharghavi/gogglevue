import 'package:Aarambha/Utils/time_of_day_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff.dart';
import '../constants.dart';

class StaffHelper {

  final FirebaseFirestore _firestore;

  StaffHelper(this._firestore);

  Future<List<Staff>> getAllStaff() async{

    QuerySnapshot querySnapshot = await _firestore.collection(K.staffCollection).get();
    List<Staff> staffList = [];

    if (querySnapshot.docs.isNotEmpty) {
      staffList = querySnapshot.docs.map((doc) {
        return Staff.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

    }
    return staffList;
  }

  Future<Staff> addNewStaff(String name, String? email, String phone, String? address, DateTime? dob, DateTime joiningDate, double salary) async{
    QuerySnapshot qs = await _firestore.collection(K.staffCollection).where('phone', isEqualTo: phone).get();
    if (qs.docs.isNotEmpty) {
      throw Exception('Staff with phone number $phone already exist');
    }

    DateTime normalizedDate = TimeOfDayUtils.normalizeDate(joiningDate);

    Staff newStaff = Staff(name: name,
                          email: email,
                          phone: phone,
                          address: address,
                          dob: dob,
                          joiningDate: normalizedDate,
                          monthlyPayment: salary);

    await _firestore.collection(K.staffCollection).add(newStaff.toMap());
    return newStaff;
  }

  Future<void> deleteStaff(Staff staff) async {
    final staffDocRef = _firestore.collection(K.staffCollection).doc(staff.id);
    await staffDocRef.delete();
  }

  Future<Staff?> getStaffForId(String staffId) async{
    final staffDocRef = _firestore.collection(K.staffCollection).doc(staffId);
    final staffSnapshot = await staffDocRef.get();
    if (staffSnapshot.exists) {
      return Staff.fromFirestore(staffSnapshot.data() as Map<String, dynamic>, staffId);
    }
    return null;
  }
}