import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/widgets/general_button_widget.dart';

class AddQuestionScreen extends StatefulWidget {
  final String? tutorId;
  final String? categoryId;
  final String? categoryTitle;
  final bool filterLanguageCategories;

  const AddQuestionScreen({
    Key? key,
    this.tutorId,
    this.categoryId,
    this.categoryTitle,
    this.filterLanguageCategories = false,
  }) : super(key: key);

  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];

  // Form field controllers
  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  String _correctOption = 'A'; // Default to option A

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.tutorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tutor ID is missing!'),
              backgroundColor: Colors.red),
        );
        Navigator.pop(context);
        return;
      }
      _loadCategories();
      // If category is pre-selected, set it
      if (widget.categoryId != null && widget.categoryTitle != null) {
        setState(() {
          _selectedCategoryId = widget.categoryId;
        });
      }
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('tutorId', isEqualTo: widget.tutorId)
          .get();

      List<Map<String, dynamic>> categories = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc.data()['title'] ?? '',
          'subject': doc.data()['subject'] ?? '',
        };
      }).toList();

      if (widget.filterLanguageCategories) {
        categories = categories.where((cat) {
          final title = cat['title'].toString().toLowerCase();
          final subject = cat['subject'].toString().toLowerCase();
          return title.contains('language') ||
              title.contains('english') ||
              subject.contains('language') ||
              subject.contains('english');
        }).toList();
      }

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading categories:  {e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the correct answer text based on selected option
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

      // Create question data
      final questionData = {
        'questions': _questionController.text.trim(),
        'optionA': _optionAController.text.trim(),
        'optionB': _optionBController.text.trim(),
        'optionC': _optionCController.text.trim(),
        'optionD': _optionDController.text.trim(),
        'correctAnswer': correctAnswerText,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add question to the selected category
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(_selectedCategoryId)
          .collection('questions')
          .add(questionData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add question: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCategoryDropdown() {
    if (_isLoading) {
      // Show a skeleton loader for the dropdown
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        alignment: Alignment.centerLeft,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: 120,
            height: 16,
            child: LinearProgressIndicator(minHeight: 8),
          ),
        ),
      );
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
          child: Text(category['title']),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Question',
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
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildCategoryDropdown(),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _questionController,
                  label: 'Question',
                  hint: 'Enter your question here',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a question' : null,
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
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter option A' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _optionBController,
                  label: 'Option B',
                  hint: 'Enter option B',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter option B' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _optionCController,
                  label: 'Option C',
                  hint: 'Enter option C',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter option C' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _optionDController,
                  label: 'Option D',
                  hint: 'Enter option D',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter option D' : null,
                ),
                const SizedBox(height: 24),
                _buildCorrectOptionSelector(),
                const SizedBox(height: 32),
                GeneralButtonWidget(
                  text: 'Add Question',
                  onPressed: _isLoading ? null : _saveQuestion,
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
