import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecentActivitiesScreen extends StatefulWidget {
  const RecentActivitiesScreen({Key? key}) : super(key: key);

  @override
  State<RecentActivitiesScreen> createState() => _RecentActivitiesScreenState();
}

class _RecentActivitiesScreenState extends State<RecentActivitiesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _activities = [];
  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadRecentActivities();
  }

  Future<void> _loadRecentActivities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final activities = <Map<String, dynamic>>[];

      // 1. Load recent quiz results
      final quizResultsSnap = await FirebaseFirestore.instance
          .collection('quiz_results')
          .where('studentId', isEqualTo: _user!.uid)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      for (var doc in quizResultsSnap.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final score = (data['correctAnswers'] ?? 0) as int;
        final total = (data['totalQuestions'] ?? 1) as int;
        final percentage = total > 0 ? (score / total * 100).round() : 0;

        activities.add({
          'type': 'quiz',
          'title': '${data['subject']} Quiz completed',
          'subtitle': '$score/$total correct • ${_formatTimeAgo(timestamp)}',
          'icon': Icons.quiz,
          'color': _getScoreColor(percentage),
          'timestamp': timestamp,
          'metadata': {
            'score': score,
            'total': total,
            'percentage': percentage,
            'subject': data['subject'],
            'topic': data['topic'],
          },
        });
      }

      // 2. Load recent critical thinking attempts
      final criticalThinkingSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('critical_thinking_attempts')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      for (var doc in criticalThinkingSnap.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final isCorrect = data['isCorrect'] ?? false;

        activities.add({
          'type': 'critical_thinking',
          'title': 'Critical Thinking puzzle',
          'subtitle': isCorrect
              ? 'Correct answer • ${_formatTimeAgo(timestamp)}'
              : 'Incorrect answer • ${_formatTimeAgo(timestamp)}',
          'icon': Icons.psychology,
          'color': isCorrect ? Colors.green : Colors.orange,
          'timestamp': timestamp,
          'metadata': {
            'isCorrect': isCorrect,
            'question': data['question'],
          },
        });
      }

      // 3. Calculate and add achievement unlocks
      final achievements = await _calculateRecentAchievements();
      activities.addAll(achievements);

      // 4. Sort all activities by timestamp (most recent first)
      activities.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      // 5. Limit to most recent 15 activities
      final limitedActivities = activities.take(15).toList();

      setState(() {
        _activities = limitedActivities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading recent activities: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _calculateRecentAchievements() async {
    final achievements = <Map<String, dynamic>>[];

    try {
      // Get user's quiz statistics
      final quizResultsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('quiz_results')
          .get();

      final totalQuizzes = quizResultsSnap.docs.length;
      int perfectScores = 0;

      for (var doc in quizResultsSnap.docs) {
        final data = doc.data();
        final correctAnswers = (data['correctAnswers'] ?? 0) as int;
        final totalQuestionsInQuiz = (data['totalQuestions'] ?? 1) as int;

        if (correctAnswers == totalQuestionsInQuiz) {
          perfectScores++;
        }
      }

      // Check for recent achievement unlocks (simplified logic)
      final now = DateTime.now();

      if (totalQuizzes == 1) {
        achievements.add({
          'type': 'achievement',
          'title': 'Achievement unlocked: First Steps',
          'subtitle':
              'Complete your first quiz • ${_formatTimeAgo(now.subtract(const Duration(hours: 1)))}',
          'icon': Icons.star,
          'color': Colors.amber,
          'timestamp': now.subtract(const Duration(hours: 1)),
          'metadata': {'achievement': 'first_quiz'},
        });
      }

      if (perfectScores >= 1 && totalQuizzes <= 3) {
        achievements.add({
          'type': 'achievement',
          'title': 'Achievement unlocked: Perfect Score',
          'subtitle':
              'Get 100% on a quiz • ${_formatTimeAgo(now.subtract(const Duration(hours: 2)))}',
          'icon': Icons.emoji_events,
          'color': Colors.purple,
          'timestamp': now.subtract(const Duration(hours: 2)),
          'metadata': {'achievement': 'perfect_score'},
        });
      }

      if (totalQuizzes >= 5 && totalQuizzes <= 7) {
        achievements.add({
          'type': 'achievement',
          'title': 'Achievement unlocked: Quiz Master',
          'subtitle':
              'Complete 5 quizzes • ${_formatTimeAgo(now.subtract(const Duration(days: 1)))}',
          'icon': Icons.quiz,
          'color': Colors.blue,
          'timestamp': now.subtract(const Duration(days: 1)),
          'metadata': {'achievement': 'quiz_master'},
        });
      }
    } catch (e) {
      print('Error calculating achievements: $e');
    }

    return achievements;
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Recent Activities',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecentActivities,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Header section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Learning Journey',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_activities.length} recent activities',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Activities list
                  Expanded(
                    child: _activities.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No activities yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Complete your first quiz to see activities here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _activities.length,
                            itemBuilder: (context, index) {
                              final activity = _activities[index];
                              return _buildActivityCard(activity);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activity['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                activity['icon'],
                color: activity['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity['subtitle'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Additional info for quiz results
            if (activity['type'] == 'quiz' &&
                activity['metadata']['percentage'] >= 80)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Great!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
