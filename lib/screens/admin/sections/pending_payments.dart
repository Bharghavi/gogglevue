import 'package:flutter/material.dart';
import '../../../Utils/time_of_day_utils.dart';
import '../../../helpers/payment_helper.dart';
import '../../../Utils/contact_utils.dart';
import '../../../helpers/batch_helper.dart';
import '../../../helpers/student_helper.dart';
import '../../../models/payment.dart';
import '../../../models/student.dart';
import '../payments/add_payments.dart';

class PendingPaymentsSection extends StatefulWidget {
  const PendingPaymentsSection({super.key});

  @override
  PendingPaymentsSectionState createState() => PendingPaymentsSectionState();
}

class PendingPaymentsSectionState extends State<PendingPaymentsSection> {
  List<Payment> overdue = [];
  Map<String, Student> studentMap = {};
  Map<String, String> batchMap = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOverduePayments();
  }

  void fetchOverduePayments() async {
    setState(() {
      isLoading = true;
    });

    final fetchedPayments = await PaymentHelper.getPaymentOverdue();
    final studentIds =
        fetchedPayments.map((payment) => payment.studentId).toSet().toList();
    final fetchedStudents = await StudentHelper.fetchStudentsByIds(studentIds);
    final batches = await BatchHelper.fetchActiveBatches();

    setState(() {
      isLoading = false;
      overdue = fetchedPayments;
      studentMap = fetchedStudents;
      batchMap = {for (var batch in batches) batch.id!: batch.name};
    });
  }

  String getPaymentDueMessage(Payment payment) {
    String message = 'Hi ${studentMap[payment.studentId]!.name},\n '
        'Your payment is due from ${TimeOfDayUtils.dateTimeToString(payment.validTo)}.\n Please make the payment at the earliest. Thanks.';
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : overdue.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'There are no pending payments',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: overdue.length,
                  itemBuilder: (context, index) {
                    final payment = overdue[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Grouping the icon and name close together
                          Row(
                            children: [
                              const Icon(Icons.currency_rupee_rounded, color: Colors.red),
                              const SizedBox(width: 8), // Add some spacing between the icon and name
                              Text(
                                studentMap[payment.studentId]!.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          // Adding some space before the "View Details" button
                          TextButton(
                            onPressed: () => _viewDetailsButtonPressed(payment),
                            child: const Text('View Details'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  void _viewDetailsButtonPressed(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(studentMap[payment.studentId]!.name,
            style: Theme.of(context).textTheme.bodyMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Batch: ${batchMap[payment.batchId]!}', style: Theme.of(context).textTheme.bodySmall,),
            Text(
                'Previous Payment: ${TimeOfDayUtils.dateTimeToString(payment.validTo)}',
                 style: Theme.of(context).textTheme.bodySmall),
            if (payment.note != null && payment.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Note: ${payment.note!}',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: IconButton(
                  icon: Icon(Icons.call, color: Colors.green),
                  onPressed: () => ContactUtils.makeCall(
                    studentMap[payment.studentId]!.phone,
                      context
                  ),
                ),
              ),
              Flexible(
                child: IconButton(
                  icon: Image.asset(
                    'assets/icon/WhatsApp_icon.png',
                    width: 24.0,
                    height: 24.0,
                  ),
                  onPressed: () {
                    ContactUtils.sendMessage(
                      studentMap[payment.studentId]!.phone,
                      message: getPaymentDueMessage(payment),
                    );
                    setState(() {
                      payment.note =
                      'Reminder sent on ${TimeOfDayUtils.dateTimeToString(DateTime.now())}';
                    });
                    PaymentHelper.savePaymentNote(payment);
                  },
                ),
              ),
              Flexible(
                child: TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPaymentPage(
                          selectedStudent: payment.studentId,
                          selectedBatch: payment.batchId,
                        ),
                      ),
                    );
                    if (result == true) {
                      fetchOverduePayments();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Mark as Paid'),
                ),
              ),
              Flexible(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
