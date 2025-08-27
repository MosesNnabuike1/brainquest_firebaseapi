import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorDashboardScreen extends StatefulWidget {
  final String tutorName;
  final String? tutorId;
  final VoidCallback? onOpenProfileTab;

  const TutorDashboardScreen({
    Key? key,
    this.tutorName = "Tutor Name",
    this.tutorId,
    this.onOpenProfileTab,
  }) : super(key: key);

  @override
  State<TutorDashboardScreen> createState() => _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends State<TutorDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'totalStudents': 0,
    'totalQuizzes': 0,
    'averageScore': 0.0,
  };
  String? _tutorId;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadTutorId();
  }

  Future<void> _loadTutorId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('tutors')
          .doc(user.uid)
          .get();
      if (!mounted) return;
      setState(() {
        _tutorId = doc.data()?['tutorId']?.toString();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // Error loading tutor ID
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _stats = {
            'totalStudents': 0,
            'totalQuizzes': 0,
            'averageScore': 0.0,
          };
          _isLoading = false;
        });
        return;
      }

      String? tutorId = widget.tutorId;
      if (tutorId == null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        tutorId = userDoc.data()?['tutorId']?.toString();
      }

      int totalStudents = 0;
      int totalQuizzes = 0;
      double averageScore = 0.0;

      if (tutorId != null && tutorId.isNotEmpty) {
        // Only count students who have written a quiz using this tutorId
        final resultsQuery = await FirebaseFirestore.instance
            .collection('quiz_results')
            .where('tutorId', isEqualTo: tutorId)
            .get();

        // Get unique student IDs from quiz_results
        final studentIds = <String>{};
        double totalScore = 0;
        int totalResults = 0;

        for (var doc in resultsQuery.docs) {
          final data = doc.data();
          final studentId = data['studentId'];
          // Only count non-null, non-empty student IDs
          if (studentId != null &&
              studentId is String &&
              studentId.trim().isNotEmpty) {
            studentIds.add(studentId.trim());
          }
          final correctAnswers = data['correctAnswers'] ?? 0;
          final totalQuestions = data['totalQuestions'] ?? 1;
          if (totalQuestions > 0) {
            totalScore += (correctAnswers / totalQuestions) * 100;
            totalResults++;
          }
        }
        // If no valid student IDs, totalStudents should be 0
        totalStudents = studentIds.isEmpty ? 0 : studentIds.length;
        averageScore = totalResults > 0 ? totalScore / totalResults : 0.0;

        // Count total quiz questions created by this tutor
        final categoriesQuery = await FirebaseFirestore.instance
            .collection('categories')
            .where('tutorId', isEqualTo: tutorId)
            .get();
        int totalQuizQuestions = 0;
        for (var catDoc in categoriesQuery.docs) {
          final questionsSnap = await FirebaseFirestore.instance
              .collection('categories')
              .doc(catDoc.id)
              .collection('questions')
              .get();
          totalQuizQuestions += questionsSnap.docs.length;
        }
        totalQuizzes = totalQuizQuestions;
      }

      if (!mounted) return;
      setState(() {
        _stats = {
          'totalStudents': totalStudents,
          'totalQuizzes': totalQuizzes,
          'averageScore': averageScore,
        };
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stats = {
          'totalStudents': 0,
          'totalQuizzes': 0,
          'averageScore': 0.0,
        };
        _isLoading = false;
      });
    }
  }

  // ...existing code...
  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black, size: 28),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: color,
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        scrolledUnderElevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        titleSpacing: 8,
        leadingWidth: 56,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const CircleAvatar(
              radius: 22,
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
              child: Icon(Icons.person, color: Colors.white, size: 26),
            ),
            onPressed: () {
              final openTab = widget.onOpenProfileTab;
              if (openTab != null) {
                openTab();
              } else {
                context.push('/tutor/profile');
              }
            },
            tooltip: 'Open profile',
          ),
        ),
        title: Text(
          "Welcome, ${widget.tutorName}",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Removed motivational text
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        const Text('Tutor ID:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SelectableText(
                          _tutorId ?? '',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.blue),
                          maxLines: 1,
                        ),
                        Builder(
                          builder: (context) {
                            return IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              tooltip: 'Copy Tutor ID',
                              onPressed: () {
                                if (_tutorId != null) {
                                  Clipboard.setData(
                                      ClipboardData(text: _tutorId!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Tutor ID copied to clipboard!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Tutor ID not available!'),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Students',
                              _stats['totalStudents'].toString(),
                              Icons.people,
                              const Color.fromRGBO(
                                  154, 207, 247, 1), // original color
                            ),
                          ),
                          Expanded(
                            child: _buildStatCard(
                              'Total Quiz Questions', // label split for equal height
                              _stats['totalQuizzes'].toString(),
                              Icons.quiz,
                              const Color.fromRGBO(
                                  255, 186, 49, 1), // original color
                            ),
                          ),
                          Expanded(
                            child: _buildStatCard(
                              'Average Score',
                              '${_stats['averageScore'].toStringAsFixed(1)}%',
                              _stats['averageScore'] >= 70
                                  ? Icons.thumb_up
                                  : Icons.thumb_down,
                              const Color.fromRGBO(
                                  253, 126, 125, 1), // original color
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 32),
                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 14),
                    Column(
                      children: [
                        _buildQuickActionCard(
                          'Add a New Category',
                          Icons.add,
                          const Color.fromRGBO(154, 207, 247, 1),
                          () {
                            context.push('/tutor/add-category', extra: {
                              'tutorId': widget.tutorId,
                            });
                          },
                        ),
                        const SizedBox(height: 2),
                        _buildQuickActionCard(
                          'Add a New Quiz Question',
                          Icons.add,
                          const Color.fromRGBO(255, 186, 49, 1),
                          () {
                            final tid = _tutorId ?? widget.tutorId;
                            if (tid == null || tid.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Tutor ID not loaded yet.'),
                                    backgroundColor: Colors.red),
                              );
                              return;
                            }
                            context.push('/tutor/add-question', extra: {
                              'tutorId': tid,
                            });
                          },
                        ),
                        const SizedBox(height: 2),
                        _buildQuickActionCard(
                          'Manage Achievements',
                          Icons.emoji_events,
                          const Color.fromRGBO(253, 126, 125, 1),
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Achievement system coming soon!'),
                                  backgroundColor: Colors.orange),
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        _buildQuickActionCard(
                          'Add Logic Puzzle',
                          Icons.psychology,
                          const Color.fromRGBO(255, 186, 49, 1),
                          () {
                            final tid = _tutorId ?? widget.tutorId;
                            if (tid == null || tid.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Tutor ID not loaded yet.'),
                                    backgroundColor: Colors.red),
                              );
                              return;
                            }
                            context.push('/tutor/add-puzzle', extra: {
                              'tutorId': tid,
                            });
                          },
                        ),
                        const SizedBox(height: 2),
                        // Removed Update Passcode quick action
                      ],
                    ),
                    // ...existing code...
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
