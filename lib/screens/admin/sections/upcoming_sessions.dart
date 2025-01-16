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
  List<Batch> today = [];
  List<Batch> tomorrow = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUpcomingSessions();
  }

  Future<void> fetchUpcomingSessions() async {
    setState(() {
      isLoading = true;
    });
    try {
      final upcomingBatches = await UpcomingSessionsHelper.getUpcomingBatches();
      setState(() {
        today = upcomingBatches[0]!;
        tomorrow = upcomingBatches[1]!;
      });

    } catch (e) {
      setState(() {
        today = [];
        tomorrow = [];
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
          : today.isEmpty && tomorrow.isEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No sessions scheduled for today and tomorrow.',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Display today's sessions
          if (today.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Today',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...today.map((session) => ListTile(
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
                      builder: (context) =>
                          StudentBatchPage(batch: session),
                    ),
                  );
                },
                child: const Text('View Details'),
              ),
            )),
          ],

          // Display tomorrow's sessions
          if (tomorrow.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Tomorrow',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...tomorrow.map((session) => ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(session.name),
              subtitle: Text(
                'Tomorrow at ${TimeOfDayUtils.timeOfDayToString(session.startTime)}',
              ),
              trailing: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StudentBatchPage(batch: session),
                    ),
                  );
                },
                child: const Text('View Details'),
              ),
            )),
          ],
        ],
      ),
    );
  }


}
