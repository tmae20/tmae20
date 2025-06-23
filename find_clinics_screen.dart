import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'reminder_screen.dart';
import 'profile_screen.dart';
import 'clinic_detail_screen.dart';

class FindClinicsScreen extends StatefulWidget {
  const FindClinicsScreen({super.key});

  @override
  State<FindClinicsScreen> createState() => _FindClinicsScreenState();
}

class _FindClinicsScreenState extends State<FindClinicsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  int _selectedNavIndex = 0; // Adjust as needed

  // Dummy clinics data
  final List<Map<String, String>> _allClinics = [
    {
      "name": "EyeCare Clinic Manila",
      "address": "123 Vision St, Manila, PH",
      "distance": "2.5 km",
      "hours": "8:00 AM - 5:00 PM",
      "phone": "+63 2 1234 5678",
    },
    {
      "name": "VisionPlus Optics",
      "address": "456 Optic Ave, Quezon City, PH",
      "distance": "5.1 km",
      "hours": "9:00 AM - 6:00 PM",
      "phone": "+63 2 9876 5432",
    },
    {
      "name": "ClearEyes Center",
      "address": "789 Eye Rd, Makati, PH",
      "distance": "7.3 km",
      "hours": "7:00 AM - 3:00 PM",
      "phone": "+63 2 2345 6789",
    },
    {
      "name": "Premier Eye Clinic",
      "address": "21 Retina St, Pasig, PH",
      "distance": "8.0 km",
      "hours": "8:00 AM - 4:00 PM",
      "phone": "+63 2 8765 4321",
    },
    {
      "name": "Optima Vision Center",
      "address": "9 Iris Blvd, Taguig, PH",
      "distance": "10.2 km",
      "hours": "10:00 AM - 7:00 PM",
      "phone": "+63 2 4567 8901",
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredClinics {
    if (_searchText.isEmpty) return _allClinics;
    return _allClinics
        .where((clinic) =>
            clinic["name"]!.toLowerCase().contains(_searchText.toLowerCase()) ||
            clinic["address"]!
                .toLowerCase()
                .contains(_searchText.toLowerCase()))
        .toList();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
    switch (index) {
      case 0: // Home
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1: // Progress
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProgressScreen()),
        );
        break;
      case 2: // Eye Scan (you can handle as needed)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Eye Scan tapped")),
        );
        break;
      case 3: // Reminders
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReminderScreen()),
        );
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B6B);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Find Clinics",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for clinics or location",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredClinics.isEmpty
                ? Center(
                    child: Text(
                      "No clinics found.",
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    itemCount: _filteredClinics.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final clinic = _filteredClinics[idx];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClinicDetailScreen(clinic: clinic),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.local_hospital,
                                        color: primaryColor, size: 28),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        clinic["name"]!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        clinic["distance"]!,
                                        style: const TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        clinic["address"]!,
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(
                                      clinic["hours"]!,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(
                                      clinic["phone"]!,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
