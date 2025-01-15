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
  PendingPaymentsSectionState createState() =>
      PendingPaymentsSectionState();
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
    final studentIds = fetchedPayments.map((payment) => payment.studentId).toSet().toList();
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
          final textStyle = const TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.currency_rupee_rounded, color: Colors.red), // Leading icon
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentMap[payment.studentId]!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Text(batchMap[payment.batchId]!, style: textStyle),
                      const SizedBox(height: 8.0),
                      Text('previous payment: ${TimeOfDayUtils.dateTimeToString(payment.validTo)}', style: textStyle,),
                      const SizedBox(height: 8.0),
                      if (payment.note != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            payment.note!,
                            style: textStyle
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(Icons.call, color: Colors.green),
                            onPressed: () => ContactUtils.makeCall(
                              studentMap[payment.studentId]!.phone,
                            ),
                          ),
                          IconButton(
                            icon: Image.asset(
                              'assets/icon/WhatsApp_icon.png',
                              width: 24.0,
                              height: 24.0,
                            ),
                            onPressed: () => {
                              ContactUtils.sendMessage(
                                studentMap[payment.studentId]!.phone,
                                message: getPaymentDueMessage(payment),
                              ),
                              setState(() {
                                payment.note = 'Reminder sent on ${TimeOfDayUtils.dateTimeToString(DateTime.now())}';
                               }),
                              PaymentHelper.savePaymentNote(payment),
                            }
                          ),
                          TextButton(
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
                            },
                            child: const Text('Mark as Paid'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}