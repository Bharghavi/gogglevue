import 'package:flutter/material.dart';
import '../../screens/settings_page.dart';
import '../../helpers/admin_helper.dart';
import 'sections/upcoming_sessions.dart';
import 'sections/pending_payments.dart';
import 'sections/follow_up_enquiries.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomepageState createState() => HomepageState();
}
class HomepageState extends State<HomePage> {

  String adminName = '';

  @override
  void initState() {
    super.initState();
    getAdminName();
  }

  Future<void> getAdminName() async {
    String name = await AdminHelper.getLoggedInAdminName();

    setState(() {
      adminName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Welcome $adminName'),
                ),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upcoming Sessions section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Upcoming Sessions'),
                    const UpcomingSessionsSection(),
                  ],
                ),
              ),
              const SizedBox(width: 16.0), // Spacing between the two sections
              // Pending Payments section
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