import 'add_question_screen.dart';
import 'package:flutter/material.dart';
import '../student/widgets/question_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/student/widgets/general_button_widget.dart';

class TutorQuestionListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final String tutorId;

  const TutorQuestionListScreen({
    Key? key,
    required this.categoryId,
    required this.categoryTitle,
    required this.tutorId,
  }) : super(key: key);

  @override
  State<TutorQuestionListScreen> createState() =>
      _TutorQuestionListScreenState();
}

class _TutorQuestionListScreenState extends State<TutorQuestionListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final questionsSnap = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .collection('questions')
          .get();
      setState(() {
        _questions = questionsSnap.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading questions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .collection('questions')
          .doc(questionId)
          .delete();
      _fetchQuestions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _editQuestion(Map<String, dynamic> question) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(
          tutorId: widget.tutorId,
          categoryId: widget.categoryId,
          categoryTitle: widget.categoryTitle,
        ),
        settings: RouteSettings(arguments: {'editQuestion': question}),
      ),
    );
    _fetchQuestions();
  }

  void _addQuestion() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(
          tutorId: widget.tutorId,
          categoryId: widget.categoryId,
          categoryTitle: widget.categoryTitle,
        ),
      ),
    );
    _fetchQuestions();
  }

  Future<void> _deleteCategory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: 'Delete Category',
        content: const Text(
            'Are you sure you want to delete this category and all its questions? This cannot be undone.'),
        actions: [
          GeneralButtonWidget(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            backgroundColor: const Color(0xFFFFBA31), // rgba(255, 186, 49, 1)
            fontSize: 15,
            fontWeight: FontWeight.bold,
            textColor: Colors.black,
          ),
          GeneralButtonWidget(
            text: 'Delete',
            onPressed: () => Navigator.pop(context, true),
            backgroundColor: Colors.red,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .delete();
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete category: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editCategory() async {
    // You can implement a category edit screen or dialog here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Edit category not implemented.'),
          backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Questions: ${widget.categoryTitle}',
            style: const TextStyle(
                color: Color(0xFF181DB4), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF181DB4)),
      ),
      floatingActionButton: SizedBox(
        height: 64,
        width: 64,
        child: FloatingActionButton(
          onPressed: _addQuestion,
          backgroundColor: const Color(0xFF181DB4),
          tooltip: 'Add Question',
          elevation: 6,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  children: [
                    // Category info and actions
                    Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: const Color(0xFF181DB4), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.categoryTitle,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF181DB4))),
                                const SizedBox(height: 6),
                                // You can fetch and show the category description here if available
                                // Text('Category description...', style: TextStyle(fontSize: 15, color: Colors.black54)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xFF181DB4)),
                            tooltip: 'Edit Category',
                            onPressed: _editCategory,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Category',
                            onPressed: _deleteCategory,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18, left: 2),
                      child: Text(
                        'All Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    ..._questions.map((q) => Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: QuestionCard(
                                        questionText: q['questions'] ?? '',
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Color(0xFF181DB4),
                                              size: 22),
                                          tooltip: 'Edit',
                                          onPressed: () => _editQuestion(q),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red, size: 22),
                                          tooltip: 'Delete',
                                          onPressed: () async {
                                            final confirmed =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AppDialog(
                                                title: 'Delete Question',
                                                content: const Text(
                                                    'Are you sure you want to delete this question? This action cannot be undone.'),
                                                actions: [
                                                  GeneralButtonWidget(
                                                    text: 'Cancel',
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    backgroundColor:
                                                        const Color(0xFFFFBA31),
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    textColor: Colors.black,
                                                  ),
                                                  GeneralButtonWidget(
                                                    text: 'Delete',
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    backgroundColor: Colors.red,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirmed == true) {
                                              _deleteQuestion(q['id']);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...['optionA', 'optionB', 'optionC', 'optionD']
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final idx = entry.key;
                                final opt = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(44),
                                      border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 2),
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 18),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${String.fromCharCode(65 + idx)}.',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            q[opt] ?? '',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        )),
                  ],
                ),
    );
  }
}
