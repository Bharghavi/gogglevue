import 'package:gogglevue/helpers/batch_helper.dart';
import 'package:intl/intl.dart';
import '../models/batch.dart';

class UpcomingSessionsHelper {

  static Future<List<Map<String, dynamic>>>  buildUpcomingSessions() async {

    List<Batch> batches = await BatchHelper.fetchActiveBatches();

    print('${batches.length} batches fetched');

    Map<String, int> dayToIndex = {
      "Sun": 0,
      "Mon": 1,
      "Tue": 2,
      "Wed": 3,
      "Thu": 4,
      "Fri": 5,
      "Sat": 6,
    };

    // Get today's day and index
    String today = DateFormat('E').format(DateTime.now()); // e.g., "Mon"
    int todayIndex = dayToIndex[today]!;

    // Process batches
    List<Map<String, dynamic>> upcomingSessions = [];
    for (var batch in batches) {
      // Filter and sort scheduleDays
      List<String> upcomingDays = batch.scheduleDays
          .where((day) => dayToIndex[day]! >= todayIndex)
          .toList()
        ..sort((a, b) => dayToIndex[a]!.compareTo(dayToIndex[b]!));

      if (upcomingDays.isNotEmpty) {
        upcomingSessions.add({
          "batchName": batch.name,
          "upcomingDays": upcomingDays,
        });
      }
    }

    return upcomingSessions;
  }

  static Future<List<Batch>> getBatchesForToday() async {
    List<Batch> batches = await BatchHelper.fetchActiveBatches();
    String today = DateFormat('E').format(DateTime.now());

    List<Batch> result = batches.where((batch) {
      return batch.scheduleDays.contains(today);
    }).toList();

    return result;
  }

}