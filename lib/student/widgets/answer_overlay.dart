import 'package:flutter/material.dart';
import 'package:firebase_quizzapp/student/widgets/general_button_widget.dart';

class CorrectOverlay extends StatelessWidget {
  final AnimationController controller;
  final Animation<Offset> offsetAnimation;
  final VoidCallback onNextQuestion;
  final bool isCorrect;

  const CorrectOverlay({
    Key? key,
    required this.controller,
    required this.offsetAnimation,
    required this.onNextQuestion,
    this.isCorrect = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dim background
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.45),
          ),
        ),
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return SlideTransition(
              position: offsetAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: const BoxConstraints(
                      minHeight: 300,
                      maxHeight: 400,
                    ),
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 18),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Good/Bad icon with stars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Left stars (2)
                            Transform.translate(
                              offset: const Offset(25, -30),
                              child: const Icon(Icons.star,
                                  color: Colors.orange, size: 24),
                            ),
                            Transform.translate(
                              offset: const Offset(-18, -45),
                              child: Icon(Icons.star,
                                  color: Colors.orange.withOpacity(0.2),
                                  size: 16),
                            ),
                            // Good or Bad icon in colored circle
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? const Color(0xFFFFBA31)
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isCorrect
                                    ? Icons.thumb_up_alt_rounded
                                    : Icons.thumb_down_alt_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            // Right stars (2)
                            Transform.translate(
                              offset: const Offset(18, -45),
                              child: Icon(
                                Icons.star,
                                color: Colors.orange.withOpacity(0.2),
                                size: 16,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-25, -30),
                              child: const Icon(Icons.star,
                                  color: Colors.orange, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const SizedBox(height: 18),
                        Text(
                          isCorrect ? "Brilliant!" : "Oops!",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isCorrect
                                ? const Color(0xFF181DB4)
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isCorrect
                              ? "Your Answer is correct"
                              : "Your Answer is wrong",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 22),
                        GeneralButtonWidget(
                          text: isCorrect ? "Next Question" : "Try Again",
                          onPressed: onNextQuestion,
                          enabled: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
