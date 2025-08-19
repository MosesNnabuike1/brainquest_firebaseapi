import 'quiz_summary_dialog.dart';
import 'package:flutter/material.dart';
import '../../tutor/tutor_question_list_screen.dart';

class CategoryQuizRow extends StatelessWidget {
  final String title;
  final int questions;
  final Color buttonColor;
  final Color textColor;
  final String subject;
  final String categoryId;
  final String tutorId;
  final bool showAddQuestionButton;

  const CategoryQuizRow({
    Key? key,
    required this.title,
    required this.questions,
    required this.buttonColor,
    required this.subject,
    required this.categoryId,
    required this.tutorId,
    this.textColor = Colors.white,
    this.showAddQuestionButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  questions > 0
                      ? "$questions Questions"
                      : "No questions available",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (showAddQuestionButton) {
                // Tutor: Navigate to TutorQuestionListScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TutorQuestionListScreen(
                      categoryId: categoryId,
                      categoryTitle: title,
                      tutorId: tutorId,
                    ),
                  ),
                );
              } else {
                // Student: Check if there are questions available
                if (questions <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('No questions available in this category yet.'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                // Show quiz dialog if questions are available
                showDialog(
                  context: context,
                  builder: (context) {
                    return QuizSummaryDialog(
                      subject: subject,
                      topic: title,
                      questions: questions,
                      time: "30mins",
                      categoryId: categoryId,
                      tutorId: tutorId,
                    );
                  },
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: showAddQuestionButton || questions > 0
                  ? buttonColor
                  : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              elevation: 0,
            ),
            child: Text(
              showAddQuestionButton
                  ? "View Questions"
                  : (questions > 0 ? "View Quiz" : "No Questions"),
              style: TextStyle(color: textColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
