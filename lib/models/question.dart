/// Model class representing a quiz question
class Question {
  // Question properties
  final String id;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;

  /// Creates a new Question instance
  /// 
  /// All parameters are required and represent the question's data
  const Question({
    required this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
  });

  /// Creates a Question instance from a Firestore document map
  /// 
  /// [map] - The Firestore document data
  /// [id] - Optional document ID, if not provided will try to get from map
  factory Question.fromMap(Map<String, dynamic> map, {String? id}) {
    return Question(
      id: id ?? map['id'] ?? '',
      questionText: map['questions'] ?? '',
      optionA: map['optionA'] ?? '',
      optionB: map['optionB'] ?? '',
      optionC: map['optionC'] ?? '',
      optionD: map['optionD'] ?? '',
      correctOption: map['correctAnswer'] ?? '',
    );
  }

  /// Converts the Question instance to a Firestore document map
  Map<String, dynamic> toMap() {
    return {
      'questions': questionText,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctOption,
    };
  }

  /// Returns a list of all options in order (A, B, C, D)
  List<String> get options => [optionA, optionB, optionC, optionD];
} 