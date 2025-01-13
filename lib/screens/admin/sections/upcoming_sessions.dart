import 'package:flutter/material.dart';
import '../../../helpers/upcoming_sessions_helper.dart';
import '../../../Utils/time_of_day_utils.dart';
import '../../../models/batch.dart';
import '../student_batch_page.dart';

class UpcomingSessionsSection extends StatefulWidget {
  const UpcomingSessionsSection({super.key});

  @override
  UpcomingSessionsSectionState createState() =>
      UpcomingSessionsSectionState();
}

class UpcomingSessionsSectionState extends State<UpcomingSessionsSection> {
  List<Batch> sessions = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSessionsForToday();
  }

  Future<void> fetchSessionsForToday() async {
    setState(() {
      isLoading = true;
    });

    try {
      final batchForToday = await UpcomingSessionsHelper.getBatchesForToday();
      setState(() {
        sessions = batchForToday;
      });
    } catch (e) {
      setState(() {
        sessions = []; // Reset sessions in case of an error
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : sessions.isEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No sessions scheduled for today.',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(session.name),
            subtitle: Text(
              'Today at ${TimeOfDayUtils.timeOfDayToString(session.startTime)}',
            ),
            trailing: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentBatchPage(batch: session),
                  ),
                );
              },
              child: const Text('View Details'),
            ),
          );
        },
      ),
    );
  }

}
