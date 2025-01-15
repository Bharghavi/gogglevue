import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gogglevue/Utils/time_of_day_utils.dart';

import '../../../Utils/ui_utils.dart';
import '../../../helpers/payment_helper.dart';
import '../../../helpers/student_batch_helper.dart';
import '../../../helpers/student_helper.dart';
import '../../../models/batch.dart';
import '../../../models/student.dart';

class AddPaymentPage extends StatefulWidget {
  final String? selectedStudent;
  final String? selectedBatch;

  const AddPaymentPage({super.key, this.selectedStudent, this.selectedBatch});


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

  @override
  void initState() {
    super.initState();
    if (widget.selectedStudent != null) {
      selectedStudent = widget.selectedStudent;
      fetchBatch(selectedStudent!);
      selectedBatch =  (widget.selectedBatch != null) ? widget.selectedBatch : null;
    }
    fetchStudents();
  }

  Future<void> fetchStudents() async{
    setState(() {
      isLoading = true;
    });
    final fetchedStudents = await StudentHelper.fetchAllStudents();
    setState(() {
      students = fetchedStudents;
      isLoading = false;
    });
  }

  Future<void> fetchBatch(String studentId) async {
    setState(() {
      isLoading = true;
    });
    final fetchedBatches = await StudentBatchHelper.getBatchesForStudent(studentId);
    setState(() {
      batches = fetchedBatches;
      isLoading = false;
    });
  }

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
                    fetchBatch(selectedStudent!);
                  });
                },
                validator: (value) => value == null ? "Please select a student" : null,
              ),

              SizedBox(height: 16),

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
                title: Text("Paid Date: ${paidDate != null ? TimeOfDayUtils.dateTimeToString(paidDate!) : "Select Date"}"),
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
                title: Text("Valid From: ${validFrom != null ? TimeOfDayUtils.dateTimeToString(validFrom!) : "Select Date"}"),
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
                title: Text("Valid To: ${validTo != null ? TimeOfDayUtils.dateTimeToString(validTo!) : "Select Date"}"),
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
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorDialog(context, 'Error', 'Error occurred: $e');
      }
    }
  }
}
