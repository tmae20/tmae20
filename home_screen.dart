import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'symptom_assessment_screen.dart';
import 'find_clinics_screen.dart';
import 'appointments_screen.dart';
import 'progress_screen.dart';
import 'reminder_screen.dart';
import 'profile_screen.dart';
import 'activity_log_screen.dart';
import 'view_history_screen.dart';
import 'full_report_screen.dart';
import '../eye_scan_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0; // Default to Home tab (index 0)
  late String _formattedDateTime;
  late String _username;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _recentScans = [];

  Map<String, dynamic> _eyeHealthData = {
    'leftEye': {'status': '', 'score': 0, 'stage': ''},
    'rightEye': {'status': '', 'score': 0, 'stage': ''},
    'overallScore': 0
  };
  bool _isLoadingMetrics = true;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _fetchEyeHealthData();
    // For Left Eye progress bar
  }

  Color _getStatusColor(String status, bool isLeftEye) {
    if (status.toLowerCase() == 'normal') {
      return Colors.green;
    } else if (status.toLowerCase() == 'immature') {
      return Colors.amber;
    } else if (status.toLowerCase() == 'unknown') {
      return Colors.grey;
    } else {
      // Default colors
      return isLeftEye ? Colors.amber : Colors.green;
    }
  }

  // Add this method to generate chart spots from scan history
  List<FlSpot> _generateSpots(bool isRightEye) {
    // Filter scans by eye
    final filteredScans = _recentScans
        .where((scan) => scan['eye'] == (isRightEye ? 'Right Eye' : 'Left Eye'))
        .toList();

    // Sort by timestamp
    filteredScans.sort((a, b) {
      final aTime = a['timestamp'] as Timestamp;
      final bTime = b['timestamp'] as Timestamp;
      return aTime.compareTo(bTime);
    });

    // Limit to 6 most recent points
    final limitedScans = filteredScans.length > 6
        ? filteredScans.sublist(filteredScans.length - 6)
        : filteredScans;

    // Create spots
    List<FlSpot> spots = [];
    for (int i = 0; i < limitedScans.length; i++) {
      final scan = limitedScans[i];
      final confidence = (scan['confidence'] as double?) ?? 0.0;
      spots.add(FlSpot(i.toDouble(), confidence * 100));
    }

    // If we have fewer than 6 points, fill with default values
    if (spots.length < 6) {
      // Default values to show a trend
      final defaultValues = isRightEye
          ? [90.0, 92.0, 94.0, 90.0, 93.0, 95.0]
          : [55.0, 50.0, 45.0, 40.0, 38.0, 35.0];

      for (int i = spots.length; i < 6; i++) {
        spots.add(FlSpot(i.toDouble(), defaultValues[i]));
      }
    }

    return spots;
  }

  Future<void> _fetchEyeHealthData() async {
    try {
      setState(() {
        _isLoadingMetrics = true;
      });

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _isLoadingMetrics = false;
        });
        return;
      }

      // Fetch the most recent left eye scan
      final leftEyeQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('scans')
          .where('eye', isEqualTo: 'Left Eye')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      // Fetch the most recent right eye scan
      final rightEyeQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('scans')
          .where('eye', isEqualTo: 'Right Eye')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      // Process left eye data
      Map<String, dynamic> leftEyeData = {
        'status': 'Unknown',
        'score': 0,
        'stage': 'No Data'
      };

      if (leftEyeQuery.docs.isNotEmpty) {
        final doc = leftEyeQuery.docs.first;
        final data = doc.data();

        final prediction = data['prediction'] as String? ?? '';
        final confidence = data['confidence'] as double? ?? 0.0;

        final bool isNormal = prediction.toLowerCase().contains('normal') ||
            prediction.toLowerCase() == "no cataract";

        leftEyeData = {
          'status': isNormal ? 'Normal' : 'Immature',
          'score': (confidence * 100).round(),
          'stage': isNormal ? 'No Cataract' : 'Initial Stage'
        };
      }

      // Process right eye data
      Map<String, dynamic> rightEyeData = {
        'status': 'Unknown',
        'score': 0,
        'stage': 'No Data'
      };

      if (rightEyeQuery.docs.isNotEmpty) {
        final doc = rightEyeQuery.docs.first;
        final data = doc.data();

        final prediction = data['prediction'] as String? ?? '';
        final confidence = data['confidence'] as double? ?? 0.0;

        final bool isNormal = prediction.toLowerCase().contains('normal') ||
            prediction.toLowerCase() == "no cataract";

        rightEyeData = {
          'status': isNormal ? 'Normal' : 'Immature',
          'score': (confidence * 100).round(),
          'stage': isNormal ? 'No Cataract' : 'Initial Stage'
        };
      }

      // Calculate overall score - Fix type issues here
      int overallScore = 0;
      if ((leftEyeData['score'] as num) > 0 ||
          (rightEyeData['score'] as num) > 0) {
        int divisor = 0;
        int sum = 0;

        if ((leftEyeData['score'] as num) > 0) {
          sum += (leftEyeData['score'] as num).toInt();
          divisor++;
        }

        if ((rightEyeData['score'] as num) > 0) {
          sum += (rightEyeData['score'] as num).toInt();
          divisor++;
        }

        overallScore = divisor > 0 ? (sum / divisor).round() : 0;
      }

      setState(() {
        _eyeHealthData = {
          'leftEye': leftEyeData,
          'rightEye': rightEyeData,
          'overallScore': overallScore
        };
        _isLoadingMetrics = false;
      });
    } catch (e) {
      print('Error fetching eye health data: $e');
      setState(() {
        _isLoadingMetrics = false;
      });
    }
  }

  void _updateDateTime() {
    // Fixed date as specified by user
    _formattedDateTime = "2025-06-15 16:44:22";
    _username = "ArsisjaySo";
  }

  void _onNavItemTapped(int index) {
    if (_selectedNavIndex == index) {
      return; // Already on this tab, do nothing
    }

    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0: // Home
        // Already on home screen, no navigation needed
        break;
      case 1: // Progress
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProgressScreen()),
          (route) => false,
        );
        break;
      case 2: // Eye Scan
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
    const Color secondaryColor = Color(0xFF4A6572);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.remove_red_eye,
                            size: 24,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'SmartiCare',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Profile avatar
                    GestureDetector(
                      onTap: () {
                        // Navigate to profile when avatar is tapped
                        _onNavItemTapped(4);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "A",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Current date/time and user info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): $_formattedDateTime",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          "Current User's Login: $_username",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // User greeting
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Hello, $_username",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "👋",
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Monitor your eye health and detect cataract early",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // Eye Health Score Card
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade700,
                        Colors.blue.shade800,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isLoadingMetrics
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Health Status
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _eyeHealthData['overallScore'] >= 70
                                            ? "Good Eye Health"
                                            : "Attention Needed",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: size.width * 0.6,
                                        child: Text(
                                          "Your overall eye health score is based on the combined analysis of both eyes.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Score Circle
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${_eyeHealthData['overallScore']}%",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // Your Eye Health Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Eye Health",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Left and Right Eye Cards
                    Row(
                      children: [
                        // Left Eye Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _isLoadingMetrics
                                ? Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.amber))
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                      _eyeHealthData['leftEye']
                                                          ['status'],
                                                      true)
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.remove_red_eye,
                                              color: _getStatusColor(
                                                  _eyeHealthData['leftEye']
                                                      ['status'],
                                                  true),
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Left Eye",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _eyeHealthData['leftEye']['status'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(
                                              _eyeHealthData['leftEye']
                                                  ['status'],
                                              true),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _eyeHealthData['leftEye']['stage'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: ((MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          72) /
                                                      2) *
                                                  (_eyeHealthData['leftEye']
                                                          ['score'] /
                                                      100),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                    _eyeHealthData['leftEye']
                                                        ['status'],
                                                    true),
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${_eyeHealthData['leftEye']['score']}%",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right Eye Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _isLoadingMetrics
                                ? Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.green))
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                      _eyeHealthData['rightEye']
                                                          ['status'],
                                                      false)
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.remove_red_eye,
                                              color: _getStatusColor(
                                                  _eyeHealthData['rightEye']
                                                      ['status'],
                                                  false),
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Right Eye",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _eyeHealthData['rightEye']['status'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(
                                              _eyeHealthData['rightEye']
                                                  ['status'],
                                              false),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _eyeHealthData['rightEye']['stage'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: ((MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          72) /
                                                      2) *
                                                  (_eyeHealthData['rightEye']
                                                          ['score'] /
                                                      100),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                    _eyeHealthData['rightEye']
                                                        ['status'],
                                                    false),
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${_eyeHealthData['rightEye']['score']}%",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Data Analysis Chart
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Data Analysis",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to progress screen
                            _onNavItemTapped(1);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(60, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text("View All"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Chart Container
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: 25,
                            verticalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final months = [
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'May',
                                    'Jun'
                                  ];
                                  if (value.toInt() < 0 ||
                                      value.toInt() >= months.length) {
                                    return const Text('');
                                  }
                                  return Text(
                                    months[value.toInt()],
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 25,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}%',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                                reservedSize: 42,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          minX: 0,
                          maxX: 5,
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            // Right Eye Line (Green)
                            LineChartBarData(
                              spots: _recentScans.isNotEmpty
                                  ? _generateSpots(true)
                                  : [
                                      const FlSpot(0, 90),
                                      const FlSpot(1, 92),
                                      const FlSpot(2, 94),
                                      const FlSpot(3, 90),
                                      const FlSpot(4, 93),
                                      const FlSpot(5, 95),
                                    ],
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.green.withOpacity(0.1),
                              ),
                            ),
                            LineChartBarData(
                              spots: _recentScans.isNotEmpty
                                  ? _generateSpots(false)
                                  : [
                                      const FlSpot(0, 55),
                                      const FlSpot(1, 50),
                                      const FlSpot(2, 45),
                                      const FlSpot(3, 40),
                                      const FlSpot(4, 38),
                                      const FlSpot(5, 35),
                                    ],
                              isCurved: true,
                              color: Colors.amber,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.amber.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Legend
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Left Eye",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Right Eye",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick action items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickAction(
                          icon: Icons.location_on,
                          color: Colors.blue,
                          label: "Find Clinics",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FindClinicsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.calendar_today,
                          color: Colors.green,
                          label: "Appointments",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AppointmentsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.history,
                          color: Colors.purple,
                          label: "View History",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ViewHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.document_scanner,
                          color: primaryColor,
                          label: "Report",
                          onTap: () {
                            // Navigate to Full Report screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FullReportScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Recent Activity
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Activity",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to activity log screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ActivityLogScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(60, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text("See All"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Recent activity list
                    _buildActivityItem(
                      icon: Icons.camera_alt,
                      color: primaryColor,
                      title: "Eye Scan Completed",
                      subtitle: "Left eye scan completed",
                      time: "Today, 10:45 AM",
                    ),
                    _buildActivityItem(
                      icon: Icons.local_hospital,
                      color: Colors.blue,
                      title: "Doctor's Appointment",
                      subtitle: "Follow-up with Dr. Johnson",
                      time: "Yesterday, 2:30 PM",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppointmentsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActivityItem(
                      icon: Icons.notification_important,
                      color: Colors.amber,
                      title: "Prescription Reminder",
                      subtitle: "Time to apply your eye drops",
                      time: "Jun 10, 9:00 AM",
                      onTap: () {
                        _onNavItemTapped(3); // Navigate to reminders
                      },
                    ),
                  ],
                ),
              ),

              // Extra space at bottom for navigation bar
              const SizedBox(height: 30),
            ],
          ),
        ),
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
        // Eye Scan as the center item with a special design
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

  Widget _buildQuickAction({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
