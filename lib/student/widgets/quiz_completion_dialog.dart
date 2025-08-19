import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_quizzapp/student/widgets/general_button_widget.dart';

class QuizCompletionDialog extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const QuizCompletionDialog({
    Key? key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.onRetry,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final score =
        totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
    final isPassing = score >= 60;

    return AppDialog(
      title: isPassing ? "Congratulations!" : "Keep Practicing!",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStarsAndCenterIcon(isPassing),
          const SizedBox(height: 18),
          Text(
            isPassing
                ? "You have successfully completed the quiz."
                : "You need more practice to improve your score.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Score: ",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${score.toStringAsFixed(0)}%",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPassing ? const Color(0xFF181DB4) : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Correct Answers: ",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                "$correctAnswers / $totalQuestions",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        GeneralButtonWidget(
          text: "Exit",
          onPressed: onExit,
          enabled: true,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFF181DB4),
        ),
        GeneralButtonWidget(
          text: "Retry",
          onPressed: onRetry,
          enabled: true,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFFFFBA31),
        ),
      ],
    );
  }

  Widget _buildStarsAndCenterIcon(bool isPassing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        // big star
        Transform.translate(
          offset: const Offset(25, -30),
          child: const Icon(Icons.star, color: Colors.orange, size: 24),
        ),
        // small faded star
        Transform.translate(
          offset: const Offset(-18, -45),
          child: Icon(
            Icons.star,
            color: Colors.orange.withOpacity(0.2),
            size: 16,
          ),
        ),
        // center circle + svg or icon
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isPassing ? const Color(0xFFFFBA31) : Colors.red,
            shape: BoxShape.circle,
          ),
          child: isPassing
              ? SvgPicture.asset(
                  'assets/icons/good.svg',
                  width: 32,
                  height: 32,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.close,
                  size: 32,
                  color: Colors.white,
                ),
        ),
        // small faded star
        Transform.translate(
          offset: const Offset(18, -45),
          child: Icon(
            Icons.star,
            color: Colors.orange.withOpacity(0.2),
            size: 16,
          ),
        ),
        // big star
        Transform.translate(
          offset: const Offset(-25, -30),
          child: const Icon(Icons.star, color: Colors.orange, size: 24),
        ),
      ],
    );
  }
}
