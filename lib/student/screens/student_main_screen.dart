import '../common_bottom_nav.dart';
import 'package:flutter/material.dart';
import '../results/quiz_results_page.dart';
import 'package:firebase_quizzapp/student/screens/profile_page.dart';
import 'package:firebase_quizzapp/student/screens/student_category_screen.dart';
import 'package:firebase_quizzapp/student/screens/student_dashboard_screen.dart';

class StudentMainScreen extends StatefulWidget {
  final String studentName;
  final String? tutorId;

  const StudentMainScreen({
    Key? key,
    this.studentName = "Student Name",
    this.tutorId,
  }) : super(key: key);

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      StudentDashboardScreen(
        studentName: widget.studentName,
        tutorId: widget.tutorId,
      ),
      StudentCategoryScreen(
        studentName: widget.studentName,
        tutorId: widget.tutorId,
      ),
      const QuizResultsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: CommonBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
