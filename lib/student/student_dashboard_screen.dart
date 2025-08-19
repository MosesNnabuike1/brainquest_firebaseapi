import 'logout_drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_quizzapp/student/widgets/fixed_header.dart';
import 'achievements_screen.dart';
import 'daily_quiz_screen.dart';

import 'feedback_dialog.dart';

class StudentDashboardScreen extends StatefulWidget {
  final String studentName;
  final String? tutorId;

  const StudentDashboardScreen({
    Key? key,
    this.studentName = "Student Name",
    this.tutorId,
  }) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const LogoutDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FixedHeader(
                studentName: widget.studentName,
                onProfileTap: () {
                  // TODO: Implement profile tap
                },
                onSettingsTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AlertDialog(
                      content: Text('Settings coming soon!'),
                    ),
                  );
                },
                onDrawerOpen: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Texts
                    Text(
                      "Welcome, "+widget.studentName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Greatness comes from continuous practices!",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // More Practice
                    const Text(
                      "More Practice",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Daily Quiz Card
                    Card(
                      color: const Color.fromRGBO(154, 207, 247, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DailyQuizScreen(),
                              settings: RouteSettings(
                                  arguments: {'tutorId': widget.tutorId}),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Daily Quiz",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 0),
                                    // You may want to restore the FutureBuilder for quiz count here
                                    const Text(
                                      "10 questions daily",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.black54, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Critical Thinking Card
                    Card(
                      color: const Color.fromRGBO(255, 186, 49, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Add navigation or logic for critical thinking
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Critical Thinking",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 0),
                                    // You may want to restore the FutureBuilder for puzzle count here
                                    const Text(
                                      "Puzzles available",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Achievements Card
                    Card(
                      color: const Color.fromRGBO(253, 126, 125, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AchievementsScreen(),
                              settings: RouteSettings(
                                  arguments: {'tutorId': widget.tutorId}),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Achievements",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 0),
                                    // You may want to restore the FutureBuilder for achievements count here
                                    const Text(
                                      "Badges earned",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.black54, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Recent Activity
                    const Text(
                      "Recent Activity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Recent Activity Container
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8FC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 0),
                      child: const Column(
                        children: [
                          // Example activity
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, size: 20, color: Colors.green),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Completed Daily Quiz",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  "2h ago",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Add more activities as needed
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.tutorId != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => FeedbackDialog(tutorId: widget.tutorId!),
                );
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback sent!'), backgroundColor: Colors.green),
                  );
                }
              },
              icon: const Icon(Icons.feedback),
              label: const Text('Send Feedback'),
            )
          : null,
    );
  }
}
