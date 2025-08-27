import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String questionText;
  final int? questionLength;

  const QuestionCard({
    Key? key,
    required this.questionText,
    this.questionLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic height based on question length
    double cardHeight = 140; // Default height

    if (questionLength != null) {
      if (questionLength! < 50) {
        cardHeight = 120; // Short questions - increased from 100
      } else if (questionLength! < 100) {
        cardHeight = 140; // Medium questions - increased from 120
      } else if (questionLength! < 150) {
        cardHeight = 160; // Long questions - increased from 140
      } else {
        cardHeight = 180; // Very long questions - increased from 160
      }
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFFFBA31),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/questioncard.png',
              width: double.infinity,
              height: cardHeight,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8), // Increased padding
            child: Text(
              questionText,
              style: const TextStyle(
                fontSize: 16, // Slightly larger font
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: questionLength != null && questionLength! > 100 ? 6 : 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
