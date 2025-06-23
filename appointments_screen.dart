import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'reminder_screen.dart';
import 'profile_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _selectedNavIndex = 0;
  final Color primaryColor = const Color(0xFFFF6B6B);

  // Dummy appointment data
  final List<Map<String, String>> _appointments = [
    {
      "doctor": "Dr. Maria Santos",
      "clinic": "EyeCare Clinic Manila",
      "date": "2025-06-20",
      "time": "10:00 AM",
      "status": "Upcoming",
      "type": "Consultation"
    },
    {
      "doctor": "Dr. John Lee",
      "clinic": "VisionPlus Optics",
      "date": "2025-05-15",
      "time": "2:00 PM",
      "status": "Completed",
      "type": "Follow-up"
    },
    {
      "doctor": "Dr. Maria Santos",
      "clinic": "EyeCare Clinic Manila",
      "date": "2025-04-10",
      "time": "9:00 AM",
      "status": "Completed",
      "type": "Eye Scan"
    },
  ];

  void _onNavItemTapped(int index) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Eye Scan tapped")),
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

  void _viewAppointmentDetails(
      BuildContext context, Map<String, String> appointment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Appointment Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Type", appointment["type"] ?? ""),
            _buildDetailRow("Status", appointment["status"] ?? ""),
            _buildDetailRow("Doctor", appointment["doctor"] ?? ""),
            _buildDetailRow("Clinic", appointment["clinic"] ?? ""),
            _buildDetailRow("Date", appointment["date"] ?? ""),
            _buildDetailRow("Time", appointment["time"] ?? ""),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.normal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade50,
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _appointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, idx) {
          final app = _appointments[idx];
          final isUpcoming = app["status"] == "Upcoming";

          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: isUpcoming ? Colors.white : Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main appointment info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.15),
                        child: Icon(
                          isUpcoming ? Icons.event_available : Icons.event_note,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${app["type"]} with ${app["doctor"]}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              app["clinic"] ?? "",
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "${app["date"]} • ${app["time"]}",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              app["status"]!,
                              style: TextStyle(
                                color: isUpcoming ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Action buttons - separate row at bottom
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.visibility, size: 16),
                        label:
                            const Text("View", style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(30, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          elevation: 0,
                        ),
                        onPressed: () => _viewAppointmentDetails(context, app),
                      ),
                      if (isUpcoming) ...[
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.cancel, size: 16),
                          label: const Text("Cancel",
                              style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(30, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            elevation: 0,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Cancel Appointment"),
                                content: Text(
                                  "Are you sure you want to cancel your appointment with ${app["doctor"]}?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _appointments[idx]["status"] =
                                            "Cancelled";
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Yes, Cancel"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
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
}
