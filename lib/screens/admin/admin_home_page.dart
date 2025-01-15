import 'package:flutter/material.dart';
import 'sections/upcoming_sessions.dart';
import 'sections/pending_payments.dart';
import 'sections/follow_up_enquiries.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomepageState createState() => HomepageState();
}
class HomepageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Upcoming Sessions'),
          const UpcomingSessionsSection(), // Replace with Placeholder
          const SizedBox(height: 16.0),
          _buildSectionHeader('Pending Payments'),
          const PendingPaymentsSection(), // Replace with Placeholder
          const SizedBox(height: 16.0),
          _buildSectionHeader('Follow-up Enquiries'),
          const FollowUpEnquirySection(), // Replace with Placeholder
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}