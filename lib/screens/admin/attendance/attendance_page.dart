import 'package:flutter/material.dart';
import 'student_attendance_page.dart';
import '../../../Utils/ui_utils.dart';
import '../../../helpers/batch_helper.dart';
import '../../../models/batch.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  AttendancePageState createState() => AttendancePageState();
}

class AttendancePageState extends State<AttendancePage> {
  List<Batch> batches = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBatch();
  }

  Future<void> fetchBatch() async {
    setState(() {
      isLoading = true;
    });
    try {
      final batchList = await BatchHelper.fetchActiveBatches();
      setState(() {
        batches = batchList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error while fetching batch', '$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Batches',
            ),
          ),
          // Content
          Expanded(
            child: batches.isEmpty
                ? Center(
                child: Text('No batches added')
            )
                : ListView.builder(
              itemCount: batches.length,
              itemBuilder: (context, index) {
                final batch = batches[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(batch.name, style: Theme.of(context).textTheme.bodyMedium,),
                    subtitle: Text(batch.address, style: Theme.of(context).textTheme.bodySmall),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentAttendancePage(batch: batch),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
