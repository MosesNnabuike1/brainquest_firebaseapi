import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_quizzapp/student/auth/student_login_screen.dart';
import 'package:firebase_quizzapp/student/auth/student_registration_screen.dart';
//import 'package:firebase_quizzapp/student/question_page.dart';
import 'package:firebase_quizzapp/student/student_welcome_screen.dart';
//import 'package:firebase_quizzapp/student/student_welcome_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set StudentWelcomeScreen as home
      home: const StudentWelcomeScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/register': (context) => const StudentRegistrationScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}