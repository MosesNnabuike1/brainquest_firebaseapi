import 'dart:async';
import '../../models/question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider class for handling question-related operations with Firestore
class QuestionProvider {
  /// Fetches questions for a specific category from Firestore
  
  /// [categoryId] - The ID of the category to fetch questions for
  /// Returns a list of [Question] objects
  /// Throws [TimeoutException] if the fetch operation takes too long
  static Future<List<Question>> getQuestions(String categoryId) async {
    try {
      // Initialize Firestore references
      final categoryRef = FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId);
          
      // Verify category exists
      final categoryDoc = await categoryRef.get();
      if (!categoryDoc.exists) {
        return [];
      }
      
      // Fetch questions from subcollection
      final questionsRef = categoryRef.collection('questions');
      final questionsSnapshot = await questionsRef.get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Question fetch timed out');
            },
          );
      
      // Handle empty questions case
      if (questionsSnapshot.docs.isEmpty) {
        return [];
      }
      
      // Convert Firestore documents to Question objects
      final questions = questionsSnapshot.docs.map((doc) {
        return Question.fromMap(doc.data(), id: doc.id);
      }).toList();
      
      return questions;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Question>> getQuestionsByTutorId(String tutorId) async {
    try {
      final categoriesSnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('tutorId', isEqualTo: tutorId)
          .get()
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Category fetch timed out');
        },
      );

      List<Question> allQuestions = [];

      for (var categoryDoc in categoriesSnapshot.docs) {
        final questionsSnapshot = await FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryDoc.id)
            .collection('questions')
            .get()
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Question fetch timed out');
          },
        );

        final questions = questionsSnapshot.docs
            .map((doc) => Question.fromMap(doc.data(), id: doc.id))
            .toList();

        allQuestions.addAll(questions);
      }

      return allQuestions;
    } catch (e) {
      rethrow;
    }
  }
}
