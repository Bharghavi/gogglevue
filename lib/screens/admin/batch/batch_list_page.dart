import 'package:flutter/material.dart';
import 'add_batch_page.dart';
import '../lesson_plan_page.dart';
import 'edit_batch_dialog.dart';
import 'student_batch_page.dart';
import '../../../Utils/ui_utils.dart';
import '../../../helpers/batch_helper.dart';
import '../../../models/batch.dart';
import '../attendance/student_attendance_page.dart';

class BatchListPage extends StatefulWidget {
  final String destinationPage;
  const BatchListPage({super.key, required this.destinationPage});

  @override
  BatchListPageState createState() => BatchListPageState();
}

class BatchListPageState extends State<BatchListPage> {
  List<Batch> batches = [];
  bool isLoading = false;
  String title = 'Batches';

  @override
  void initState() {
    super.initState();
    fetchBatch();
    setTitle();
  }

  @override
  void didUpdateWidget(covariant BatchListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinationPage != widget.destinationPage) {
      setTitle();
    }
    fetchBatch();
  }

  void setTitle() {
    setState(() {
      switch (widget.destinationPage) {
        case 'attendance':
          title = 'Mark Attendance';
          break;
        case 'batchDetails':
          title = 'Batch Details';
          break;
        case 'lessonPlan':
          title = 'Add Lesson Plan';
          break;
        default:
          title = 'Batches';
          break;
      }
    });
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
      appBar: AppBar(
        title: Text(title),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    onTap: () async {
                      switch(widget.destinationPage) {
                        case 'attendance':  Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StudentAttendancePage(batch: batch),
                          ),
                        );
                        break;

                        case 'batchDetails': String? deletedBatchId = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StudentBatchPage(batch: batch),
                          ),
                        );
                        if (deletedBatchId != null) {
                          setState(() {
                            batches.removeWhere((b) => b.id == deletedBatchId);
                          });
                        }
                        break;

                        case 'lessonPlan': Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LessonPlanPage(batch: batch),
                          ),
                        );
                      }
                    },
                  trailing: widget.destinationPage == 'batchDetails' ?
                Row(
                mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue,),
                      onPressed: () => {openEditDialog(context, batch )},),
                    IconButton(
                    icon: Icon(Icons.delete, color: Colors.red,),
                    onPressed: () => {_removeBatch(batch)},),
                  ],
                ) :
                  null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.destinationPage == 'batchDetails'
          ? FloatingActionButton(
        onPressed: () async {
          final newBatch = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBatchPage(),
            ),
          );
          if (newBatch != null) {
            setState(() {
              batches.add(newBatch);
            });
          }
        } ,
        child: const Icon(Icons.add, color: Colors.white,),
      )
          : null,
    );
  }

  void _removeBatch(Batch batch) async {
    bool canDeleteFromDb = await BatchHelper.canDeleteBatch(batch.id!);

    if (!canDeleteFromDb) {
      UIUtils.showErrorDialog(context, 'Delete batch', 'You cannot delete a batch with active students');
      return;
    }

    UIUtils.showConfirmationDialog(context: context,
        title: 'Remove Batch',
        content: 'Are you sure you want to delete this batch?',
        onConfirm: () {
          BatchHelper.deleteBatch(batch);
          UIUtils.showMessage(context, 'Batch deleted successfully');
          setState(() {
            batches.remove(batch);
          });
        });
  }

  void openEditDialog(BuildContext context, Batch batch) async {
    final updatedBatch = await showDialog<Batch>(
      context: context,
      builder: (context) => EditBatchDialog(batch: batch),
    );

    if (updatedBatch != null) {
      setState(() {
        batch = updatedBatch;
      });
    }
  }
}