import 'dart:math';
import '../models/question.dart';
import 'widgets/option_tile.dart';
import 'widgets/question_card.dart';
import 'widgets/answer_overlay.dart';
import 'widgets/question_header.dart';
import 'package:flutter/material.dart';
import 'widgets/question_provider.dart';
import 'widgets/quiz_completion_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/widgets/general_button_widget.dart';

/// A widget that displays a quiz question with multiple choice options
class QuestionPage extends StatefulWidget {
  final String subject;
  final String topic;
  final String categoryId;
  final String tutorId;

  const QuestionPage({
    Key? key,
    required this.subject,
    required this.topic,
    required this.categoryId,
    required this.tutorId,
  }) : super(key: key);

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with SingleTickerProviderStateMixin {
  // State variables for question management
  int? _selectedOption; // Currently selected answer option
  bool _showCorrectOverlay = false; // Controls visibility of answer overlay
  bool _isCorrect = true; // Tracks if the selected answer is correct
  late AnimationController _controller; // Controls animation of answer overlay
  late Animation<Offset> _offsetAnimation; // Defines animation path
  List<Question> _questions = []; // List of questions for the quiz
  int _currentQuestionIndex = 0; // Index of current question
  bool _isLoading = true; // Loading state indicator
  int _correctAnswers = 0; // Track number of correct answers
  bool _isQuizCompleted = false;
  final Map<int, int> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for answer overlay
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // Define the animation path for the overlay
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _loadQuestions();
  }

  double get _progress => _questions.isEmpty
      ? 0.0
      : _isQuizCompleted
          ? 1.0
          : (_currentQuestionIndex + 1) / _questions.length;

  /// Loads and prepares questions for the quiz
  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch questions from the provider
      final allQuestions =
          await QuestionProvider.getQuestions(widget.categoryId);

      // Randomize question order and options
      final random = Random();
      allQuestions.shuffle(random);

      // Shuffle options for each question
      for (var question in allQuestions) {
        final correctOption = question.correctOption;
        question.options.shuffle(random);
        // Find the new index of the correct option after shuffling
        final correctIndex = question.options.indexOf(correctOption);
        if (correctIndex != -1) {
          // Swap the correct option to a random position
          final randomIndex = random.nextInt(question.options.length);
          final temp = question.options[randomIndex];
          question.options[randomIndex] = question.options[correctIndex];
          question.options[correctIndex] = temp;
        }
      }

      // Limit to 10 questions
      final limitedQuestions = allQuestions.take(10).toList();

      if (mounted) {
        setState(() {
          _questions = limitedQuestions;
          _isLoading = false;
          _isQuizCompleted = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _questions = [];
          _isQuizCompleted = false;
        });

        // Show error message if question loading fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading questions: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handles user selection of an answer option
  void _onOptionTap(int index) {
    if (_questions.isEmpty) return;
    setState(() {
      _selectedOption = index;
      _selectedAnswers[_currentQuestionIndex] = index;
    });
  }

  /// Handles answer submission when user taps the submit button
  void _onSubmit() {
    if (_selectedOption == null) return;
    final currentQuestion = _questions[_currentQuestionIndex];
    final selectedOption = currentQuestion.options[_selectedOption!];
    final isCorrect = selectedOption == currentQuestion.correctOption;
    if (isCorrect) {
      _correctAnswers++;
    }
    setState(() {
      _isCorrect = isCorrect;
      _showCorrectOverlay = true;
    });
    _controller.forward();
  }

  /// Handles navigation to next question or quiz completion
  void _onNextQuestion() {
    setState(() {
      _showCorrectOverlay = false;
      _selectedOption = null;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _isQuizCompleted = true;
        _showCompletionDialog();
      }
    });
    _controller.reset();
  }

  void _showCompletionDialog() {
    // Save quiz results
    _saveQuizResults();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizCompletionDialog(
        totalQuestions: _questions.length,
        correctAnswers: _correctAnswers,
        onRetry: () {
          Navigator.pop(context); // Close dialog
          setState(() {
            _currentQuestionIndex = 0;
            _correctAnswers = 0;
            _selectedOption = null;
            _showCorrectOverlay = false;
            _isQuizCompleted = false;
            _selectedAnswers.clear();
          });
          _loadQuestions(); // Reload questions
        },
        onExit: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Return to previous screen
        },
      ),
    );
  }

  Future<void> _saveQuizResults() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final questionResults = _questions.asMap().entries.map((entry) {
        final index = entry.key;
        final question = entry.value;
        final selectedOptionIndex = _selectedAnswers[index];
        final selectedOption = selectedOptionIndex != null
            ? question.options[selectedOptionIndex]
            : '';
        final isCorrect = selectedOption == question.correctOption;

        return {
          'questionText': question.questionText,
          'selectedAnswer': selectedOption,
          'correctAnswer': question.correctOption,
          'isCorrect': isCorrect,
        };
      }).toList();

      await FirebaseFirestore.instance.collection('quiz_results').add({
        'studentId': user.uid,
        'subject': widget.subject,
        'topic': widget.topic,
        'tutorId': widget.tutorId,
        'totalQuestions': _questions.length,
        'correctAnswers': _correctAnswers,
        'timestamp': FieldValue.serverTimestamp(),
        'questionResults': questionResults,
      });
    } catch (e) {
      print('Error saving quiz results: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while questions are being fetched
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show message if no questions are available
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No questions available for this category.'),
        ),
      );
    }

    // Get current question and calculate progress
    final currentQuestion = _questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Main content area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question header with progress
                    QuestionHeader(
                      subject: widget.subject,
                      topic: widget.topic,
                      questionNumber: _currentQuestionIndex + 1,
                      totalQuestions: _questions.length,
                      progress: _progress,
                    ),
                    const SizedBox(height: 30),
                    // Question text
                    QuestionCard(
                      questionText: currentQuestion.questionText,
                    ),
                    const SizedBox(height: 32),
                    // Answer options
                    ...currentQuestion.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isCorrectAnswer =
                          option == currentQuestion.correctOption;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OptionTile(
                          index: index,
                          text: option,
                          selectedOption: _selectedOption,
                          onTap: _onOptionTap,
                          isCorrect: isCorrectAnswer,
                          showCorrectAnswer: _showCorrectOverlay,
                          enabled: _selectedOption == null,
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    // Submit/Next button
                    GeneralButtonWidget(
                      text: _selectedOption != null
                          ? (isLastQuestion ? "Submit" : "Submit")
                          : "Submit",
                      onPressed: _selectedOption != null && !_showCorrectOverlay
                          ? _onSubmit
                          : null,
                      enabled: _selectedOption != null && !_showCorrectOverlay,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Answer overlay that shows correct/incorrect feedback
          if (_showCorrectOverlay)
            CorrectOverlay(
              controller: _controller,
              offsetAnimation: _offsetAnimation,
              onNextQuestion: _onNextQuestion,
              isCorrect: _isCorrect,
              buttonText: isLastQuestion ? "Submit" : "Next Question",
            ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
