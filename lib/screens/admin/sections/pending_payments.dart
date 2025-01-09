import 'package:flutter/material.dart';

class PendingPaymentsSection extends StatefulWidget {
  const PendingPaymentsSection({super.key});

  @override
  PendingPaymentsSectionState createState() =>
      PendingPaymentsSectionState();
}

class PendingPaymentsSectionState extends State<PendingPaymentsSection> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: const Text('John Doe'),
            subtitle: const Text('Amount Due: \$150\nDue Date: Jan 10, 2025'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text('Send Reminder'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: const Text('Jane Smith'),
            subtitle: const Text('Amount Due: \$200\nDue Date: Overdue'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: const Text('Send Reminder'),
            ),
          ),
        ],
      ),
    );
  }
}