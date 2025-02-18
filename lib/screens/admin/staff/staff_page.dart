import '../../../Utils/image_utils.dart';
import 'add_staff_dialog.dart';
import '/managers/database_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/staff.dart';
import '../../../helpers/staff_helper.dart';
import '../../../Utils/ui_utils.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  StaffPageState createState() => StaffPageState();
}

class StaffPageState extends State<StaffPage> {
  List<Staff> staffList = [];

  late StaffHelper staffHelper;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final firestore = await DatabaseManager.getAdminDatabase();
    staffHelper = StaffHelper(firestore);
    fetchStaff();
  }

  Future<void> fetchStaff() async {
    try {
      final fetchedStaff = await staffHelper.getAllStaff();
      setState(() {
        staffList = fetchedStaff;
      });
    } catch (e) {
      if (mounted) {
      UIUtils.showMessage(context, 'Failed to fetch staff: $e');
      }
    }
  }

  void _removeStaff(Staff staff) async {
    UIUtils.showConfirmationDialog(context: context,
        title: 'Remove Staff',
        content: 'Are you sure you want to delete ${staff.name}?',
        onConfirm: () {
          staffHelper.deleteStaff(staff).then((_) {
            setState(() {
              staffList.remove(staff);
            });
            if (mounted) {
              UIUtils.showMessage(context, 'Staff deleted successfully');
            }
          });
        });
  }

  void _makeCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if(mounted) {
        UIUtils.showErrorDialog(context, 'Error', 'Error occurred, please try later');
      }
    }
  }

  void _sendMessage(String phoneNumber) async {
    final uri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if(mounted) {
        UIUtils.showErrorDialog(context, 'Error', 'Error occurred, please try later');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Staff',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Content
          Expanded(
            child: staffList.isEmpty
                ? Center(
              child: Text(
                'No staff available',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
                : ListView.builder(
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return ListTile(
                  title: Text(staff.name, style: Theme.of(context).textTheme.bodyMedium),
                  subtitle:
                      Text('Phone: ${staff.phone}', style: Theme.of(context).textTheme.bodySmall),
                  leading:staff.profilePic == null || staff.profilePic!.isEmpty
                      ? const Icon(Icons.person, size: 50)  // Default icon for missing profile pic
                      : ImageUtils.getClipRRectImage(staff.profilePic!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Ensures the row takes up minimal space
                    children: [
                      IconButton(
                        icon: Icon(Icons.call, color: Colors.green),
                        onPressed: () => _makeCall(staff.phone),
                      ),
                      IconButton(
                        icon: Image.asset(
                          'assets/icon/WhatsApp_icon.png',
                          width: 24,
                          height: 24,
                        ),
                        onPressed: () => _sendMessage(staff.phone),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeStaff(staff),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newStaff = await showDialog(
            context: context,
            builder: (context) => AddStaffDialog(),
          );
          if (newStaff != null) {
            setState(() {
              staffList.add(newStaff);
            });
          }
        },
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
