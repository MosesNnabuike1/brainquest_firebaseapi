import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/widgets/general_button_widget.dart';

class LanguageTestScreen extends StatefulWidget {
  const LanguageTestScreen({Key? key}) : super(key: key);

  @override
  State<LanguageTestScreen> createState() => _LanguageTestScreenState();
}

class _LanguageTestScreenState extends State<LanguageTestScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _question;
  int? _selectedOption;
  bool _answered = false;
  bool _isCorrect = false;
  int _streak = 0;
  String? _badge;
  User? get _user => FirebaseAuth.instance.currentUser;
  String? _tutorId;
  bool _didLoad = false;

  @override
  void initState() {
    super.initState();
    // Do not call _loadQuestionAndStreak here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      _tutorId = args?['tutorId'];
      _loadQuestionAndStreak();
      _didLoad = true;
    }
  }

  Future<void> _loadQuestionAndStreak() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tutorId = _tutorId;
      if (tutorId == null || _user == null) {
        setState(() {
          _error = 'Tutor ID or user not found.';
          _isLoading = false;
        });
        return;
      }
      // Fetch all language categories for this tutor
      final categoriesSnap = await FirebaseFirestore.instance
          .collection('categories')
          .where('tutorId', isEqualTo: tutorId)
          .get();
      List<Map<String, dynamic>> allQuestions = [];
      for (var catDoc in categoriesSnap.docs) {
        final data = catDoc.data();
        final isLanguage = (data['name']
                    ?.toString()
                    .toLowerCase()
                    .contains('language') ??
                false) ||
            (data['subject']?.toString().toLowerCase().contains('language') ??
                false) ||
            (data['name']?.toString().toLowerCase().contains('english') ??
                false) ||
            (data['subject']?.toString().toLowerCase().contains('english') ??
                false);
        if (isLanguage) {
          final questionsSnap = await FirebaseFirestore.instance
              .collection('categories')
              .doc(catDoc.id)
              .collection('questions')
              .get();
          allQuestions.addAll(questionsSnap.docs.map((q) => q.data()));
        }
      }
      if (allQuestions.isEmpty) {
        setState(() {
          _error = 'No language questions found for your tutor.';
          _isLoading = false;
        });
        return;
      }
      // Deterministically pick one for today
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      allQuestions.sort(
          (a, b) => a['questions'].hashCode.compareTo(b['questions'].hashCode));
      final seed = today.hashCode ^ tutorId.hashCode;
      final random = Random(seed);
      allQuestions.shuffle(random);
      int streak = await _calculateStreak();
      setState(() {
        _question = allQuestions.first;
        _isLoading = false;
        _selectedOption = null;
        _answered = false;
        _isCorrect = false;
        _streak = streak;
        _badge = _getBadgeForStreak(streak);
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading language test: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAttempt(int selectedIndex, bool isCorrect) async {
    if (_user == null) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final options = [
      _question?['optionA'],
      _question?['optionB'],
      _question?['optionC'],
      _question?['optionD'],
    ];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('language_test_attempts')
        .doc(today)
        .set({
      'date': today,
      'question': _question?['questions'],
      'selectedOption': selectedIndex,
      'selectedValue': options[selectedIndex],
      'correctAnswer': _question?['correctAnswer'],
      'isCorrect': isCorrect,
      'explanation': _question?['explanation'],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<int> _calculateStreak() async {
    if (_user == null) return 0;
    final attemptsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('language_test_attempts');
    int streak = 0;
    DateTime date = DateTime.now();
    while (true) {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final doc = await attemptsRef.doc(dateStr).get();
      if (doc.exists) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  String? _getBadgeForStreak(int streak) {
    if (streak >= 30) return '30-Day Streak!';
    if (streak >= 7) return '7-Day Streak!';
    if (streak >= 3) return '3-Day Streak!';
    return null;
  }

  void _onOptionTap(int index) async {
    if (_answered) return;
    final options = [
      _question?['optionA'],
      _question?['optionB'],
      _question?['optionC'],
      _question?['optionD'],
    ];
    final selectedValue = options[index];
    final isCorrect = selectedValue == _question?['correctAnswer'];
    await _saveAttempt(index, isCorrect);
    int streak = await _calculateStreak();
    setState(() {
      _selectedOption = index;
      _answered = true;
      _isCorrect = isCorrect;
      _streak = streak;
      _badge = _getBadgeForStreak(streak);
    });
  }

  void _showHistory() async {
    if (_user == null) return;
    final attemptsSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('language_test_attempts')
        .orderBy('timestamp', descending: true)
        .limit(30)
        .get();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text('Attempt History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...attemptsSnap.docs.map((doc) {
                final data = doc.data();
                return Card(
                  color: data['isCorrect'] == true
                      ? Colors.green[50]
                      : Colors.red[50],
                  child: ListTile(
                    title: Text(data['question'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your answer:  ${data['selectedValue'] ?? '-'}'),
                        Text(
                            'Correct answer:  ${data['correctAnswer'] ?? '-'}'),
                        if ((data['explanation'] ?? '').isNotEmpty)
                          Text('Explanation:  ${data['explanation']}'),
                        Text('Date:  ${data['date'] ?? ''}'),
                      ],
                    ),
                    trailing: data['isCorrect'] == true
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Language Test'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: _showHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _question == null
                  ? const Center(child: Text('No question for today.'))
                  : SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Text('Streak: $_streak',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  if (_badge != null) ...[
                                    const SizedBox(width: 10),
                                    const Icon(Icons.emoji_events,
                                        color: Colors.amber, size: 28),
                                    Text(_badge!,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber)),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFFD7E7D), width: 1),
                                  borderRadius: BorderRadius.circular(18),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24, horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text('Today\'s Language Question:',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 18),
                                      Text(_question!['questions'] ?? '',
                                          style: const TextStyle(fontSize: 18)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              ...List.generate(4, (i) {
                                final options = [
                                  _question?['optionA'],
                                  _question?['optionB'],
                                  _question?['optionC'],
                                  _question?['optionD'],
                                ];
                                final isSelected = _selectedOption == i;
                                final isCorrect =
                                    options[i] == _question?['correctAnswer'];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () => _onOptionTap(i),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 18),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isCorrect && _answered
                                                ? Colors.green[100]
                                                : (!isCorrect && _answered
                                                    ? Colors.red[100]
                                                    : Colors.blue[50]))
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? (isCorrect && _answered
                                                  ? Colors.green
                                                  : (!isCorrect && _answered
                                                      ? Colors.red
                                                      : Colors.blue))
                                              : Colors.grey.shade300,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                              '${String.fromCharCode(65 + i)}.',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              options[i] ?? '',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 32),
                              if (_answered)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _isCorrect
                                          ? Colors.green
                                          : Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isCorrect
                                            ? 'Correct! 🎉'
                                            : 'Incorrect.',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                          'Answer: ${_question!['correctAnswer'] ?? ''}',
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green)),
                                      const SizedBox(height: 12),
                                      if ((_question!['explanation'] ?? '')
                                          .isNotEmpty)
                                        Text(
                                            'Explanation: ${_question!['explanation']}',
                                            style:
                                                const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 24),
                              GeneralButtonWidget(
                                text: 'View History',
                                onPressed: _showHistory,
                                enabled: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }
}
