import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_quizzapp/student/daily_quiz_screen.dart';
import 'package:firebase_quizzapp/student/student_main_screen.dart';
import 'package:firebase_quizzapp/student/student_welcome_screen.dart';
import 'package:firebase_quizzapp/student/auth/student_login_screen.dart';
import 'package:firebase_quizzapp/student/auth/student_registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Optionally handle errors here, but no print statements
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainQuest',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
        textTheme: ThemeData.light().textTheme.copyWith(
          bodyLarge: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
          bodyMedium: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
          titleLarge: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
        ),
      ),
      home: const StudentWelcomeScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/register': (context) => const StudentRegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const StudentMainScreen(),
        '/category': (context) => const StudentMainScreen(),
        '/results': (context) => const StudentMainScreen(),
        '/daily-quiz': (context) => const DailyQuizScreen(),
        // If you have a profile page, uncomment and implement:
        // '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
