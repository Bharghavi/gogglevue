import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_helper.dart';
import '../models/batch.dart';
import '../constants.dart';

class BatchHelper {

  static Future<List<Batch>> fetchActiveBatches() async{

    String adminId = await AdminHelper.getLoggedAdminUserId();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(K.batchCollection)
        .where(K.adminId, isEqualTo: adminId)
        .where(K.active, isEqualTo: true)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return [];
    }

    List<Batch> batches = await Future.wait(querySnapshot.docs.map((doc) async {
      await resetStudentCount(doc.id);
      DocumentSnapshot updatedDoc = await FirebaseFirestore.instance
          .collection(K.batchCollection)
          .doc(doc.id)
          .get();
      return Batch.fromFirestore(updatedDoc);
    }));

    return batches;
  }

  static Future<void> deleteBatch(Batch batch) async {
    final batchDocRef = FirebaseFirestore.instance.collection(K.batchCollection).doc(batch.id);
    batchDocRef.delete();
  }

  static Future<Batch> createNewBatch(String name, bool active, String courseId, String notes, List<String> scheduleDays, TimeOfDay startTime, TimeOfDay endTime, String address) async{
    String adminId = await AdminHelper.getLoggedAdminUserId();
    Batch newBatch = Batch(
        adminId: adminId,
        name: name,
        studentCount: 0,
        active: active,
        courseId: courseId,
        notes: notes,
        scheduleDays: scheduleDays,
        startTime: startTime,
        endTime: endTime,
        address: address);
    DocumentReference docRef = await FirebaseFirestore.instance.collection(K.batchCollection).add(newBatch.toMap());
    newBatch.id = docRef.id;
    return newBatch;
  }

  static Future<void> updateBatch(Batch batch) async {
    final batchDocRef = FirebaseFirestore.instance
        .collection(K.batchCollection).doc(batch.id);

    await batchDocRef.update(batch.toMap());
  }

  static Future<void> updateStudentCount(String batchId, int delta) async {
    final batchDocRef = FirebaseFirestore.instance.collection(K.batchCollection).doc(batchId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(batchDocRef);
      if (snapshot.exists) {
        final currentCount = snapshot[K.studentCount] ?? 0;
        transaction.update(batchDocRef, {K.studentCount: currentCount + delta});
      }
    });
  }

  static Future<void> resetStudentCount(String batchId) async {
    final studentsSnapshot = await FirebaseFirestore.instance
        .collection(K.studentBatchCollection)
        .where(K.batchId, isEqualTo: batchId)
        .get();

    final count = studentsSnapshot.docs.length;

    await FirebaseFirestore.instance
        .collection(K.batchCollection)
        .doc(batchId)
        .update({'studentCount': count});
  }
}