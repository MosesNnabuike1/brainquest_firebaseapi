import 'profile_page.dart';
import 'common_bottom_nav.dart';
import 'student_category_screen.dart';
import 'package:flutter/material.dart';
import 'student_dashboard_screen.dart';
import 'results/quiz_results_page.dart';

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
