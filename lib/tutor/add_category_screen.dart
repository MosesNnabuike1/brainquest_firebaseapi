import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/student/widgets/general_button_widget.dart';

class AddCategoryScreen extends StatefulWidget {
  final String? tutorId;

  const AddCategoryScreen({Key? key, required this.tutorId}) : super(key: key);

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  // Remove _imageFile, _picker, _pickImage, _uploadImage
  // Add a controller for the image URL
  final _imageUrlController = TextEditingController();
  String? _selectedTime;

  // Boolean values
  bool _allowRetakes = false;
  bool _randomizeQuestions = true;

  final List<String> _timeOptions = ['15mins', '30mins', '45mins', '60mins'];

  // Form field controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _questionsController = TextEditingController();

  // Add a FocusNode for the image URL field
  final FocusNode _imageUrlFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_onImageUrlFieldUnfocus);
    // Reset image state every time the widget is initialized
    // _imageFile = null; // Removed
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _questionsController.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  // Helper to convert Google Drive share link to direct link
  String _convertGoogleDriveLink(String url) {
    print('Converting Google Drive link: $url');
    
    // First, try to extract file ID using a more flexible approach
    if (url.contains('drive.google.com/file/d/')) {
      final fileIdMatch = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
      if (fileIdMatch != null) {
        final fileId = fileIdMatch.group(1);
        final convertedUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
        print('Converted to: $convertedUrl');
        return convertedUrl;
      }
    }
    
    // Handle different Google Drive URL formats as fallback
    final patterns = [
      RegExp(r'drive\.google\.com\/file\/d\/([\w-]+)\/view\?usp=drive_link'),
      RegExp(r'drive\.google\.com\/file\/d\/([\w-]+)\/view'),
      RegExp(r'drive\.google\.com\/file\/d\/([\w-]+)\/'),
      RegExp(r'drive\.google\.com\/open\?id=([\w-]+)'),
      RegExp(r'drive\.google\.com\/uc\?id=([\w-]+)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final fileId = match.group(1);
        final convertedUrl = 'https://drive.google.com/uc?export=view&id=$fileId';
        print('Converted to: $convertedUrl');
        return convertedUrl;
      }
    }
    
    print('No conversion needed, returning original: $url');
    return url;
  }

  void _onImageUrlFieldUnfocus() {
    if (!_imageUrlFocusNode.hasFocus) {
      final url = _imageUrlController.text.trim();
      final converted = _convertGoogleDriveLink(url);
      if (converted != url) {
        _imageUrlController.text = converted;
      }
    }
  }

  // Remove _pickImage, _uploadImage

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Always convert the link before saving
      final rawUrl = _imageUrlController.text.trim();
      final imageUrl = _convertGoogleDriveLink(rawUrl);
      _imageUrlController.text = imageUrl; // update the field for user feedback
      
      print('=== Saving Category ===');
      print('Raw URL: $rawUrl');
      print('Converted URL: $imageUrl');
      print('Tutor ID: ${widget.tutorId}');
      
      try {
        await FirebaseFirestore.instance.collection('categories').add({
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'imageAsset': imageUrl, // Now always a direct URL
          'numberofQuestions': int.tryParse(_questionsController.text.trim()) ?? 0,
          'timeAllocation': _selectedTime,
          'allowRetakes': _allowRetakes,
          'randomizeQuestions': _randomizeQuestions,
          'tutorId': widget.tutorId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category added successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add category: [${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add a New Category',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Remove _buildImagePicker()
                  // Add image URL text field
                  _buildTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'Enter category title',
                    validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 18),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Enter category description',
                    validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                    minLines: 3,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 18),
                  _buildTextField(
                    controller: _questionsController,
                    label: 'Number of Questions',
                    hint: 'e.g., 10',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter a number';
                      if (int.tryParse(value) == null) return 'Please enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildDropdownField(
                    label: 'Time Allocation',
                    value: _selectedTime,
                    items: _timeOptions,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTime = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a time' : null,
                  ),
                  const SizedBox(height: 18),
                  _buildTextField(
                    controller: _imageUrlController,
                    label: 'Image URL',
                    hint: 'Paste a public image link (e.g. Google Drive, Imgur, etc.)',
                    validator: (value) => value!.isEmpty ? 'Please enter an image URL' : null,
                    focusNode: _imageUrlFocusNode,
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchTile(
                    title: 'Randomize Questions',
                    value: _randomizeQuestions,
                    onChanged: (bool value) => setState(() => _randomizeQuestions = value),
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    title: 'Allow Retakes',
                    value: _allowRetakes,
                    onChanged: (bool value) => setState(() => _allowRetakes = value),
                  ),
                  const SizedBox(height: 40),
                  GeneralButtonWidget(
                    text: 'Save Category',
                    onPressed: _isLoading ? null : _saveCategory,
                    enabled: !_isLoading,
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Remove _buildImagePicker

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int maxLines = 1,
    FocusNode? focusNode,
  }) {
    InputDecoration fieldDecoration = _inputDecoration(hint);

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
          decoration: fieldDecoration,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          validator: validator,
          focusNode: focusNode,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.normal,
        fontSize: 15,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF181DB4), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _buildDropdownField({
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
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: _inputDecoration('Select time'),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
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
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.red.shade700,
            inactiveThumbColor: Colors.black,
          ),
        ),
      ],
    );
  }
} 