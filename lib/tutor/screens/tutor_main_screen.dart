import 'tutor_profile_page.dart';
import 'tutor_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'tutor_manage_category_screen.dart';
import '../results/tutor_results_page.dart';
import '../../student/common_bottom_nav.dart';

class TutorMainScreen extends StatefulWidget {
  final String tutorName;
  final String? tutorId;
  final int initialIndex;

  const TutorMainScreen({
    Key? key,
    this.tutorName = "Tutor Name",
    this.tutorId,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<TutorMainScreen> createState() => _TutorMainScreenState();
}

class _TutorMainScreenState extends State<TutorMainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TutorDashboardScreen(
        tutorName: widget.tutorName,
        tutorId: widget.tutorId,
        onOpenProfileTab: () {
          setState(() {
            _selectedIndex = 3;
          });
        },
      ),
      TutorManageCategoryScreen(
        tutorName: widget.tutorName,
        tutorId: widget.tutorId,
      ),
      TutorResultsPage(
        tutorId: widget.tutorId,
      ),
      const TutorProfilePage(),
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
