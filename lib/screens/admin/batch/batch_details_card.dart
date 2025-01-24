import 'package:flutter/material.dart';
import '../../../helpers/staff_helper.dart';
import '../../../Utils/time_of_day_utils.dart';
import '../../../models/batch.dart';

class BatchDetailsCard extends StatelessWidget {
  final Batch batch;
  final String staffName;
  final VoidCallback onEdit;

  const BatchDetailsCard({super.key, required this.batch, required this.staffName, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Location: ${batch.address}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Days: ${batch.scheduleDays.join(", ")}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Time: ${TimeOfDayUtils.timeOfDayToString(batch.startTime)} - ${TimeOfDayUtils.timeOfDayToString(batch.endTime)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Instructor: $staffName',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}