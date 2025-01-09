import 'package:flutter/material.dart';

class FollowUpEnquirySection extends StatefulWidget {
  const FollowUpEnquirySection({super.key});

  @override
  FollowUpEnquirySectionState createState() => FollowUpEnquirySectionState();
}

class FollowUpEnquirySectionState extends State<FollowUpEnquirySection> {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Enquiry #123'),
            subtitle: const Text('Contact: Sarah Lee\nStatus: Pending Call'),
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Mark Completed'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Enquiry #124'),
            subtitle: const Text('Contact: Tom Carter\nStatus: Email Sent'),
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Add Note'),
            ),
          ),
        ],
      ),
    );
  }
}
