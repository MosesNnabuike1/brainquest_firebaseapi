import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_quizzapp/tutor/tutor_login_screen.dart';
import 'package:firebase_quizzapp/widgets/cancel_icon_widget.dart';
import 'package:firebase_quizzapp/student/widgets/general_button_widget.dart';

class TutorRegistrationScreen extends StatefulWidget {
  const TutorRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<TutorRegistrationScreen> createState() => _TutorRegistrationScreenState();
}

class _TutorRegistrationScreenState extends State<TutorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }
    if (!RegExp(r'[!@#\$&*~%^(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain a special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<String> _generateUniqueTutorId(String name) async {
    String base = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    String tutorId;
    bool exists = true;
    final random = Random();
    do {
      String rand = (1000 + random.nextInt(9000)).toString();
      tutorId = '$base-$rand';
      // Check uniqueness in tutors collection
      final query = await FirebaseFirestore.instance
          .collection('tutors')
          .where('tutorId', isEqualTo: tutorId)
          .limit(1)
          .get();
      exists = query.docs.isNotEmpty;
    } while (exists);
    return tutorId;
  }

  Future<void> _registerTutor() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_formKey.currentState!.validate()) {
        // Check if username already exists in 'users' collection
        final usernameQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('fullName', isEqualTo: _usernameController.text.trim())
            .limit(1)
            .get();
        if (usernameQuery.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username already exists. Please choose another.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Generate unique Tutor ID
        String tutorId = await _generateUniqueTutorId(_usernameController.text.trim());

        try {
          // Create user with Firebase Authentication
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          // Save tutor details to Firestore in the 'tutors' collection
          await FirebaseFirestore.instance
              .collection('tutors')
              .doc(userCredential.user!.uid)
              .set({
            'fullName': _usernameController.text.trim(),
            'name': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'tutorId': tutorId,
            'createdAt': Timestamp.now(),
          });

          // Save tutor details to 'users' collection
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'fullName': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'role': 'tutor',
            'tutorId': tutorId,
            'createdAt': Timestamp.now(),
          });

          // Show success dialog with Tutor ID and copy button
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text('Congratulations'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('You have successfully registered as a tutor on the Brain Quest app.'),
                    const SizedBox(height: 16),
                    const Text('Your Tutor ID is:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectableText(tutorId, style: const TextStyle(fontSize: 18, color: Colors.blue)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy Tutor ID'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: tutorId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tutor ID copied to clipboard!')),
                        );
                      },
                    ),
                  ],
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TutorLoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF181DB4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Proceed to Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        } on FirebaseAuthException catch (e) {
          String errorMsg = "Registration failed. Please try again.";
          if (e.code == 'email-already-in-use') {
            errorMsg =
                "This email is already in use. Please use another email.";
          } else if (e.code == 'invalid-email') {
            errorMsg = "The email address is invalid.";
          } else if (e.code == 'weak-password') {
            errorMsg = "The password is too weak.";
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and Cancel Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/logo2.png',
                          width: 24,
                          height: 24,
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: CancelIconWidget(
                            onTap: () => Navigator.of(context).pop(),
                            rightPadding: 0,
                            size: 18,
                            color: const Color.fromARGB(137, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Title
                    const Text(
                      'Create Tutor Account',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fill in your details to register as a tutor',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Username field
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Type your full name as it appears on your ID',
                        hintStyle: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: _validateUsername,
                    ),
                    const SizedBox(height: 16),
                    // Email field
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    // Password field
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Choose a strong password (min. 6 characters)',
                        hintStyle: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: !_showPassword,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 16),
                    // Confirm password field
                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      validator: _validateConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Re-enter your password for confirmation',
                        hintStyle: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _showConfirmPassword = !_showConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Register button
                    GeneralButtonWidget(
                      text: 'Register as Tutor',
                      onPressed: _isLoading ? null : _registerTutor,
                      enabled: !_isLoading,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    const SizedBox(height: 16),
                    // Login link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TutorLoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
} 