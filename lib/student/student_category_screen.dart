import 'package:flutter/material.dart';

class StudentCategoryScreen extends StatefulWidget {
  final String studentName;
  final String profileImageUrl;

  const StudentCategoryScreen({
    Key? key,
    this.studentName = "Student Name",
    this.profileImageUrl = "",
  }) : super(key: key);

  @override
  State<StudentCategoryScreen> createState() => _StudentCategoryScreenState();
}

class _StudentCategoryScreenState extends State<StudentCategoryScreen>
    with SingleTickerProviderStateMixin {
  bool _englishExpanded = false;
  bool _mathExpanded = false;
  bool _economicsExpanded = false;
  bool _agricExpanded = false;
  bool _biologyExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF181DB4),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          currentIndex: 1, // Category tab active
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: "Category",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "Result",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Profile, Notification, Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: widget.profileImageUrl.isNotEmpty
                        ? NetworkImage(widget.profileImageUrl)
                        : null,
                    child: widget.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none,
                            color: Colors.black),
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
              // Page Title and Subtitle
              const Text(
                "Choose a Quiz Category",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Here you can choose a quiz category and practice",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              // English Language Card with Dropdown
              Card(
                color: const Color(0xFFF6F6FE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Category icon in rounded container
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF6FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.menu_book, color: Color(0xFF181DB4), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _englishExpanded = !_englishExpanded;
                                });
                              },
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "English Language",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 0),
                                  Text(
                                    "Comprehension, Grammar, Lexis & ...",
                                    style: TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            _englishExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black54,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _englishExpanded
                          ? Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  _CategoryQuizRow(
                                    title: "Passage Comprehension",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "English Language",
                                          topic: "Passage Comprehension",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                  const Divider(height: 1, color: Colors.black12),
                                  _CategoryQuizRow(
                                    title: "Lexis & Structure Practice",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "English Language",
                                          topic: "Lexis & Structure Practice",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                  const Divider(height: 1, color: Colors.black12),
                                  _CategoryQuizRow(
                                    title: "Synonyms & Antonyms Drill",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "English Language",
                                          topic: "Synonyms & Antonyms Drill",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              // Mathematics Card
              const SizedBox(height: 5),
              Card(
                color: const Color(0xFFF6F6FE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Category icon in rounded container
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF6FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.calculate, color: Color(0xFF181DB4), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _mathExpanded = !_mathExpanded;
                                });
                              },
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mathematics",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 0),
                                  Text(
                                    "Algebra, Geometry, Calculus & ...",
                                    style: TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            _mathExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black54,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _mathExpanded
                          ? Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  _CategoryQuizRow(
                                    title: "Algebra Basics",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Mathematics",
                                          topic: "Algebra Basics",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                  const Divider(height: 1, color: Colors.black12),
                                  _CategoryQuizRow(
                                    title: "Geometry Fundamentals",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Mathematics",
                                          topic: "Geometry Fundamentals",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                  const Divider(height: 1, color: Colors.black12),
                                  _CategoryQuizRow(
                                    title: "Calculus Introduction",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Mathematics",
                                          topic: "Calculus Introduction",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              // Economics Card
              const SizedBox(height: 5),
              Card(
                color: const Color(0xFFF6F6FE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Category icon in rounded container
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF6FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.attach_money, color: Color(0xFF181DB4), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _economicsExpanded = !_economicsExpanded;
                                });
                              },
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Economics",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 0),
                                  Text(
                                    "Micro, Macro, Econometrics & ...",
                                    style: TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            _economicsExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black54,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _economicsExpanded
                          ? Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  _CategoryQuizRow(
                                    title: "Microeconomics Principles",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Economics",
                                          topic: "Microeconomics Principles",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                  const Divider(height: 1, color: Colors.black12),
                                  _CategoryQuizRow(
                                    title: "Macroeconomics Overview",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Economics",
                                          topic: "Macroeconomics Overview",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                  const Divider(height: 1, color: Colors.black12),
                                  _CategoryQuizRow(
                                    title: "Econometrics Basics",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Economics",
                                          topic: "Econometrics Basics",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              // Agricultural Science Card
              const SizedBox(height: 5),
              Card(
                color: const Color(0xFFF6F6FE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Category icon in rounded container
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF6FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.agriculture, color: Color(0xFF181DB4), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _agricExpanded = !_agricExpanded;
                                });
                              },
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Agricultural Science",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 0),
                                  Text(
                                    "Soil Science, Crop Science & ...",
                                    style: TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            _agricExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black54,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _agricExpanded
                          ? Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  _CategoryQuizRow(
                                    title: "Soil Composition and Properties",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Agricultural Science",
                                          topic: "Soil Composition and Properties",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                  const Divider(height: 1, color: Colors.black12),
                                  _CategoryQuizRow(
                                    title: "Crop Physiology and Ecology",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Agricultural Science",
                                          topic: "Crop Physiology and Ecology",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                  const Divider(height: 1, color: Colors.black12),
                                  _CategoryQuizRow(
                                    title: "Agricultural Biotechnology",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Agricultural Science",
                                          topic: "Agricultural Biotechnology",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              // Biology Card
              const SizedBox(height: 5),
              Card(
                color: const Color(0xFFF6F6FE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Category icon in rounded container
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF6FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.biotech, color: Color(0xFF181DB4), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  _biologyExpanded = !_biologyExpanded;
                                });
                              },
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Biology",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 0),
                                  Text(
                                    "Cell Biology, Genetics & ...",
                                    style: TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            _biologyExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black54,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _biologyExpanded
                          ? Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  _CategoryQuizRow(
                                    title: "Cell Structure and Function",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Biology",
                                          topic: "Cell Structure and Function",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                  const Divider(height: 1, color: Colors.black12),
                                  _CategoryQuizRow(
                                    title: "Genetic Principles and Applications",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Biology",
                                          topic: "Genetic Principles and Applications",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                  const Divider(height: 1, color: Colors.black12),
                                  _CategoryQuizRow(
                                    title: "Evolution and Biodiversity",
                                    questions: 20,
                                    onViewQuiz: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const _QuizSummaryDialog(
                                          subject: "Biology",
                                          topic: "Evolution and Biodiversity",
                                          questions: 20,
                                          time: "30mins",
                                        ),
                                      );
                                    },
                                    buttonColor: const Color(0xFFFFBA31),
                                    textColor: Colors.black,
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              // ...existing code...
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryQuizRow extends StatelessWidget {
  final String title;
  final int questions;
  final VoidCallback onViewQuiz;
  final Color buttonColor;
  final Color textColor;

  const _CategoryQuizRow({
    required this.title,
    required this.questions,
    required this.onViewQuiz,
    required this.buttonColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$questions Questions",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onViewQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              elevation: 0,
            ),
            child: Text(
              "View Quiz",
              style: TextStyle(color: textColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizSummaryDialog extends StatelessWidget {
  final String subject;
  final String topic;
  final int questions;
  final String time;

  const _QuizSummaryDialog({
    required this.subject,
    required this.topic,
    required this.questions,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quiz Summary",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 120,
              height: 2,
              color: Colors.black,
              margin: const EdgeInsets.only(bottom: 18, top: 2),
            ),
            Text(
              subject,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              topic,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "$questions multiple choice questions",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Time: $time",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Start quiz logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF181DB4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Start Now",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
