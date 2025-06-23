import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'reminder_screen.dart';
import 'profile_screen.dart';
import 'symptom_assessment_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _selectedNavIndex = 1; // Progress is at index 1

  // Dummy progress data
  final List<Map<String, dynamic>> progressData = [
    {
      "date": DateTime(2025, 6, 12),
      "eye": "Right Eye",
      "score": 98,
      "classification": "Normal",
      "result": "No Cataract",
      "details":
          "Your eye health is excellent. No signs of cataract formation detected.",
      "recommendations": "Continue with regular checkups every 6 months.",
      "doctor": "Dr. Maria Santos",
    },
    {
      "date": DateTime(2025, 5, 1),
      "eye": "Left Eye",
      "score": 94,
      "classification": "Normal",
      "result": "No Cataract",
      "details":
          "Your eye health is good. No significant issues detected in this scan.",
      "recommendations":
          "Maintain regular eye checkups and protect eyes from UV exposure.",
      "doctor": "Dr. Maria Santos",
    },
    {
      "date": DateTime(2025, 3, 16),
      "eye": "Right Eye",
      "score": 97,
      "classification": "Normal",
      "result": "No Cataract",
      "details":
          "Eye health remains excellent with no signs of deterioration since last scan.",
      "recommendations": "Continue current eye care routine.",
      "doctor": "Dr. James Wilson",
    },
    {
      "date": DateTime(2025, 1, 4),
      "eye": "Left Eye",
      "score": 93,
      "classification": "Normal",
      "result": "No Cataract",
      "details":
          "Eye health is within normal parameters. Minor dryness detected.",
      "recommendations": "Consider using lubricating eye drops as needed.",
      "doctor": "Dr. James Wilson",
    },
  ];

  void _showScanDetails(Map<String, dynamic> scan) {
    const Color primaryColor = Color(0xFFFF6B6B);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with eye icon and classification
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.15),
                      radius: 25,
                      child: Icon(
                        scan["eye"] == "Right Eye"
                            ? Icons.remove_red_eye
                            : Icons.remove_red_eye_outlined,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scan["eye"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              scan["classification"],
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Score visualization
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          CircularProgressIndicator(
                            value: scan["score"] / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              scan["score"] > 90 ? Colors.green : primaryColor,
                            ),
                          ),
                          Text(
                            "${scan["score"]}%",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Health Score",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        scan["result"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Scan details
                _buildDetailSection(
                    "Scan Date", DateFormat.yMMMMd().format(scan["date"])),
                _buildDetailSection("Doctor", scan["doctor"]),
                _buildDetailSection("Details", scan["details"]),
                _buildDetailSection("Recommendations", scan["recommendations"]),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Scan details shared")),
                        );
                      },
                      icon: const Icon(Icons.share_outlined),
                      label: const Text("Share"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text("Close"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  void _onNavItemTapped(int index) {
    if (_selectedNavIndex == index) {
      return;
    }
    setState(() {
      _selectedNavIndex = index;
    });
    switch (index) {
      case 0: // Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1: // Progress (already here)
        break;
      case 2: // Eye Scan - Changed to navigate to SymptomAssessmentScreen
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
      case 3: // Reminders
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ReminderScreen()),
          (route) => false,
        );
        break;
      case 4: // Profile
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

    // Simple chart data extraction (just scores over time)
    final List<int> scores =
        progressData.map((e) => e["score"] as int).toList();
    final List<String> labels = progressData
        .map((e) => DateFormat.MMMd().format(e["date"] as DateTime))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          'Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
                (route) => false,
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: primaryColor.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFFF6B6B),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User and date info
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-06-15 16:53:20",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      "Current User's Login: ArsisjaySo",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Progress Chart Section
          _ProgressChartSection(
            scores: scores,
            labels: labels,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 28),
          Text(
            'Scan History',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          // List of Progress Cards
          ...progressData.map((scan) => _ProgressCard(
                scan: scan,
                primaryColor: primaryColor,
                onTap: () => _showScanDetails(scan),
              )),
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

class _ProgressChartSection extends StatelessWidget {
  final List<int> scores;
  final List<String> labels;
  final Color primaryColor;

  const _ProgressChartSection({
    required this.scores,
    required this.labels,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Chart: simple line chart with points (no chart library, just a custom painter)
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 220,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Score Trend',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: CustomPaint(
                painter: _SimpleLineChartPainter(
                  scores: scores,
                  color: primaryColor,
                ),
                child: Container(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...labels.map((e) => Text(e,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade700))),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SimpleLineChartPainter extends CustomPainter {
  final List<int> scores;
  final Color color;

  _SimpleLineChartPainter({required this.scores, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;
    final double minScore = (scores.reduce((a, b) => a < b ? a : b)).toDouble();
    final double maxScore = (scores.reduce((a, b) => a > b ? a : b)).toDouble();

    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double chartHeight = size.height - 20;
    final double chartWidth = size.width;
    final double dxStep = chartWidth / (scores.length - 1);

    final points = <Offset>[];
    for (int i = 0; i < scores.length; i++) {
      final x = dxStep * i;
      final double normalized = (scores[i] - minScore) /
          ((maxScore - minScore) == 0 ? 1 : (maxScore - minScore));
      final y = chartHeight - normalized * (chartHeight - 20) + 10;
      points.add(Offset(x, y));
    }

    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paintLine);
    }

    // Draw dots
    for (final p in points) {
      canvas.drawCircle(p, 6, paintDot);
      canvas.drawCircle(p, 9, paintDot..color = color.withOpacity(0.15));
      paintDot.color = color; // Reset after opacity
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ProgressCard extends StatelessWidget {
  final Map<String, dynamic> scan;
  final Color primaryColor;
  final VoidCallback onTap;

  const _ProgressCard(
      {required this.scan, required this.primaryColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final DateTime date = scan["date"];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.15),
                child: Icon(
                  scan["eye"] == "Right Eye"
                      ? Icons.remove_red_eye
                      : Icons.remove_red_eye_outlined,
                  color: primaryColor,
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${scan["eye"]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      scan["classification"],
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date: ${DateFormat.yMMMMd().format(date)}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Health Score: ${scan["score"]}%   |   ${scan["result"]}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Visual indicator that card is tappable
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
