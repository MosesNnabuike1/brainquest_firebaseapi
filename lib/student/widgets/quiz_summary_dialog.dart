import 'package:flutter/material.dart';
import 'package:firebase_quizzapp/student/question_page.dart';
import 'package:firebase_quizzapp/student/widgets/general_button_widget.dart';

class QuizSummaryDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    print('\n=== Building QuizSummaryDialog ===');
    print('Subject: $subject');
    print('Topic: $topic');
    print('Category ID: $categoryId');
    print('Tutor ID: $tutorId');

    return AppDialog(
      title: "Quiz Summary",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow("Subject", subject),
          const SizedBox(height: 16),
          _buildSummaryRow("Topic", topic),
          const SizedBox(height: 16),
          _buildSummaryRow("Questions", "$questions Questions"),
          const SizedBox(height: 16),
          _buildSummaryRow("Time", time),
        ],
      ),
      actions: [
        GeneralButtonWidget(
          text: "Start Now",
          onPressed: () {
            if (questions == 0) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No questions available for this quiz.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return QuestionPage(
                    subject: subject,
                    topic: topic,
                    categoryId: categoryId,
                    tutorId: tutorId,
                  );
                },
              ),
            );
          },
          backgroundColor: const Color(0xFF181DB4),
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
