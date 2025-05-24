import 'package:firebase_quizzapp/student/student_category_screen.dart';
import 'package:flutter/material.dart';
import 'common_bottom_nav.dart';
import 'logout_drawer.dart';

class StudentDashboardScreen extends StatefulWidget {
  final String studentName;
  final String profileImageUrl;

  const StudentDashboardScreen({
    Key? key,
    this.studentName = "Student Name",
    this.profileImageUrl = "",
  }) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    // Use pushReplacement with no animation for seamless navigation
    Widget page;
    if (index == 0) {
      page = const StudentDashboardScreen();
    } else if (index == 1) {
      page = const StudentCategoryScreen();
    } else if (index == 2) {
      // page = const ResultScreen(); // Uncomment when implemented
      return;
    } else if (index == 3) {
      // page = const ProfileScreen(); // Uncomment when implemented
      return;
    } else {
      return;
    }
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ));
  }


  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LogoutDrawer(),
      backgroundColor: Colors.white,
      bottomNavigationBar: CommonBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Profile, Notification, Settings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _openDrawer(context),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: widget.profileImageUrl.isNotEmpty
                            ? NetworkImage(widget.profileImageUrl)
                            : null,
                        child: widget.profileImageUrl.isEmpty
                            ? const Icon(Icons.person, size: 28)
                            : null,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.black),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.black),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Welcome Texts
                Text(
                  "Welcome, ${widget.studentName}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Greatness comes from continuous practice!",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 28),
                // More Practice
                const Text(
                  "More Practice",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 14),
                // Daily Quiz Card
                Card(
                  color: const Color(0xFF9ACFF7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  //
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Daily Quiz",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 0),
                                Text(
                                  "20 mixed questions",
                                  style: TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.black54, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Critical Thinking Card
                Card(
                  color: const Color(0xFFFFBA31),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // elevation: 3,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Critical Thing",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 0),
                                Text(
                                  "20 mixed questions",
                                  style: TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.black54, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Language Text Card
                Card(
                  color: const Color(0xFFFDE7D7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Language Text",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 0),
                                Text(
                                  "20 mixed questions",
                                  style: TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.black54, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 28),
                // Recent Activity
                const Text(
                  "Recent Activity",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 14),
                // Recent Activity Container
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8FC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 20, color: Colors.black54),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "You completed 3 quizzes this week",
                              style: TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Divider(height: 1, color: Colors.black12),
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 20, color: Colors.black54),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "You revision Chemistry yesterday",
                              style: TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
