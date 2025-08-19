import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResult {
  final String id;
  final String studentId;
  final String subject;
  final String topic;
  final String tutorId;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime timestamp;
  final List<QuestionResult> questionResults;

  QuizResult({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.topic,
    required this.tutorId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timestamp,
    required this.questionResults,
  });

  double get score => (correctAnswers / totalQuestions) * 100;

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'subject': subject,
      'topic': topic,
      'tutorId': tutorId,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timestamp': timestamp,
      'questionResults': questionResults.map((q) => q.toMap()).toList(),
    };
  }

  factory QuizResult.fromMap(String id, Map<String, dynamic> map) {
    final questionResultsRaw = map['questionResults'];
    final questionResultsList = (questionResultsRaw is List)
        ? questionResultsRaw
        : <dynamic>[];
    DateTime timestamp;
    final ts = map['timestamp'];
    if (ts is Timestamp) {
      timestamp = ts.toDate();
    } else if (ts is DateTime) {
      timestamp = ts;
    } else if (ts is String) {
      // Try to parse string timestamp
      timestamp = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      timestamp = DateTime.now();
    }
    return QuizResult(
      id: id,
      studentId: map['studentId'] ?? '',
      subject: map['subject'] ?? '',
      topic: map['topic'] ?? '',
      tutorId: map['tutorId'] ?? '',
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      timestamp: timestamp,
      questionResults: questionResultsList
          .map((q) => QuestionResult.fromMap(q))
          .toList(),
    );
  }
}

class QuestionResult {
  final String questionText;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;

  QuestionResult({
    required this.questionText,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
    };
  }

  factory QuestionResult.fromMap(Map<String, dynamic> map) {
    return QuestionResult(
      questionText: map['questionText'] ?? '',
      selectedAnswer: map['selectedAnswer'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
    );
  }
} 