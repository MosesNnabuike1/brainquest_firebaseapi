import 'dart:math';
import 'package:intl/intl.dart';
import '../widgets/option_tile.dart';
import '../widgets/question_card.dart';
import 'package:flutter/material.dart';
import '../widgets/answer_overlay.dart';
import '../widgets/question_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/widgets/cancel_icon_widget.dart';
import 'package:firebase_quizzapp/widgets/general_button_widget.dart';

class DailyQuizScreen extends StatefulWidget {
  final String? tutorId;
  const DailyQuizScreen({Key? key, this.tutorId}) : super(key: key);

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  List<Map<String, dynamic>> _questions = [];
  int? _selectedOption;
  bool _showCorrectOverlay = false;
  bool _isCorrect = true;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  List<int?> _selectedAnswers = [];
  bool _submitted = false;
  int _score = 0;
  bool _isLoading = true;

  String? get _tutorId => widget.tutorId;

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
    Future.delayed(Duration.zero, _loadDailyQuiz);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadDailyQuiz() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final tutorId = _tutorId;
      if (tutorId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // First, try to fetch from pre-generated daily quizzes
      final dailyQuizDoc = await FirebaseFirestore.instance
          .collection('daily_quizzes')
          .doc('${today}_$tutorId')
          .get();

      if (dailyQuizDoc.exists) {
        // Use pre-generated daily quiz, use only the available questions (never pad to 10)
        final data = dailyQuizDoc.data()!;
        final questions =
            List<Map<String, dynamic>>.from(data['questions'] ?? []);
        final actualQuestions =
            questions.length <= 10 ? questions : questions.take(10).toList();

        if (actualQuestions.isNotEmpty) {
          setState(() {
            _questions = actualQuestions;
            _selectedAnswers = List<int?>.filled(actualQuestions.length, null);
            _isLoading = false;
            _currentQuestionIndex = 0;
            _selectedOption = null;
            _showCorrectOverlay = false;
            _isCorrect = true;
            _submitted = false;
            _score = 0;
          });
          return;
        }
      }

      // Fallback: Generate daily quiz on client side (limited to 10 questions)
      final categoriesSnap = await FirebaseFirestore.instance
          .collection('categories')
          .where('tutorId', isEqualTo: tutorId)
          .get();
      List<Map<String, dynamic>> allQuestions = [];
      for (var catDoc in categoriesSnap.docs) {
        final questionsSnap = await FirebaseFirestore.instance
            .collection('categories')
            .doc(catDoc.id)
            .collection('questions')
            .get();
        allQuestions.addAll(questionsSnap.docs.map((q) => q.data()));
      }
      if (allQuestions.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No daily quiz questions found for your tutor.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          Future.delayed(const Duration(milliseconds: 300), () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          });
        }
        return;
      }
      allQuestions.sort(
          (a, b) => a['questions'].hashCode.compareTo(b['questions'].hashCode));
      final seed = today.hashCode ^ tutorId.hashCode;
      final random = Random(seed);
      allQuestions.shuffle(random);
      final dailyQuestions = allQuestions.length <= 10
          ? allQuestions
          : allQuestions.take(10).toList();
      setState(() {
        _questions = dailyQuestions;
        _selectedAnswers = List<int?>.filled(dailyQuestions.length, null);
        _isLoading = false;
        _currentQuestionIndex = 0;
        _selectedOption = null;
        _showCorrectOverlay = false;
        _isCorrect = true;
        _submitted = false;
        _score = 0;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double get _progress => _questions.isEmpty
      ? 0.0
      : _submitted
          ? 1.0
          : (_currentQuestionIndex + 1) / _questions.length;

  void _onOptionTap(int index) {
    setState(() {
      _selectedOption = index;
      _selectedAnswers[_currentQuestionIndex] = index;
    });
  }

  void _onSubmit() {
    if (_selectedOption == null) return;
    final currentQuestion = _questions[_currentQuestionIndex];
    final options = [
      currentQuestion['optionA'],
      currentQuestion['optionB'],
      currentQuestion['optionC'],
      currentQuestion['optionD']
    ];
    final selectedOption = options[_selectedOption!];
    final isCorrect = selectedOption == currentQuestion['correctAnswer'];
    if (isCorrect) {
      _score++;
    }
    setState(() {
      _isCorrect = isCorrect;
      _showCorrectOverlay = true;
    });
    _controller.forward();
  }

  void _onNextQuestion() {
    setState(() {
      _showCorrectOverlay = false;
      _selectedOption = null;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _submitted = true;
        _saveQuizResult();
      }
    });
    _controller.reset();
  }

  Future<void> _saveQuizResult() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final now = DateTime.now();
      // Compose questionResults array
      final List<Map<String, dynamic>> questionResults = [];
      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        final options = [
          q['optionA'],
          q['optionB'],
          q['optionC'],
          q['optionD']
        ];
        final selectedIdx = _selectedAnswers[i];
        final selectedValue = selectedIdx != null ? options[selectedIdx] : '';
        questionResults.add({
          'questionText': q['questions'] ?? '',
          'selectedAnswer': selectedValue,
          'correctAnswer': q['correctAnswer'] ?? '',
          'isCorrect': selectedValue == q['correctAnswer'],
        });
      }
      await FirebaseFirestore.instance.collection('quiz_results').add({
        'studentId': user.uid,
        'subject': 'Daily Quiz',
        'topic': '',
        'tutorId': _tutorId ?? '',
        'totalQuestions': _questions.length,
        'correctAnswers': _score,
        'timestamp': Timestamp.fromDate(now),
        'questionResults': questionResults,
        'type': 'daily',
      });
    } catch (e) {
      // Optionally handle error (e.g., show a snackbar)
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_submitted) {
      return _buildResultView(_questions, _score, _selectedAnswers);
    }
    final currentQuestion = _questions[_currentQuestionIndex];
    final options = [
      currentQuestion['optionA'],
      currentQuestion['optionB'],
      currentQuestion['optionC'],
      currentQuestion['optionD']
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: CancelIconWidget(
                  rightPadding: 0,
                  size: 20,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuestionHeader(
                      subject: "Daily Quiz",
                      topic: "Mixed Categories",
                      questionNumber: _currentQuestionIndex + 1,
                      totalQuestions: _questions.length,
                      progress: _progress,
                    ),
                    const SizedBox(height: 30),
                    QuestionCard(
                      questionText:
                          currentQuestion['questions'] ?? 'No question',
                    ),
                    const SizedBox(height: 32),
                    ...options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isCorrect =
                          option == currentQuestion['correctAnswer'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OptionTile(
                          index: index,
                          text: option,
                          selectedOption: _selectedOption,
                          onTap: _onOptionTap,
                          isCorrect: isCorrect,
                          showCorrectAnswer: _showCorrectOverlay,
                          enabled: _selectedOption == null,
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    GeneralButtonWidget(
                      text: _selectedOption != null
                          ? (_currentQuestionIndex == _questions.length - 1
                              ? "Submit"
                              : "Submit")
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
          if (_showCorrectOverlay)
            CorrectOverlay(
              controller: _controller,
              offsetAnimation: _offsetAnimation,
              onNextQuestion: _onNextQuestion,
              isCorrect: _isCorrect,
              buttonText: _currentQuestionIndex == _questions.length - 1
                  ? "See Results"
                  : "Next Question",
            ),
        ],
      ),
    );
  }

  Widget _buildResultView(
      List questions, int score, List<int?> selectedAnswers) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events,
                      color: Color(0xFFFFBA31), size: 32),
                  const SizedBox(width: 10),
                  Text('Quiz Completed!',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Score:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    Text('$score / ${questions.length}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3))),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final q = questions[i];
                    final options = [
                      q['optionA'],
                      q['optionB'],
                      q['optionC'],
                      q['optionD']
                    ];
                    final correct = q['correctAnswer'];
                    final selectedIdx = selectedAnswers[i];
                    final selected =
                        selectedIdx != null ? options[selectedIdx] : null;
                    final wasCorrect = selected == correct;
                    return Container(
                      decoration: BoxDecoration(
                        color: wasCorrect ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: wasCorrect
                              ? Colors.green[200]!
                              : Colors.red[200]!,
                          width: 1.2,
                        ),
                      ),
                      child: ListTile(
                        title: Text(q['questions'] ?? '',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Your answer: ${selected ?? "-"}',
                                style: const TextStyle(color: Colors.black87)),
                            Text('Correct answer: $correct',
                                style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                        trailing: wasCorrect
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.cancel, color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFBA31),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
