import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../student/widgets/question_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/widgets/general_button_widget.dart';

// Simple AppDialog implementation
class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const AppDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: actions,
    );
  }
}

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editQuestion(Map<String, dynamic> question) async {
    await context.push('/tutor/add-question', extra: {
      'tutorId': widget.tutorId,
      'question': question,
      'isEditing': true,
    });
  }

  void _addQuestion() async {
    await context.push('/tutor/add-question', extra: {
      'tutorId': widget.tutorId,
      'categoryId': widget.categoryId,
      'isEditing': false,
    });
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to delete category: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _editCategory() async {
    // Show edit category modal instead of navigating to a new page
    await _showEditCategoryModal();
  }

  Future<void> _showEditCategoryModal() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: widget.categoryTitle);
    final descriptionController = TextEditingController();
    final questionsController = TextEditingController();
    final imageUrlController = TextEditingController();
    String? selectedTime;
    bool allowRetakes = false;
    bool randomizeQuestions = true;
    bool isLoading = false;

    final List<String> timeOptions = ['15mins', '30mins', '45mins', '60mins'];

    // Load existing category data
    try {
      final categoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .get();

      if (categoryDoc.exists) {
        final data = categoryDoc.data()!;
        descriptionController.text = data['description'] ?? '';
        questionsController.text = (data['numberofQuestions'] ?? 0).toString();
        selectedTime = data['timeAllocation'];
        allowRetakes = data['allowRetakes'] ?? false;
        randomizeQuestions = data['randomizeQuestions'] ?? true;
        imageUrlController.text = data['imageAsset'] ?? '';
      }
    } catch (e) {
      print('Error loading category data: $e');
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: const Text(
                'Edit Category',
                style: TextStyle(
                  color: Color(0xFF181DB4),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModalTextField(
                        controller: titleController,
                        label: 'Title',
                        hint: 'Enter category title',
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildModalTextField(
                        controller: descriptionController,
                        label: 'Description',
                        hint: 'Enter category description',
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a description'
                            : null,
                        minLines: 3,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildModalTextField(
                        controller: questionsController,
                        label: 'Number of Questions',
                        hint: 'Enter number of questions',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter a number';
                          if (int.tryParse(value) == null)
                            return 'Please enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildModalDropdown(
                        label: 'Time Allocation',
                        value: selectedTime,
                        items: timeOptions,
                        onChanged: (String? newValue) {
                          setModalState(() {
                            selectedTime = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a time' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildModalTextField(
                        controller: imageUrlController,
                        label: 'Image URL',
                        hint: 'Paste a public image link',
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter an image URL' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildModalSwitchTile(
                        title: 'Randomize Questions',
                        value: randomizeQuestions,
                        onChanged: (bool value) {
                          setModalState(() => randomizeQuestions = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModalSwitchTile(
                        title: 'Allow Retakes',
                        value: allowRetakes,
                        onChanged: (bool value) {
                          setModalState(() => allowRetakes = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setModalState(() => isLoading = true);
                            try {
                              await FirebaseFirestore.instance
                                  .collection('categories')
                                  .doc(widget.categoryId)
                                  .update({
                                'title': titleController.text.trim(),
                                'description':
                                    descriptionController.text.trim(),
                                'numberofQuestions': int.tryParse(
                                        questionsController.text.trim()) ??
                                    0,
                                'timeAllocation': selectedTime,
                                'allowRetakes': allowRetakes,
                                'randomizeQuestions': randomizeQuestions,
                                'imageAsset': imageUrlController.text.trim(),
                                'updatedAt': FieldValue.serverTimestamp(),
                              });

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Category updated successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                // Refresh the screen
                                _fetchQuestions();
                              }
                            } catch (e) {
                              setModalState(() => _isLoading = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Failed to update category: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF181DB4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF181DB4), width: 2),
            ),
          ),
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildModalDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF181DB4), width: 2),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildModalSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF181DB4),
          activeTrackColor: const Color(0xFF181DB4).withOpacity(0.3),
        ),
      ],
    );
  }

  // Helper method to calculate question card height based on question length
  double _getQuestionCardHeight(String questionText) {
    final questionLength = questionText.length;
    double cardHeight = 140; // Default height

    if (questionLength < 50) {
      cardHeight = 120; // Short questions
    } else if (questionLength < 100) {
      cardHeight = 140; // Medium questions
    } else if (questionLength < 150) {
      cardHeight = 160; // Long questions
    } else {
      cardHeight = 180; // Very long questions
    }

    return cardHeight;
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
                    // Category info and actions - reduced size and icons on same row
                    Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF181DB4), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.categoryTitle,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF181DB4)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xFF181DB4), size: 20),
                            tooltip: 'Edit Category',
                            onPressed: _editCategory,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
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
                    if (_questions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'No questions yet. Add your first question!',
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    else
                      ..._questions.map((q) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: 24), // Increased bottom padding
                            child: SwipeToRevealCard(
                              key: Key(q['id']),
                              question: q,
                              onEdit: () => _editQuestion(q),
                              onDelete: () => _deleteQuestion(q['id']),
                              cardHeight:
                                  _getQuestionCardHeight(q['questions'] ?? ''),
                            ),
                          )),
                  ],
                ),
    );
  }
}

class SwipeToRevealCard extends StatefulWidget {
  final Map<String, dynamic> question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double cardHeight;

  const SwipeToRevealCard({
    Key? key,
    required this.question,
    required this.onEdit,
    required this.onDelete,
    required this.cardHeight,
  }) : super(key: key);

  @override
  State<SwipeToRevealCard> createState() => _SwipeToRevealCardState();
}

class _SwipeToRevealCardState extends State<SwipeToRevealCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  double _dragOffset = 0;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0,
      end: -168, // Width of both action buttons (80 + 80 + 8 margin)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      // Limit the drag to only left direction and max reveal distance
      _dragOffset = _dragOffset.clamp(-168.0, 0.0);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_dragOffset < -50) {
      // If dragged more than 50px, reveal the buttons
      _animationController.forward();
      setState(() {
        _isRevealed = true;
        _dragOffset = -168;
      });
    } else {
      // Otherwise, snap back to original position
      _animationController.reverse();
      setState(() {
        _isRevealed = false;
        _dragOffset = 0;
      });
    }
  }

  void _handleTap() {
    if (_isRevealed) {
      // If revealed, hide the buttons
      _animationController.reverse();
      setState(() {
        _isRevealed = false;
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.cardHeight,
          child: Stack(
            children: [
              // Background actions aligned to the question card height
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: widget.cardHeight,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF181DB4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: widget.onEdit,
                          borderRadius: BorderRadius.circular(16),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: widget.cardHeight,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AppDialog(
                                title: 'Delete Question',
                                content: const Text(
                                    'Are you sure you want to delete this question? This action cannot be undone.'),
                                actions: [
                                  GeneralButtonWidget(
                                    text: 'Cancel',
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    backgroundColor: const Color(0xFFFFBA31),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    textColor: Colors.black,
                                  ),
                                  GeneralButtonWidget(
                                    text: 'Delete',
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    backgroundColor: Colors.red,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              widget.onDelete();
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Foreground swipeable question card only
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        _isRevealed ? _slideAnimation.value : _dragOffset, 0),
                    child: GestureDetector(
                      onPanUpdate: _handlePanUpdate,
                      onPanEnd: _handlePanEnd,
                      onTap: _handleTap,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: QuestionCard(
                          questionText: widget.question['questions'] ?? '',
                          questionLength:
                              (widget.question['questions'] ?? '').length,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Static options below the swipeable question card
        ...['optionA', 'optionB', 'optionC', 'optionD']
            .asMap()
            .entries
            .map((entry) {
          final idx = entry.key;
          final opt = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44),
                border: Border.all(color: Colors.grey.shade300, width: 2),
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                      color: Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${String.fromCharCode(65 + idx)}.',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.question[opt] ?? '',
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}
