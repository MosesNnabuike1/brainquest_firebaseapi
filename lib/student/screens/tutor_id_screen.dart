import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/widgets/cancel_icon_widget.dart';

class TutorIdScreen extends StatefulWidget {
  final String studentName;

  const TutorIdScreen({
    Key? key,
    required this.studentName,
  }) : super(key: key);

  @override
  State<TutorIdScreen> createState() => _TutorIdScreenState();
}

class _TutorIdScreenState extends State<TutorIdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tutorIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tutorIdController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Query Firestore to check if the tutor ID exists in tutors collection
        print('Checking tutor ID: ${_tutorIdController.text.trim()}');
        String tutorId = _tutorIdController.text.trim();
        var tutorQuery = await FirebaseFirestore.instance
            .collection('tutors')
            .where('tutorId', isEqualTo: tutorId)
            .limit(1)
            .get();

        if (tutorQuery.docs.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid Tutor ID. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Tutor ID is valid, navigate to student main screen
          if (mounted) {
            context.go('/home', extra: {
              'studentName': widget.studentName,
              'tutorId': tutorId,
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CancelIconWidget(
                          rightPadding: 0,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Welcome Text
                    Text(
                      "Welcome, ${widget.studentName}!",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please enter your Tutor ID to continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Tutor ID Input
                    TextFormField(
                      controller: _tutorIdController,
                      decoration: InputDecoration(
                        labelText: 'Tutor ID',
                        hintText: 'Enter your Tutor ID',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF181DB4)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Tutor ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF181DB4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Help Text
                    const Center(
                      child: Text(
                        'Don\'t have a Tutor ID? Contact your tutor',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
