import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_helper.dart';
import '../models/batch.dart';
import '../constants.dart';

class BatchHelper {

  final FirebaseFirestore _firestore;

  BatchHelper(this._firestore);

  Future<List<Batch>> fetchActiveBatches() async{

    String adminId = await AdminHelper.getLoggedAdminUserId();

    QuerySnapshot querySnapshot = await _firestore
        .collection(K.batchCollection)
        .where(K.adminId, isEqualTo: adminId)
        .where(K.active, isEqualTo: true)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return [];
    }

    List<Batch> batches = await Future.wait(querySnapshot.docs.map((doc) async {
      await resetStudentCount(doc.id);
      DocumentSnapshot updatedDoc = await _firestore
          .collection(K.batchCollection)
          .doc(doc.id)
          .get();
      return Batch.fromFirestore(updatedDoc);
    }));

    return batches;
  }

  Future<void> deleteBatch(Batch batch) async {
    final batchDocRef = _firestore.collection(K.batchCollection).doc(batch.id);
    batchDocRef.delete();

    final staffsInBatch = await _firestore.collection(K.staffAssignmentCollection)
        .where(K.batchId, isEqualTo: batch.id)
        .get();

    for (final doc in staffsInBatch.docs) {
      await doc.reference.delete();
    }
  }

  Future<bool> canDeleteBatch(String batchId) async {
    final studentsInBatch = await _firestore.collection(K.studentBatchCollection)
        .where(K.batchId, isEqualTo: batchId)
        .get();
     return studentsInBatch.docs.isEmpty;
  }

  Future<Batch> createNewBatch(String name, bool active, String courseId, String notes, List<String> scheduleDays, TimeOfDay startTime, TimeOfDay endTime, String address, GeoPoint? location) async{
    Batch newBatch = Batch(
        name: name,
        studentCount: 0,
        active: active,
        courseId: courseId,
        notes: notes,
        scheduleDays: scheduleDays,
        startTime: startTime,
        endTime: endTime,
        address: address,
        location: location);
    DocumentReference docRef = await _firestore.collection(K.batchCollection).add(newBatch.toMap());
    newBatch.id = docRef.id;
    return newBatch;
  }

  Future<void> updateBatch(Batch batch) async {
    final batchDocRef = _firestore
        .collection(K.batchCollection).doc(batch.id);

    await batchDocRef.update(batch.toMap());
  }

  Future<void> updateStudentCount(String batchId, int delta) async {
    final batchDocRef = _firestore.collection(K.batchCollection).doc(batchId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(batchDocRef);
      if (snapshot.exists) {
        final currentCount = snapshot[K.studentCount] ?? 0;
        transaction.update(batchDocRef, {K.studentCount: currentCount + delta});
      }
    });
  }

  Future<void> resetStudentCount(String batchId) async {
    final studentsSnapshot = await _firestore
        .collection(K.studentBatchCollection)
        .where(K.batchId, isEqualTo: batchId)
        .get();

    final count = studentsSnapshot.docs.length;

    await _firestore
        .collection(K.batchCollection)
        .doc(batchId)
        .update({'studentCount': count});
  }
}