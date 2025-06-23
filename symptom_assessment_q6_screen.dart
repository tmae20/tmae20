import 'package:flutter/material.dart';
import 'symptom_assessment_q7_screen.dart'; // Import Q7 screen

class SymptomAssessmentQ6Screen extends StatefulWidget {
  final Function(String) onAnswer;
  final VoidCallback onPrevious;

  const SymptomAssessmentQ6Screen({
    super.key,
    required this.onAnswer,
    required this.onPrevious,
    required Null Function() onNext,
  });

  @override
  State<SymptomAssessmentQ6Screen> createState() =>
      _SymptomAssessmentQ6ScreenState();
}

class _SymptomAssessmentQ6ScreenState extends State<SymptomAssessmentQ6Screen> {
  String? _selectedAnswer;
  final List<String> _options = [
    'Never',
    'Rarely (few times a year)',
    'Sometimes (few times a month)',
    'Often (few times a week)',
    'Always (daily)',
  ];

  // Map to store answers
  final Map<String, String> _assessmentAnswers = {};

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B6B);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                      ),
                    ),
                  ),

                  // Title
                  const Text(
                    'Symptom Assessment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Empty space to balance the layout
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Progress indicator - 86% (6/7)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question 6 of 7',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Text(
                        '86%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.86,
                    backgroundColor: Colors.grey.shade200,
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 8,
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    const Text(
                      'Do you experience double vision in one eye?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Image
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/double_vision.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Use this if you don't have the image
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 50,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.remove_red_eye,
                              size: 50,
                              color: Colors.grey.shade700.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade100,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Seeing duplicate images when looking through just one eye can be a symptom of cataracts.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blue.shade900,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Answer options
                    ...List.generate(_options.length, (index) {
                      final option = _options[index];
                      return _buildAnswerOption(
                        option: option,
                        isSelected: _selectedAnswer == option,
                        onTap: () {
                          setState(() {
                            _selectedAnswer = option;
                          });
                          widget.onAnswer(option);
                          _assessmentAnswers['q6'] = option;
                        },
                        primaryColor: primaryColor,
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Navigation buttons - Previous and Next
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  SizedBox(
                    width: 120,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: widget.onPrevious,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade800,
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Previous',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Next button with navigation to Q7
                  SizedBox(
                    width: 120,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedAnswer != null
                          ? () {
                              // Navigate to Question 7
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SymptomAssessmentQ7Screen(
                                    onAnswer: (answer) {
                                      // Store Q7 answer
                                      print('Q7 Answer: $answer');
                                      // In a real app, you would save the answer to a state management solution
                                    },
                                    onFinish: () {
                                      // Navigate to results screen (to be implemented)
                                      // For now, just navigate back to home with all answers
                                      Navigator.popUntil(
                                          context, (route) => route.isFirst);

                                      // Here you would typically:
                                      // 1. Calculate the risk score based on all answers
                                      // 2. Navigate to a results screen showing the assessment outcome
                                      // 3. Provide personalized recommendations

                                      // You could display a success message
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Assessment completed successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    onPrevious: () {
                                      // Go back to Q6
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        elevation: _selectedAnswer != null ? 2 : 0,
                        shadowColor: primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption({
    required String option,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(width: 16),
              Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? primaryColor : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
