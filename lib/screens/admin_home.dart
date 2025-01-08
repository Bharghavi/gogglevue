import 'package:flutter/material.dart';
import '../managers/login_manager.dart';
import 'batch_page.dart';
import 'staff_page.dart';
import 'course_page.dart';
import 'student_page.dart';
import 'lesson_plan_page.dart';
import 'payment_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  AdminHomepageState createState() => AdminHomepageState();
}

class AdminHomepageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    HomePage(),
    BatchPage(),
    StudentPage(),
    LessonPlanPage(),
    StaffPage(),
    AttendancePage(),
    CoursePage(),
    PaymentPage(),
    EnquiryPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.of(context).pop();
  }

  Future<void> _signOut() async {
    await LoginManager.signout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Homepage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _signOut,
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
                color: Colors.blueGrey,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => _onDrawerItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.batch_prediction),
              title: Text('Batch'),
              onTap: () => _onDrawerItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Student'),
              onTap: () => _onDrawerItemTapped(2),
            ),
            ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text('Lesson Plan'),
              onTap: () => _onDrawerItemTapped(3),
            ),
            ListTile(
              leading: Icon(Icons.supervisor_account),
              title: Text('Staff'),
              onTap: () => _onDrawerItemTapped(4),
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Attendance'),
              onTap: () => _onDrawerItemTapped(5),
            ),
            ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text('Courses'),
              onTap: () => _onDrawerItemTapped(6),
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payment'),
              onTap: () => _onDrawerItemTapped(7),
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Enquiry'),
              onTap: () => _onDrawerItemTapped(8),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('This page is under construction'));
  }
}

// AttendancePage.dart
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Attendance Page'));
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
