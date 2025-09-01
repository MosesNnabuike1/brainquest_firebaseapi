import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/widgets/general_button_widget.dart';

class EditQuestionScreen extends StatefulWidget {
  final String tutorId;
  final String questionId;
  final String categoryId;

  const EditQuestionScreen({
    Key? key,
    required this.tutorId,
    required this.questionId,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _optionAController;
  late TextEditingController _optionBController;
  late TextEditingController _optionCController;
  late TextEditingController _optionDController;
  late TextEditingController _answerController;

  bool _isLoading = false;
  bool _isLoadingQuestion = true;
  bool _isLoadingCategories = true;
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  String _correctOption = 'A';
  Map<String, dynamic>? _questionData;
  bool _allowRetakes = true; // Default to allowing retakes

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _optionAController = TextEditingController();
    _optionBController = TextEditingController();
    _optionCController = TextEditingController();
    _optionDController = TextEditingController();
    _answerController = TextEditingController();

    // Set the selected category to the current one
    _selectedCategoryId = widget.categoryId;

    // Fetch both the question data and categories
    _fetchQuestionData();
    _fetchCategories();
  }

  Future<void> _fetchQuestionData() async {
    try {
      print('Fetching question data for ID: ${widget.questionId}');
      final questionDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .collection('questions')
          .doc(widget.questionId)
          .get();

      if (questionDoc.exists) {
        final data = questionDoc.data()!;
        setState(() {
          _questionData = data;
          _questionController.text = data['questions'] ?? '';
          _optionAController.text = data['optionA'] ?? '';
          _optionBController.text = data['optionB'] ?? '';
          _optionCController.text = data['optionC'] ?? '';
          _optionDController.text = data['optionD'] ?? '';
          _answerController.text = data['answer'] ?? '';
          _correctOption = data['correctOption'] ?? 'A';
          _selectedCategoryId = data['categoryId'] ?? widget.categoryId;
          _allowRetakes = data['allowRetakes'] ?? true; // Load retake setting
          _isLoadingQuestion = false;
        });

        print('Question data loaded successfully:');
        print('Question: ${_questionController.text}');
        print('Option A: ${_optionAController.text}');
        print('Option B: ${_optionBController.text}');
        print('Option C: ${_optionCController.text}');
        print('Option D: ${_optionDController.text}');
        print('Answer: ${_answerController.text}');
        print('Correct option: $_correctOption');
        print('Category ID: $_selectedCategoryId');
      } else {
        print('Question document does not exist');
        setState(() {
          _isLoadingQuestion = false;
        });
      }
    } catch (e) {
      print('Error fetching question data: $e');
      setState(() {
        _isLoadingQuestion = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      setState(() {
        _categories = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _updateQuestion() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      String correctAnswerText;
      switch (_correctOption) {
        case 'A':
          correctAnswerText = _optionAController.text.trim();
          break;
        case 'B':
          correctAnswerText = _optionBController.text.trim();
          break;
        case 'C':
          correctAnswerText = _optionCController.text.trim();
          break;
        case 'D':
          correctAnswerText = _optionDController.text.trim();
          break;
        default:
          correctAnswerText = _optionAController.text.trim();
      }

      final questionData = {
        'questions': _questionController.text.trim(),
        'optionA': _optionAController.text.trim(),
        'optionB': _optionBController.text.trim(),
        'optionC': _optionCController.text.trim(),
        'optionD': _optionDController.text.trim(),
        'answer': _answerController.text.trim(),
        'correctOption': _correctOption,
        'correctAnswer': correctAnswerText,
        'categoryId': _selectedCategoryId,
        'tutorId': widget.tutorId,
        'allowRetakes': _allowRetakes, // Add retake setting
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(_selectedCategoryId)
            .collection('questions')
            .doc(widget.questionId)
            .update(questionData);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update question: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildCategoryDropdown() {
    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Select Category',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category['id'],
          child: Text(category['name'] ?? category['title'] ?? 'Categories'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildCorrectOptionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correct Answer:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['A', 'B', 'C', 'D'].map((option) {
            return Expanded(
              child: RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _correctOption,
                onChanged: (value) {
                  setState(() {
                    _correctOption = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRetakeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiz Retake Settings:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Allow students to retake this quiz'),
          subtitle: const Text(
              'When disabled, students cannot retake this quiz once completed'),
          value: _allowRetakes,
          onChanged: (value) {
            setState(() {
              _allowRetakes = value;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print('=== BUILD METHOD ===');
    print('Is loading question: $_isLoadingQuestion');
    print('Is loading categories: $_isLoadingCategories');
    print('Question data: $_questionData');
    print('Question controller text: ${_questionController.text}');
    print('Option A controller text: ${_optionAController.text}');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Question',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoadingQuestion || _isLoadingCategories
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildCategoryDropdown(),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _questionController,
                        label: 'Question',
                        hint: 'Enter your question here',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a question'
                            : null,
                        minLines: 3,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Options:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _optionAController,
                        label: 'Option A',
                        hint: 'Enter option A',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter option A'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _optionBController,
                        label: 'Option B',
                        hint: 'Enter option B',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter option B'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _optionCController,
                        label: 'Option C',
                        hint: 'Enter option C',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter option C'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _optionDController,
                        label: 'Option D',
                        hint: 'Enter option D',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter option D'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _answerController,
                        label: 'Answer Explanation',
                        hint:
                            'Enter explanation for the correct answer (optional)',
                        minLines: 2,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 24),
                      _buildCorrectOptionSelector(),
                      const SizedBox(height: 24),
                      _buildRetakeToggle(),
                      const SizedBox(height: 32),
                      GeneralButtonWidget(
                        text: 'Update Question',
                        onPressed: _isLoading ? null : _updateQuestion,
                        enabled: !_isLoading,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
