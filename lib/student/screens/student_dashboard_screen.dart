import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/student/widgets/fixed_header.dart';
// import 'logout_drawer.dart';

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
  User? get _user => FirebaseAuth.instance.currentUser;
  Future<List<Map<String, dynamic>>> _loadRecentActivities() async {
    if (_user == null) return [];
    final activities = <Map<String, dynamic>>[];
    final quizResultsSnap = await FirebaseFirestore.instance
        .collection('quiz_results')
        .where('studentId', isEqualTo: _user!.uid)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();
    for (var doc in quizResultsSnap.docs) {
      final data = doc.data();
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      final score = (data['correctAnswers'] ?? 0) as int;
      final total = (data['totalQuestions'] ?? 1) as int;
      activities.add({
        'title': '${data['subject']} Quiz completed',
        'subtitle': '$score/$total correct • ${_formatTimeAgo(timestamp)}',
        'timestamp': timestamp,
      });
    }
    return activities;
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Texts
                    Text(
                      "Welcome, ${widget.studentName}",
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
                          context.push('/daily-quiz', extra: {
                            'tutorId': widget.tutorId,
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Daily Quiz",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 0),
                                    // You may want to restore the FutureBuilder for quiz count here
                                    Text(
                                      "10 questions daily",
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
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
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Critical Thinking",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 0),
                                    // You may want to restore the FutureBuilder for puzzle count here
                                    Text(
                                      "Puzzles available",
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: Colors.black54, size: 20),
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
                          context.push('/achievements', extra: {
                            'tutorId': widget.tutorId,
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Achievements",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 0),
                                    // You may want to restore the FutureBuilder for achievements count here
                                    Text(
                                      "Badges earned",
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
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
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _loadRecentActivities(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final activities = snapshot.data ?? [];
                        if (activities.isEmpty) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8FC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 0),
                            child: const Center(
                              child: Text('No recent activities yet.',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black54)),
                            ),
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8FC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 0),
                          child: Column(
                            children: activities
                                .map((activity) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 6),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              size: 20, color: Colors.green),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              activity['title'],
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                          Text(
                                            activity['subtitle'],
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: widget.tutorId != null
      //     ? FloatingActionButton.extended(
      //         onPressed: () async {
      //           final result = await showDialog(
      //             context: context,
      //             builder: (context) => FeedbackDialog(tutorId: widget.tutorId!),
      //           );
      //           if (result == true && mounted) {
      //             ScaffoldMessenger.of(context).showSnackBar(
      //               const SnackBar(content: Text('Feedback sent!'), backgroundColor: Colors.green),
      //             );
      //           }
      //         },
      //         icon: const Icon(Icons.feedback),
      //         label: const Text('Send Feedback'),
      //       )
      //     : null,
    );
  }
}
