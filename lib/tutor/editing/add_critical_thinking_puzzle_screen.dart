import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/widgets/general_button_widget.dart';

class AddCriticalThinkingPuzzleScreen extends StatefulWidget {
  final String? tutorId;
  const AddCriticalThinkingPuzzleScreen({Key? key, this.tutorId})
      : super(key: key);

  @override
  State<AddCriticalThinkingPuzzleScreen> createState() =>
      _AddCriticalThinkingPuzzleScreenState();
}

class _AddCriticalThinkingPuzzleScreenState
    extends State<AddCriticalThinkingPuzzleScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  String _correctOption = 'A';
  final _explanationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (widget.tutorId == null) return;
    setState(() {
      _isLoading = true;
    });
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where('tutorId', isEqualTo: widget.tutorId)
        .get();
    setState(() {
      _categories = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'title': doc.data()['title'] ?? '',
              })
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _savePuzzle() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null)
      return;
    setState(() {
      _isLoading = true;
    });
    try {
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
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(_selectedCategoryId)
          .collection('logic_puzzles')
          .add({
        'question': _questionController.text.trim(),
        'optionA': _optionAController.text.trim(),
        'optionB': _optionBController.text.trim(),
        'optionC': _optionCController.text.trim(),
        'optionD': _optionDController.text.trim(),
        'correctAnswer': correctAnswerText,
        'explanation': _explanationController.text.trim(),
        'createdBy': widget.tutorId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Logic puzzle added!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
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
    _explanationController.dispose();
    super.dispose();
  }

  Widget _buildCorrectOptionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Correct Answer:',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Add Logic Puzzle'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Select Category',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat['id'],
                            child: Text(cat['title']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _questionController,
                        decoration: const InputDecoration(
                          labelText: 'Puzzle Question',
                          border: OutlineInputBorder(),
                        ),
                        minLines: 2,
                        maxLines: 4,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter the puzzle question'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Options:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _optionAController,
                        decoration: const InputDecoration(
                          labelText: 'Option A',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter option A'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _optionBController,
                        decoration: const InputDecoration(
                          labelText: 'Option B',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter option B'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _optionCController,
                        decoration: const InputDecoration(
                          labelText: 'Option C',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter option C'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _optionDController,
                        decoration: const InputDecoration(
                          labelText: 'Option D',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter option D'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      _buildCorrectOptionSelector(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _explanationController,
                        decoration: const InputDecoration(
                          labelText: 'Explanation (optional)',
                          border: OutlineInputBorder(),
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      GeneralButtonWidget(
                        text: 'Save Puzzle',
                        onPressed: _isLoading ? null : _savePuzzle,
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
