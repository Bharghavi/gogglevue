import 'package:flutter/material.dart';
import 'package:gogglevue/helpers/batch_helper.dart';
import '../../helpers/student_batch_helper.dart';
import '../../helpers/student_helper.dart';
import '../../Utils/ui_utils.dart';
import '../../helpers/payment_helper.dart';
import '../../models/batch.dart';
import '../../models/payment.dart';
import '../../models/student.dart';

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
                            "Paid Date: ${payment.paymentDate.toLocal().toString().split(' ')[0]}",
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

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async{
    final fetchedStudents = await StudentHelper.fetchAllStudents();

    setState(() {
      students = fetchedStudents;
    });
  }

  Future<void> fetchBatch(String studentId) async {
    final fetchedBatches = await StudentBatchHelper.getBatchesForStudent(studentId);

    setState(() {
      batches = fetchedBatches;
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
