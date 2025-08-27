import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

// Category and QuizTopic models for quiz categories
class CategoryData {
  final String id;  // Firebase document ID
  final String title;
  final String description;
  final String iconPath;
  final List<QuizTopic> topics;

  const CategoryData({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.topics,
  });
}

class QuizTopic {
  final String title;
  final int questions;
  final String subject;

  const QuizTopic({
    required this.title,
    required this.questions,
    required this.subject,
  });
}

class CategoryDataProvider {
  static Future<List<CategoryData>> getCategories(String? tutorId) async {
    try {
      if (tutorId == null) return [];
      var snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('tutorId', isEqualTo: tutorId)
          .get();
      List<CategoryData> categories = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Fetch actual number of questions in subcollection
        final questionsSnap = await FirebaseFirestore.instance
            .collection('categories')
            .doc(doc.id)
            .collection('questions')
            .get();
        final actualCount = questionsSnap.docs.length;
        categories.add(CategoryData(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          iconPath: data['imageAsset'] ?? '',
          topics: [
            QuizTopic(
              title: data['title'] ?? '',
              questions: actualCount,
              subject: data['title'] ?? '',
            )
          ],
        ));
      }
      categories.sort((a, b) => a.title.compareTo(b.title));
      return categories;
    } catch (e) {
      rethrow;
    }
  }
} 