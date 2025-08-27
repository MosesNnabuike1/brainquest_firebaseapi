import '../../models/quiz_result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/student/widgets/fixed_header.dart';

class QuizResultsPage extends StatefulWidget {
  const QuizResultsPage({Key? key}) : super(key: key);

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
  bool _initialLoading = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FixedHeader(
                studentName: user?.displayName ?? 'Student Name',
                onProfileTap: () {},
                onSettingsTap: () {},
                onDrawerOpen: () {},
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('quiz_results')
                        .where('studentId', isEqualTo: user?.uid)
                        .orderBy('timestamp', descending: true)
                        .limit(50)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final isWaiting =
                          snapshot.connectionState == ConnectionState.waiting;
                      if (_initialLoading && !isWaiting) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _initialLoading = false);
                        });
                      }
                      return Stack(
                        children: [
                          if (snapshot.hasError)
                            Center(
                              child: Text('Error: \\${snapshot.error}'),
                            )
                          else if (isWaiting)
                            const SizedBox.shrink()
                          else if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.quiz_outlined,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No Quiz Results Yet',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Complete some quizzes to see your results here',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final doc = snapshot.data!.docs[index];
                                final result = QuizResult.fromMap(
                                    doc.id, doc.data() as Map<String, dynamic>);
                                return Card(
                                  color: const Color.fromRGBO(250, 250, 250, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      context.push('/quiz-history', extra: {
                                        'resultId': doc.id,
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          _buildScoreCircle(result.score),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  result.subject,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  result.topic,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${result.correctAnswers}/${result.totalQuestions} correct • ${_formatDate(result.timestamp)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward_ios,
                                              color: Colors.black54, size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (isWaiting || _initialLoading)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.3),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(double score) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getScoreColor(score).withOpacity(0.1),
        border: Border.all(
          color: _getScoreColor(score),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${score.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getScoreColor(score),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
