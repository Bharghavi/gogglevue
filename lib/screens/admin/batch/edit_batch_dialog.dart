import 'package:flutter/material.dart';
import '../../../helpers/staff_helper.dart';
import '../../../helpers/staff_assignment_helper.dart';

import '../../../Utils/time_of_day_utils.dart';
import '../../../helpers/batch_helper.dart';
import '../../../managers/database_manager.dart';
import '../../../models/batch.dart';
import '../../../models/staff.dart';

class EditBatchDialog extends StatefulWidget {
  final Batch batch;

  const EditBatchDialog({super.key, required this.batch});

  @override
  EditBatchDialogState createState() => EditBatchDialogState();
}

class EditBatchDialogState extends State<EditBatchDialog> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  List<String> selectedDays = [];
  final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();

  String? selectedInstructorId;
  DateTime _startDate = DateTime.now();
  List<Staff> fetchedInstructors = [];
  late BatchHelper batchHelper;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final firestore = await DatabaseManager.getAdminDatabase();
    batchHelper = BatchHelper(firestore);
    final currentStaff = await StaffAssignmentHelper.getStaffFor(widget.batch.id!, DateTime.now());
    final staffList = await StaffHelper.getAllStaff();
    setState(() {
      nameController = TextEditingController(text: widget.batch.name);
      addressController = TextEditingController(text: widget.batch.address);
      selectedDays = widget.batch.scheduleDays;
      startTime = widget.batch.startTime;
      endTime = widget.batch.endTime;
      fetchedInstructors = staffList;

      if (currentStaff != null) {
        selectedInstructorId = currentStaff.id;
      }
    });
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
      title: Text(
        'Edit Batch Details',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Batch Name'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 8),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 16),
            Text(
              'Select Days of the Week',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                Expanded(
                  child: TextButton(
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
                    child: Text(
                      'Start Time: ${TimeOfDayUtils.timeOfDayToString(startTime)}',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextButton(
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
                    child: Text(
                      'End Time: ${TimeOfDayUtils.timeOfDayToString(endTime)}',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Change Instructor Details',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedInstructorId,
              decoration: InputDecoration(
                labelText: 'Select Coach/Instructor',
                border: OutlineInputBorder(),
              ),
              items: fetchedInstructors.map((staff) {
                return DropdownMenuItem(
                  value: staff.id,
                  child: Text(staff.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedInstructorId = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _fromDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectFromDate(_fromDateController),
                ),
              ),
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

            await batchHelper.updateBatch(widget.batch);
            await StaffAssignmentHelper.assignStaff(
              widget.batch.id!,
              selectedInstructorId!,
              _startDate,
              null,
            );

            if (mounted) {
              Navigator.pop(context, widget.batch);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }


  void _selectFromDate(TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
        controller.text = TimeOfDayUtils.dateTimeToString(selectedDate);
      });
    }
  }
}
