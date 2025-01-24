import 'package:flutter/material.dart';

import '../../../Utils/time_of_day_utils.dart';
import '../../../helpers/batch_helper.dart';
import '../../../models/batch.dart';

class EditBatchDialog extends StatefulWidget {
  final Batch batch;

  const EditBatchDialog({super.key, required this.batch});

  @override
  EditBatchDialogState createState() => EditBatchDialogState();
}

class EditBatchDialogState extends State<EditBatchDialog> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late List<String> selectedDays;
  final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late TimeOfDay startTime;
  late TimeOfDay endTime;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.batch.name);
    addressController = TextEditingController(text: widget.batch.address);
    selectedDays = widget.batch.scheduleDays;
    startTime = widget.batch.startTime;
    endTime = widget.batch.endTime;
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Batch Details', style: Theme.of(context).textTheme.bodyMedium,),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Batch Name'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text('Select Days of the Week', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: daysOfWeek.map((day) {
                final isSelected = selectedDays.contains(day);
                return ChoiceChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedDays.add(day);
                      } else {
                        selectedDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (picked != null) {
                      setState(() {
                        startTime = picked;
                      });
                    }
                  },
                  child: Text('Start Time: ${TimeOfDayUtils.timeOfDayToString(startTime)}'),
                ),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (picked != null) {
                      setState(() {
                        endTime = picked;
                      });
                    }
                  },
                  child: Text('End Time: ${TimeOfDayUtils.timeOfDayToString(endTime)}'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            widget.batch.name = nameController.text;
            widget.batch.address = addressController.text;
            widget.batch.scheduleDays = selectedDays;
            widget.batch.startTime = startTime;
            widget.batch.endTime = endTime;

            await BatchHelper.updateBatch(widget.batch);

            if (mounted) {
              Navigator.pop(context, widget.batch);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
