import 'package:flutter/material.dart';
import 'widgets/question_header.dart';
import 'widgets/question_card.dart';
import 'widgets/option_tile.dart';
import 'widgets/answer_overlay.dart';
import 'widgets/general_button_widget.dart';

class QuestionPage extends StatefulWidget {
  final String subject;
  final String topic;
  final int questionNumber;
  final int totalQuestions;

  const QuestionPage({
    Key? key,
    this.subject = "English Language",
    this.topic = "Passage Comprehension",
    this.questionNumber = 7,
    this.totalQuestions = 20,
  }) : super(key: key);

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with SingleTickerProviderStateMixin {
  int? _selectedOption;
  bool _showCorrectOverlay = false;
  bool _isCorrect = true;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onOptionTap(int index) {
    setState(() {
      _selectedOption = index;
    });
    // Option A (index 0) is correct, Option B (index 1) is wrong
    if (index == 0) {
      setState(() {
        _isCorrect = true;
        _showCorrectOverlay = true;
      });
      _controller.forward();
    } else if (index == 1) {
      setState(() {
        _isCorrect = false;
        _showCorrectOverlay = true;
      });
      _controller.forward();
    }
    // For other options, you can add logic as needed
  }

  void _onNextQuestion() {
    setState(() {
      _showCorrectOverlay = false;
      _selectedOption = null;
    });
    _controller.reset();
    // TODO: Load next question logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuestionHeader(
                    subject: widget.subject,
                    topic: widget.topic,
                    questionNumber: widget.questionNumber,
                    totalQuestions: widget.totalQuestions,
                  ),
                  const SizedBox(height: 8),
                  const QuestionCard(
                    questionText:
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc ut laoreet facilisis, massa erat dictum urna, at dictum velit enim non erat.",
                  ),
                  const SizedBox(height: 32),
                  OptionTile(
                    index: 0,
                    text: "Option A",
                    selectedOption: _selectedOption,
                    onTap: _onOptionTap,
                  ),
                  const SizedBox(height: 14),
                  OptionTile(
                    index: 1,
                    text: "Option B",
                    selectedOption: _selectedOption,
                    onTap: _onOptionTap,
                  ),
                  const SizedBox(height: 14),
                  OptionTile(
                    index: 2,
                    text: "Option C",
                    selectedOption: _selectedOption,
                    onTap: _onOptionTap,
                  ),
                  const SizedBox(height: 14),
                  OptionTile(
                    index: 3,
                    text: "Option D",
                    selectedOption: _selectedOption,
                    onTap: _onOptionTap,
                  ),
                  const Spacer(),
                  GeneralButtonWidget(
                    text: "Submit",
                    onPressed: _selectedOption != null ? () {} : null,
                    enabled: _selectedOption != null,
                  ),
                ],
              ),
            ),
          ),
          if (_showCorrectOverlay)
            CorrectOverlay(
              controller: _controller,
              offsetAnimation: _offsetAnimation,
              onNextQuestion: _onNextQuestion,
              isCorrect: _isCorrect,
            ),
        ],
      ),
    );
  }
}
