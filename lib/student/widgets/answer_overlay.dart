import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_quizzapp/student/widgets/general_button_widget.dart';

class CorrectOverlay extends StatelessWidget {
  final AnimationController controller;
  final Animation<Offset> offsetAnimation;
  final VoidCallback onNextQuestion;
  final bool isCorrect;
  final String buttonText;

  const CorrectOverlay({
    Key? key,
    required this.controller,
    required this.offsetAnimation,
    required this.onNextQuestion,
    required this.isCorrect,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Dim background
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.45)),
        ),

        // Slide-up "sheet"
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
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: 300,
                      maxHeight: 400,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildStarsAndCenterIcon(),
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
                          text: buttonText,
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
  } // end build

  Widget _buildStarsAndCenterIcon() {
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
        // center circle + svg
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isCorrect ? const Color(0xFFFFBA31) : Colors.red,
            shape: BoxShape.circle,
          ),
          child: isCorrect
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
