import 'package:flutter/material.dart';
import '../../helpers/admin_helper.dart';
import '../settings_page.dart';
import 'batch/batch_list_page.dart';
import 'staff_page.dart';
import 'course/course_page.dart';
import 'student_page.dart';
import 'payments/payment_page.dart';
import 'admin_home_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  AdminHomepageState createState() => AdminHomepageState();
}

class AdminHomepageState extends State<AdminHomePage> {
  int _currentIndex = 0;
  String adminName = '';

  // List of pages
  final List<Widget> _pages = [
    HomePage(),
    BatchListPage(destinationPage: 'batchDetails'),
    StudentPage(),
    BatchListPage(destinationPage: 'lessonPlan'),
    StaffPage(),
    BatchListPage(destinationPage: 'attendance'),
    CoursePage(),
    PaymentPage(),
    EnquiryPage(),
  ];

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

  void _onDrawerItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi $adminName!'),
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
      body: _pages[_currentIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text(
                'Menu',
                style: Theme.of(context).appBarTheme.titleTextStyle
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home', style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () => _onDrawerItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.batch_prediction),
              title: Text('Batch', style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () => _onDrawerItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Student', style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () => _onDrawerItemTapped(2),
            ),
            ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text('Lesson Plan', style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () => _onDrawerItemTapped(3),
            ),
            ListTile(
              leading: Icon(Icons.supervisor_account,),
              title: Text('Staff', style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () => _onDrawerItemTapped(4),
            ),
            ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text('Attendance', style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () => _onDrawerItemTapped(5),
            ),
            ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text('Courses', style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () => _onDrawerItemTapped(6),
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payment', style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () => _onDrawerItemTapped(7),
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Enquiry', style: Theme.of(context).textTheme.bodyMedium,),
              onTap: () => _onDrawerItemTapped(8),
            ),
          ],
        ),
      ),
    );
  }
}

// EnquiryPage.dart
class EnquiryPage extends StatelessWidget {
  const EnquiryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Enquiry Page'));
  }
}
