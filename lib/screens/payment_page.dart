import 'package:flutter/material.dart';
import '../Utils/ui_utils.dart';
import '../helpers/payment_helper.dart';
import '../models/batch.dart';
import '../models/payment.dart';

import '../models/student.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  List<Payment> allPayments = [];

  // Filters
  String? selectedStudent;
  List<Student> students = [];
  DateTime? startDate;
  DateTime? endDate;

  List<Payment> filteredPayments = [];

  @override
  void initState() {
    super.initState();
    filteredPayments = List.from(allPayments);
  }

  // Apply filters
  void applyFilters() {
    setState(() async {
      if (selectedStudent != null && startDate != null && endDate != null) {
        filteredPayments = await PaymentHelper.fetchPaymentsBetweenDatesForStudent(selectedStudent!, startDate!, endDate!);
      } else if (selectedStudent == null && startDate != null && endDate != null) {
        filteredPayments = await PaymentHelper.fetchPaymentsBetweenDates(startDate!, endDate!);
      }
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filters Section
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStudent,
                    decoration: InputDecoration(labelText: "Select Student"),
                    items: students.map((student) {
                      return DropdownMenuItem<String>(
                        value: student.id,
                        child: Text(student.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStudent = value;
                        applyFilters();
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ListTile(
                    title: Text("Start Date: ${startDate != null ? startDate!.toLocal().toString().split(' ')[0] : "Any"}"),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, startDate, (date) {
                      setState(() {
                        startDate = date;
                        applyFilters();
                      });
                    }),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text("End Date: ${endDate != null ? endDate!.toLocal().toString().split(' ')[0] : "Any"}"),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, endDate, (date) {
                      setState(() {
                        endDate = date;
                        applyFilters();
                      });
                    }),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // List of Payments
            Expanded(
              child: filteredPayments.isNotEmpty
                  ? ListView.builder(
                itemCount: filteredPayments.length,
                itemBuilder: (context, index) {
                  final payment = filteredPayments[index];
                  return Card(
                    child: ListTile(
                      title: Text("Student: ${payment.studentId}"),
                      subtitle: Text(
                        "Batch: ${payment.batchId}\nAmount: \$${payment.amount}\nPaid Date: ${payment.paymentDate.toLocal().toString().split(' ')[0]}",
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

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add payment page
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

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key});

  @override
  AddPaymentPageState createState() => AddPaymentPageState();
}

class AddPaymentPageState extends State<AddPaymentPage> {
  // Form key
  final _formKey = GlobalKey<FormState>();
  bool  isLoading = false;

  // Dropdown values
  String? selectedStudent;
  String? selectedBatch;
  List<Student> students = [];
  List<Batch> batches = [];

  // Payment fields
  double? amount;
  DateTime? paidDate;
  DateTime? validFrom;
  DateTime? validTo;

  // Date picker
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
        title: Text("Add Payment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Student Dropdown
              DropdownButtonFormField<String>(
                value: selectedStudent,
                decoration: InputDecoration(labelText: "Select Student"),
                items: students.map((student) {
                  return DropdownMenuItem<String>(
                    value: student.id,
                    child: Text(student.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStudent = value;
                  });
                },
                validator: (value) => value == null ? "Please select a student" : null,
              ),

              SizedBox(height: 16),

              // Batch Dropdown
              DropdownButtonFormField<String>(
                value: selectedBatch,
                decoration: InputDecoration(labelText: "Select Batch"),
                items: batches.map((batch) {
                  return DropdownMenuItem<String>(
                    value: batch.id,
                    child: Text(batch.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBatch = value;
                  });
                },
                validator: (value) => value == null ? "Please select a batch" : null,
              ),

              SizedBox(height: 16),

              // Amount Field
              TextFormField(
                decoration: InputDecoration(labelText: "Payment Amount"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value);
                },
                validator: (value) => value == null || value.isEmpty || double.tryParse(value) == null
                    ? "Please enter a valid amount"
                    : null,
              ),

              SizedBox(height: 16),

              // Paid Date
              ListTile(
                title: Text("Paid Date: ${paidDate != null ? paidDate!.toLocal().toString().split(' ')[0] : "Select Date"}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, paidDate, (date) {
                  setState(() {
                    paidDate = date;
                  });
                }),
              ),

              SizedBox(height: 16),

              // Valid From
              ListTile(
                title: Text("Valid From: ${validFrom != null ? validFrom!.toLocal().toString().split(' ')[0] : "Select Date"}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, validFrom, (date) {
                  setState(() {
                    validFrom = date;
                  });
                }),
              ),

              SizedBox(height: 16),

              // Valid To
              ListTile(
                title: Text("Valid To: ${validTo != null ? validTo!.toLocal().toString().split(' ')[0] : "Select Date"}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, validTo, (date) {
                  setState(() {
                    validTo = date;
                  });
                }),
              ),

              SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                   addPayment();
                  }
                },
                child: Text("Save Payment"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addPayment() async {
    try {
      isLoading  = true;
      await PaymentHelper.savePayment(amount!,
          selectedStudent!,
          selectedBatch!,
          paidDate!,
          validFrom!, validTo!);
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        UIUtils.showMessage(context, 'Payment saved successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error', 'Error occurred: $e');
      }
    }
  }
}
