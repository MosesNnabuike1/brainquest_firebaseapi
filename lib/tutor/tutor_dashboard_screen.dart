import 'add_category_screen.dart';
import 'add_question_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_critical_thinking_puzzle_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/tutor/logout_drawer.dart';

class TutorDashboardScreen extends StatefulWidget {
  final String tutorName;
  final String? tutorId;

  const TutorDashboardScreen({
    Key? key,
    this.tutorName = "Tutor Name",
    this.tutorId,
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
        _tutorId = null;
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
        final studentsQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('tutorId', isEqualTo: tutorId)
            .get();
        totalStudents = studentsQuery.docs.length;

        final categoriesQuery = await FirebaseFirestore.instance
            .collection('categories')
            .where('tutorId', isEqualTo: tutorId)
            .get();
        totalQuizzes = categoriesQuery.docs.length;

        final resultsQuery = await FirebaseFirestore.instance
            .collection('quiz_results')
            .where('tutorId', isEqualTo: tutorId)
            .get();

        double totalScore = 0;
        int totalResults = 0;

        for (var doc in resultsQuery.docs) {
          final data = doc.data();
          final correctAnswers = data['correctAnswers'] ?? 0;
          final totalQuestions = data['totalQuestions'] ?? 1;
          if (totalQuestions > 0) {
            totalScore += (correctAnswers / totalQuestions) * 100;
            totalResults++;
          }
        }

        averageScore = totalResults > 0 ? totalScore / totalResults : 0.0;
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

  void _showUpdatePasscodeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedOption = 0; // 0 = Tutor ID, 1 = Password
        final idController = TextEditingController();
        final passwordController = TextEditingController();
        final confirmPasswordController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Passcode'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      RadioListTile<int>(
                        value: 0,
                        groupValue: selectedOption,
                        onChanged: (val) => setState(() => selectedOption = val ?? 0),
                        title: const Text('Change Tutor ID'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<int>(
                        value: 1,
                        groupValue: selectedOption,
                        onChanged: (val) => setState(() => selectedOption = val ?? 0),
                        title: const Text('Change Password'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (selectedOption == 0) ...[
                    const Text('New Tutor ID'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(
                        hintText: 'Enter new Tutor ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ] else ...[
                    const Text('New Password'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter new password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Confirm Password'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Re-enter new password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    if (selectedOption == 0) {
                      final newId = idController.text.trim();
                      if (newId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tutor ID cannot be empty.'),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) throw Exception('Not logged in');
                        await FirebaseFirestore.instance
                            .collection('tutors')
                            .doc(user.uid)
                            .update({'tutorId': newId});
                        Navigator.pop(context);
                        setState(() {
                          _tutorId = newId;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tutor ID updated!'),
                              backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to update Tutor ID: $e'),
                              backgroundColor: Colors.red),
                        );
                      }
                    } else {
                      final newPass = passwordController.text.trim();
                      final confirmPass = confirmPasswordController.text.trim();
                      if (newPass.isEmpty || confirmPass.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Password fields cannot be empty.'),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (newPass != confirmPass) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Passwords do not match.'),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (newPass.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Password must be at least 6 characters.'),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) throw Exception('Not logged in');
                        await user.updatePassword(newPass);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Password updated!'),
                              backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to update password: $e'),
                              backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const LogoutDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color.fromARGB(255, 0, 0, 0), // App primary color
                        child: Icon(Icons.person, color: Colors.white, size: 26),
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: 'Open profile/drawer',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Welcome, ${widget.tutorName}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.settings, color: Color.fromARGB(255, 0, 0, 0), size: 26),
                      tooltip: 'Settings',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Settings'),
                            content: const Text('Do you want to clear all app data? This will log you out and reset the app.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Clear app data logic: sign out and maybe clear local storage
                                  await FirebaseAuth.instance.signOut();
                                  // Optionally clear local storage here
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('App data cleared. You have been logged out.'), backgroundColor: Colors.red),
                                  );
                                  // Optionally navigate to login/welcome screen
                                },
                                child: const Text('Clear Data', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Removed motivational text
                    Row(
                      children: [
                        const Text('Your Tutor ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        SelectableText(_tutorId ?? '', style: const TextStyle(fontSize: 16, color: Colors.blue)),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) {
                            return IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              tooltip: 'Copy Tutor ID',
                              onPressed: () {
                                if (_tutorId != null) {
                                  Clipboard.setData(ClipboardData(text: _tutorId!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tutor ID copied to clipboard!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tutor ID not available!'), backgroundColor: Colors.red),
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
                              const Color.fromRGBO(204, 204, 204, 1),
                            ),
                          ),
                          Expanded(
                            child: _buildStatCard(
                              'Total Quiz',
                              _stats['totalQuizzes'].toString(),
                              Icons.quiz,
                              const Color.fromRGBO(204, 204, 204, 1),
                            ),
                          ),
                          Expanded(
                            child: _buildStatCard(
                              'Average Score',
                              '${_stats['averageScore'].toStringAsFixed(1)}%',
                              _stats['averageScore'] >= 70 ? Icons.thumb_up : Icons.thumb_down,
                              const Color.fromRGBO(204, 204, 204, 1),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 32),
                    const Text(
                      "Quick Actions",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 14),
                    Column(
                      children: [
                        _buildQuickActionCard(
                          'Add a New Category',
                          Icons.add,
                          const Color.fromRGBO(154, 207, 247, 1),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCategoryScreen(tutorId: widget.tutorId),
                              ),
                            );
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
                                const SnackBar(content: Text('Tutor ID not loaded yet.'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddQuestionScreen(tutorId: tid),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        _buildQuickActionCard(
                          'Manage Achievements',
                          Icons.emoji_events,
                          const Color.fromRGBO(253, 126, 125, 1),
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Achievement system coming soon!'), backgroundColor: Colors.orange),
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
                                const SnackBar(content: Text('Tutor ID not loaded yet.'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCriticalThinkingPuzzleScreen(tutorId: tid),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        _buildQuickActionCard(
                          'Update Passcode',
                          Icons.lock,
                          const Color.fromRGBO(253, 126, 125, 1),
                          _showUpdatePasscodeDialog,
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Feedback Received",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 14),
                    _tutorId == null
                        ? const Center(child: CircularProgressIndicator())
                        : FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('feedback')
                                .where('tutorId', isEqualTo: _tutorId)
                                .orderBy('timestamp', descending: true)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return const Text('Error loading feedback', style: TextStyle(color: Colors.red));
                              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Text('No feedback received', style: TextStyle(fontSize: 15, color: Colors.black54));
                              }
                              final feedbackDocs = snapshot.data!.docs;
                              return Column(
                                children: feedbackDocs.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  final title = data['title'] ?? 'Feedback';
                                  final content = data['content'] ?? '';
                                  final author = data['studentName'] ?? 'Anonymous';
                                  final timestamp = data['timestamp'] != null && data['timestamp'] is Timestamp
                                      ? (data['timestamp'] as Timestamp).toDate()
                                      : null;
                                  String timeAgo = '';
                                  if (timestamp != null) {
                                    final now = DateTime.now();
                                    final diff = now.difference(timestamp);
                                    if (diff.inSeconds < 60) {
                                      timeAgo = '${diff.inSeconds}s ago';
                                    } else if (diff.inMinutes < 60) {
                                      timeAgo = '${diff.inMinutes}m ago';
                                    } else if (diff.inHours < 24) {
                                      timeAgo = '${diff.inHours}h ago';
                                    } else if (diff.inDays < 7) {
                                      timeAgo = '${diff.inDays}d ago';
                                    } else {
                                      timeAgo = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
                                    }
                                  }
                                  return Column(
                                    children: [
                                      _buildFeedbackCard(title, content, author, timeAgo),
                                      const SizedBox(height: 12),
                                    ],
                                  );
                                }).toList(),
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
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1), width: 1),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Icon(icon, color: Colors.black, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(String title, String content, String author, String time) {
    return Card(
      color: const Color.fromRGBO(250, 250, 250, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  author,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
