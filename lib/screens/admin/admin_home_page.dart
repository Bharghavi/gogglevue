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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Upcoming Sessions'),
                    const UpcomingSessionsSection(),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Pending Payments'),
                    const PendingPaymentsSection(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          //_buildSectionHeader('Follow-up Enquiries'),
          //const FollowUpEnquirySection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
  }
}