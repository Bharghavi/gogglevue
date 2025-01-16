import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/batch.dart';

class UpcomingSessionsHelper {

  static Future<Map<int,List<Batch>>> getUpcomingBatches() async {

    Map<int,List<Batch>> result = {};

    List<Batch> today = await _getBatchesForDay(0);
    List<Batch> tomorrow = await _getBatchesForDay(1);

    result[0] = today;
    result[1] = tomorrow;

    return result;
  }

  static Future<List<Batch>> _getBatchesForDay(int dayOffset) async {
    DateTime targetDate = DateTime.now().add(Duration(days: dayOffset));
    String targetDay = DateFormat('E').format(targetDate);

    String? now = (dayOffset == 0)
        ? DateFormat('HH:mm').format(DateTime.now())
        : null;

    Query query = FirebaseFirestore.instance
        .collection(K.batchCollection)
        .where(K.scheduleDays, arrayContains: targetDay);

    if (now != null) {
      query = query.where('startTime', isGreaterThan: now);
    }

    query = query.orderBy('startTime');

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => Batch.fromFirestore(doc)).toList();
  }
}