import 'package:flutter/material.dart';
import '../../../Utils/time_of_day_utils.dart';
import '../../../helpers/batch_helper.dart';
import '../../../helpers/student_helper.dart';
import '../../../Utils/ui_utils.dart';
import '../../../helpers/payment_helper.dart';
import '../../../models/payment.dart';
import '../../../models/student.dart';
import 'add_payments.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  Map<String, String> studentMap = {};
  Map<String, String> batchMap = {};

  List<Payment> allPayments = [];

  String? selectedStudent;
  List<Student> students = [];
  DateTime? startDate;
  DateTime? endDate;

  List<Payment> filteredPayments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
    fetchPayments();

  }

  Future<void> fetchStudents() async {
    try {
      setState(() {
        isLoading = true;
      });
      final fetchedStudents = await StudentHelper.fetchAllStudents();
      final batches = await BatchHelper.fetchActiveBatches();
      setState(() {
        students = fetchedStudents;
        studentMap = {for (var student in students) student.id!: student.name};
        batchMap = {for (var batch in batches) batch.id!: batch.name};
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          UIUtils.showErrorDialog(
              context, 'Error', 'Failed to fetch student: $e');
        }
      });
    }
  }


  Future<void> fetchPayments() async {
    try{
      setState(() {
        isLoading = true;
      });
      final fetchedPayments = await PaymentHelper.fetchAllPayments();
      setState(() {
        allPayments = fetchedPayments;
        filteredPayments = List.from(allPayments);
      });
    } catch(e) {
      setState(() {
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          UIUtils.showErrorDialog(context,'Error', 'Failed to fetch payment: $e');
        }
      });
    }


  }

  // Apply filters
  void applyFilters() async {
    setState(() {
      isLoading = true;
    });
    List<Payment> afterFilters = [];
    //endDate ??= DateTime.now();
    if (selectedStudent != null && startDate != null && endDate != null) {
      afterFilters = await PaymentHelper.fetchPaymentsBetweenDatesForStudent(selectedStudent!, startDate!, endDate!);
    } else if (selectedStudent == null && startDate != null && endDate != null) {
      afterFilters = await PaymentHelper.fetchPaymentsBetweenDates(startDate!, endDate!);
    } else if (selectedStudent != null && startDate == null && endDate == null) {
      afterFilters = await PaymentHelper.fetchPaymentsForStudent(selectedStudent!);
    }else {
      afterFilters = allPayments;
    }
    setState(() {
      filteredPayments = afterFilters;
      isLoading = false;
    });
  }

  // Date Picker
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, ValueChanged<DateTime?> onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payments"),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filters Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Dropdown on First Line
                DropdownButtonFormField<String>(
                  value: selectedStudent,
                  decoration: InputDecoration(labelText: "Select Student"),
                  items: [
                      DropdownMenuItem<String>(
                      value: null,
                      child: Text("Any"), // Add the "Any" option
                    ),
                  ...students.map((student) {
                    return DropdownMenuItem<String>(
                      value: student.id,
                      child: Text(student.name),
                    );
                  })
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStudent = value;
                      applyFilters();
                    });
                  },
                ),
                SizedBox(height: 16),

                // Date Filters
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(
                          "Start Date: ${startDate != null ? startDate!.toLocal().toString().split(' ')[0] : "Any"}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  startDate = null; // Reset start date
                                  applyFilters();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context, startDate, (date) {
                                setState(() {
                                  startDate = date;
                                  applyFilters();
                                });
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(
                          "End Date: ${endDate != null ? endDate!.toLocal().toString().split(' ')[0] : "Any"}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  endDate = null; // Reset end date
                                  applyFilters();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context, endDate, (date) {
                                setState(() {
                                  endDate = date;
                                  applyFilters();
                                });
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),
            // List of Payments
            Expanded(
              child: isLoading? Center(
                child: CircularProgressIndicator()
              ) :
              filteredPayments.isNotEmpty
                  ? ListView.builder(
                itemCount: filteredPayments.length,
                itemBuilder: (context, index) {
                  final payment = filteredPayments[index];
                  return Card(
                    child: ListTile(
                      title: Text("Student: ${studentMap[payment.studentId]}"),
                      subtitle: Text(
                        "Batch: ${batchMap[payment.batchId]}\n"
                            "Amount: \$${payment.amount}\n"
                            "Paid Date: ${TimeOfDayUtils.dateTimeToString(payment.paymentDate)}",
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              )
                  : Center(
                child: Text("No payments found for the selected filters."),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPaymentPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

}

