import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'reminder_screen.dart';
import 'profile_screen.dart';
import 'symptom_assessment_screen.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  int _selectedNavIndex = 0; // Can be set to represent the current section
  final Color primaryColor = const Color(0xFFFF6B6B);

  // Dummy activity data
  final List<Map<String, dynamic>> _activities = [
    {
      "icon": Icons.camera_alt,
      "color": const Color(0xFFFF6B6B),
      "title": "Eye Scan Completed",
      "subtitle": "Left eye scan completed",
      "time": "Today, 10:45 AM",
      "date": "2025-06-14",
    },
    {
      "icon": Icons.local_hospital,
      "color": Colors.blue,
      "title": "Doctor's Appointment",
      "subtitle": "Follow-up with Dr. Johnson",
      "time": "Yesterday, 2:30 PM",
      "date": "2025-06-13",
    },
    {
      "icon": Icons.notification_important,
      "color": Colors.amber,
      "title": "Prescription Reminder",
      "subtitle": "Time to apply your eye drops",
      "time": "Jun 10, 9:00 AM",
      "date": "2025-06-10",
    },
    {
      "icon": Icons.trending_up,
      "color": Colors.green,
      "title": "Progress Updated",
      "subtitle": "Right eye score improved by 2%",
      "time": "Jun 8, 11:20 AM",
      "date": "2025-06-08",
    },
    {
      "icon": Icons.location_on,
      "color": Colors.purple,
      "title": "Clinic Visited",
      "subtitle": "Check-up at VisionPlus Optics",
      "time": "Jun 5, 3:15 PM",
      "date": "2025-06-05",
    },
    {
      "icon": Icons.camera_alt,
      "color": const Color(0xFFFF6B6B),
      "title": "Eye Scan Completed",
      "subtitle": "Right eye scan completed",
      "time": "Jun 1, 10:00 AM",
      "date": "2025-06-01",
    },
    {
      "icon": Icons.help,
      "color": Colors.teal,
      "title": "Symptom Assessment",
      "subtitle": "Completed eye health questionnaire",
      "time": "May 28, 2:45 PM",
      "date": "2025-05-28",
    },
    {
      "icon": Icons.local_pharmacy,
      "color": Colors.indigo,
      "title": "New Medication",
      "subtitle": "Started eye drops treatment",
      "time": "May 25, 9:30 AM",
      "date": "2025-05-25",
    },
  ];

  void _onNavItemTapped(int index) {
    if (_selectedNavIndex == index) {
      // Already on this screen, no need to navigate
      return;
    }
    setState(() {
      _selectedNavIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProgressScreen()),
          (route) => false,
        );
        break;
      case 2:
        // Eye Scan button
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SymptomAssessmentScreen(
              onStart: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
        break;
      case 3:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ReminderScreen()),
          (route) => false,
        );
        break;
      case 4:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Log"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];

          // Add date header if this is the first item or if date changes
          bool showDateHeader =
              index == 0 || activity["date"] != _activities[index - 1]["date"];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8),
                  child: Text(
                    _formatDateHeader(activity["date"]),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const Divider(),
              ],
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: activity["color"].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          activity["icon"],
                          color: activity["color"],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity["title"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity["subtitle"],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        activity["time"],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(primaryColor),
    );
  }

  Widget _buildBottomNavigationBar(Color primaryColor) {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: _onNavItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey.shade600,
      selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
      elevation: 12,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.trending_up_outlined),
          activeIcon: Icon(Icons.trending_up),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
          label: 'Eye Scan',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'Reminders',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  String _formatDateHeader(String date) {
    // Use a fixed "today" date matching the user's date preference
    DateTime now = DateTime.parse("2025-06-14");
    DateTime activityDate = DateTime.parse(date);

    // Calculate difference in days
    int differenceInDays = now.difference(activityDate).inDays;

    if (differenceInDays == 0) {
      return "Today";
    } else if (differenceInDays == 1) {
      return "Yesterday";
    } else {
      // Return formatted date
      return "${activityDate.year}/${activityDate.month.toString().padLeft(2, '0')}/${activityDate.day.toString().padLeft(2, '0')}";
    }
  }
}
