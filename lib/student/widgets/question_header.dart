import 'package:flutter/material.dart';

class QuestionHeader extends StatelessWidget {
  final String subject;
  final String topic;
  final int questionNumber;
  final int totalQuestions;
  final double progress;

  // Design constants
  static const double _circleDiameter = 80.0;
  static const double _strokeWidth = 8.0;
  static const Color _progressBg = Color(0xFFE0E0E0);
  static const Color _progressColor = Color(0xFFFFBA31);

  const QuestionHeader({
    Key? key,
    required this.subject,
    required this.topic,
    required this.questionNumber,
    required this.totalQuestions,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject and Topic
        Text(
          "$subject - $topic",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        // Question Number and Progress Circle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Question $questionNumber/$totalQuestions",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: _circleDiameter,
                  height: _circleDiameter,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: _progressBg,
                    valueColor: const AlwaysStoppedAnimation<Color>(_progressColor),
                    strokeWidth: _strokeWidth,
                  ),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
