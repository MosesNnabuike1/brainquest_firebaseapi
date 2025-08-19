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
      print('\n=== Starting Category Fetch Process ===');
      print('Tutor ID received: $tutorId');
      
      if (tutorId == null) {
        print('Tutor ID is null, returning empty list');
        return [];
      }
      
      print('Attempting to fetch categories from Firestore...');
      
      // Query for categories with the exact tutor ID
      print('Querying with tutor ID: $tutorId');
      var snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('tutorId', isEqualTo: tutorId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('Timeout while fetching categories');
              throw TimeoutException('Category fetch timed out');
            },
          );
          
      print('Query results count: ${snapshot.docs.length}');
      
      print('Processing ${snapshot.docs.length} category documents...');
      
      final categories = snapshot.docs.map((doc) {
        print('\nProcessing document:');
        print('Document ID: ${doc.id}');
        print('Document data: ${doc.data()}');
        
        final data = doc.data();
        print('\nCategory Details:');
        print('Title: ${data['title']}');
        print('Description: ${data['description']}');
        print('Image Asset: ${data['imageAsset']}');
        print('Tutor ID: ${data['tutorId']}');
        print('Number of Questions: ${data['numberofQuestions']}');
        
        final category = CategoryData(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          iconPath: data['imageAsset'] ?? '',
          topics: [
            QuizTopic(
              title: data['title'] ?? '',
              questions: data['numberofQuestions'] ?? 0,
              subject: data['title'] ?? '',
            )
          ],
        );
        print('Created category: ${category.title} (ID: ${category.id})');
        return category;
      }).toList();
      
      print('\n=== Category Fetch Process Complete ===');
      print('Total categories fetched: ${categories.length}');
      
      // Sort categories alphabetically by title
      categories.sort((a, b) => a.title.compareTo(b.title));
      
      return categories;
    } catch (e, stackTrace) {
      print('\n=== Error in Category Fetch Process ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
} 