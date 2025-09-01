import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/widgets/general_button_widget.dart';

class QuizSummaryDialog extends StatefulWidget {
  final String subject;
  final String topic;
  final int questions;
  final String time;
  final String categoryId;
  final String tutorId;

  const QuizSummaryDialog({
    Key? key,
    required this.subject,
    required this.topic,
    required this.questions,
    required this.time,
    required this.categoryId,
    required this.tutorId,
  }) : super(key: key);

  @override
  State<QuizSummaryDialog> createState() => _QuizSummaryDialogState();
}

class _QuizSummaryDialogState extends State<QuizSummaryDialog> {
  bool _isLoading = true;
  bool _canTakeQuiz = true;
  String _retakeMessage = '';

  @override
  void initState() {
    super.initState();
    _checkQuizEligibility();
  }

  Future<void> _checkQuizEligibility() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _canTakeQuiz = false;
          _retakeMessage = 'User not authenticated';
        });
        return;
      }

      // Check if category allows retakes
      final categoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .get();

      if (!categoryDoc.exists) {
        setState(() {
          _isLoading = false;
          _canTakeQuiz = false;
          _retakeMessage = 'Category not found';
        });
        return;
      }

      final categoryData = categoryDoc.data()!;
      final allowRetakes = categoryData['allowRetakes'] ?? false;

      // Check if student has already taken this quiz
      final existingResults = await FirebaseFirestore.instance
          .collection('quiz_results')
          .where('studentId', isEqualTo: user.uid)
          .where('tutorId', isEqualTo: widget.tutorId)
          .where('topic', isEqualTo: widget.topic)
          .get();

      if (existingResults.docs.isNotEmpty) {
        // Student has already taken this quiz
        if (!allowRetakes) {
          setState(() {
            _isLoading = false;
            _canTakeQuiz = false;
            _retakeMessage =
                'You have already taken this quiz. Retakes are not allowed.';
          });
          return;
        } else {
          setState(() {
            _isLoading = false;
            _canTakeQuiz = true;
            _retakeMessage =
                'You have already taken this quiz. Retakes are allowed.';
          });
          return;
        }
      }

      // Student can take the quiz
      setState(() {
        _isLoading = false;
        _canTakeQuiz = true;
        _retakeMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _canTakeQuiz = false;
        _retakeMessage = 'Error checking quiz eligibility: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('\n=== Building QuizSummaryDialog ===');
    print('Subject: ${widget.subject}');
    print('Topic: ${widget.topic}');
    print('Category ID: ${widget.categoryId}');
    print('Tutor ID: ${widget.tutorId}');

    return AppDialog(
      title: "Quiz Summary",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow("Subject", widget.subject),
          const SizedBox(height: 16),
          _buildSummaryRow("Topic", widget.topic),
          const SizedBox(height: 16),
          _buildSummaryRow("Questions", "${widget.questions} Questions"),
          const SizedBox(height: 16),
          _buildSummaryRow("Time", widget.time),
          if (_retakeMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _canTakeQuiz ? Colors.blue[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _canTakeQuiz ? Colors.blue[200]! : Colors.red[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _canTakeQuiz ? Icons.info : Icons.warning,
                    color: _canTakeQuiz ? Colors.blue[700] : Colors.red[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _retakeMessage,
                      style: TextStyle(
                        color:
                            _canTakeQuiz ? Colors.blue[700] : Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          GeneralButtonWidget(
            text: _canTakeQuiz ? "Start Now" : "Cannot Start",
            onPressed: _canTakeQuiz && widget.questions > 0
                ? () {
                    if (widget.questions == 0) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('No questions available for this quiz.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).pop();
                    context.push('/question', extra: {
                      'subject': widget.subject,
                      'topic': widget.topic,
                      'categoryId': widget.categoryId,
                      'tutorId': widget.tutorId,
                    });
                  }
                : null,
            backgroundColor:
                _canTakeQuiz ? const Color(0xFF181DB4) : Colors.grey,
            fontSize: 16,
          ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
