import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'reminder_screen.dart';
import 'profile_screen.dart';
import 'find_clinics_screen.dart';

class ClinicDetailScreen extends StatefulWidget {
  final Map<String, String> clinic;

  const ClinicDetailScreen({super.key, required this.clinic});

  @override
  State<ClinicDetailScreen> createState() => _ClinicDetailScreenState();
}

class _ClinicDetailScreenState extends State<ClinicDetailScreen> {
  int _selectedNavIndex = 0; // Adjust as needed for highlighting

  // Dummy doctor info (modify or connect to real data as needed)
  final List<Map<String, String>> doctors = [
    {
      "name": "Dr. Maria Santos",
      "specialty": "Ophthalmologist",
      "schedule": "Mon-Fri, 8:00 AM - 3:00 PM",
      "avatar": "",
    },
    {
      "name": "Dr. John Lee",
      "specialty": "Optometrist",
      "schedule": "Tue, Thu, Sat, 9:00 AM - 2:00 PM",
      "avatar": "",
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

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B6B);

    final clinic = widget.clinic;

    return Scaffold(
      appBar: AppBar(
        title: Text(clinic["name"] ?? "Clinic Detail"),
        backgroundColor: primaryColor,
      ),
      backgroundColor: Colors.grey.shade50,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Clinic Name
          Text(
            clinic["name"] ?? "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 12),
          // Clinic Address
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  clinic["address"] ?? "",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Distance and Hours
          Row(
            children: [
              const Icon(Icons.directions_walk, color: primaryColor, size: 20),
              const SizedBox(width: 6),
              Text(
                clinic["distance"] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 6),
              Text(
                clinic["hours"] ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Phone
          Row(
            children: [
              Icon(Icons.phone, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 6),
              Text(
                clinic["phone"] ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // About Section
          Text(
            "About Clinic",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We provide comprehensive eye care services including eye check-ups, cataract screening, and treatment, performed by experienced doctors using modern equipment. Book appointments for consultations, diagnostics, or ongoing care.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 22),
          // Doctors Section
          Text(
            "Doctors",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 10),
          ...doctors.map((doctor) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.15),
                  child: const Icon(Icons.person, color: primaryColor),
                ),
                title: Text(
                  doctor["name"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor["specialty"]!,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      doctor["schedule"]!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // Action Button
          const SizedBox(height: 18),
          ElevatedButton.icon(
            icon: const Icon(Icons.phone),
            label: const Text("Call Clinic"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // You can implement direct call using url_launcher or similar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Calling ${clinic["phone"]} ...")),
              );
            },
          ),
        ],
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
