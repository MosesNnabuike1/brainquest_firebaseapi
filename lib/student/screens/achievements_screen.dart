import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _achievements = [];
  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
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

      // Get user's quiz statistics
      final quizResultsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('quiz_results')
          .get();

      final totalQuizzes = quizResultsSnap.docs.length;
      int totalCorrectAnswers = 0;
      int totalQuestions = 0;
      int perfectScores = 0;
      int consecutiveDays = 0;

      for (var doc in quizResultsSnap.docs) {
        final data = doc.data();
        final correctAnswers = (data['correctAnswers'] ?? 0) as int;
        final totalQuestionsInQuiz = (data['totalQuestions'] ?? 1) as int;

        totalCorrectAnswers += correctAnswers;
        totalQuestions += totalQuestionsInQuiz;

        if (correctAnswers == totalQuestionsInQuiz) {
          perfectScores++;
        }
      }

      // Calculate achievements based on statistics
      final achievements = <Map<String, dynamic>>[];

      // Quiz completion achievements
      if (totalQuizzes >= 1) {
        achievements.add({
          'id': 'first_quiz',
          'title': 'First Steps',
          'description': 'Complete your first quiz',
          'icon': Icons.star,
          'color': Colors.amber,
          'earned': true,
        });
      }

      if (totalQuizzes >= 5) {
        achievements.add({
          'id': 'quiz_master',
          'title': 'Quiz Master',
          'description': 'Complete 5 quizzes',
          'icon': Icons.quiz,
          'color': Colors.blue,
          'earned': true,
        });
      }

      if (totalQuizzes >= 10) {
        achievements.add({
          'id': 'dedicated_learner',
          'title': 'Dedicated Learner',
          'description': 'Complete 10 quizzes',
          'icon': Icons.school,
          'color': Colors.green,
          'earned': true,
        });
      }

      // Perfect score achievements
      if (perfectScores >= 1) {
        achievements.add({
          'id': 'perfect_score',
          'title': 'Perfect Score',
          'description': 'Get 100% on a quiz',
          'icon': Icons.emoji_events,
          'color': Colors.purple,
          'earned': true,
        });
      }

      if (perfectScores >= 3) {
        achievements.add({
          'id': 'excellence',
          'title': 'Excellence',
          'description': 'Get 100% on 3 quizzes',
          'icon': Icons.diamond,
          'color': Colors.orange,
          'earned': true,
        });
      }

      // Accuracy achievements
      if (totalQuestions > 0) {
        final accuracy = (totalCorrectAnswers / totalQuestions) * 100;
        if (accuracy >= 80) {
          achievements.add({
            'id': 'high_accuracy',
            'title': 'High Accuracy',
            'description': 'Maintain 80%+ accuracy',
            'icon': Icons.track_changes,
            'color': Colors.teal,
            'earned': true,
          });
        }
      }

      // Streak achievements (placeholder)
      achievements.add({
        'id': 'streak_3',
        'title': '3-Day Streak',
        'description': 'Take quizzes for 3 consecutive days',
        'icon': Icons.local_fire_department,
        'color': Colors.red,
        'earned': consecutiveDays >= 3,
      });

      achievements.add({
        'id': 'streak_7',
        'title': 'Week Warrior',
        'description': 'Take quizzes for 7 consecutive days',
        'icon': Icons.whatshot,
        'color': Colors.deepOrange,
        'earned': consecutiveDays >= 7,
      });

      setState(() {
        _achievements = achievements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    const Text(
                      'Your Achievements',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_achievements.where((a) => a['earned'] == true).length} of ${_achievements.length} badges earned',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Achievements Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _achievements.length,
                      itemBuilder: (context, index) {
                        final achievement = _achievements[index];
                        final isEarned = achievement['earned'] == true;

                        return Container(
                          decoration: BoxDecoration(
                            color: isEarned
                                ? Colors.white
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isEarned
                                  ? achievement['color']
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                            boxShadow: isEarned
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isEarned
                                        ? achievement['color'].withOpacity(0.1)
                                        : Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    achievement['icon'],
                                    size: 32,
                                    color: isEarned
                                        ? achievement['color']
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  achievement['title'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isEarned
                                        ? Colors.black
                                        : Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  achievement['description'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isEarned
                                        ? Colors.black54
                                        : Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                if (isEarned)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'EARNED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
