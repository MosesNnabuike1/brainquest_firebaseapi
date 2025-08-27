import 'package:flutter/material.dart';
import '../../models/quiz_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorResultsPage extends StatefulWidget {
  final String? tutorId;

  const TutorResultsPage({
    Key? key,
    this.tutorId,
  }) : super(key: key);

  @override
  State<TutorResultsPage> createState() => _TutorResultsPageState();
}

class _TutorResultsPageState extends State<TutorResultsPage> {
  bool _isLoading = true;
  List<QuizResult> _quizResults = [];
  String? _currentTutorId;
  String _selectedSubject = 'All';
  List<String> _subjects = ['All'];
  final Map<String, String> _studentNames = {}; // Cache for student names
  bool _showAnalytics = true; // Control analytics visibility

  @override
  void initState() {
    super.initState();
    _loadTutorId();
  }

  void _openFilterSheet() {
    if (_subjects.isEmpty) return;
    showDialog(
      context: context,
      builder: (dialogContext) {
        String tempSelection = _selectedSubject;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Filter by Subject',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: DropdownButtonFormField<String>(
                value: tempSelection,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.arrow_drop_down),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setStateDialog(() {
                      tempSelection = newValue;
                    });
                  }
                },
                items: _subjects.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedSubject = tempSelection;
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadTutorId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? tutorId = widget.tutorId;
      if (tutorId == null) {
        final doc = await FirebaseFirestore.instance
            .collection('tutors')
            .doc(user.uid)
            .get();
        tutorId = doc.data()?['tutorId']?.toString();
      }

      setState(() {
        _currentTutorId = tutorId;
      });

      if (tutorId != null && tutorId.isNotEmpty) {
        await _loadQuizResults();
      }
    } catch (e) {
      print('Error loading tutor ID: $e');
    }
  }

  Future<void> _loadQuizResults() async {
    if (_currentTutorId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // First get all results for this tutor without ordering
      final query = FirebaseFirestore.instance
          .collection('quiz_results')
          .where('tutorId', isEqualTo: _currentTutorId);

      final snapshot = await query.get();
      final results = <QuizResult>[];
      final subjects = <String>{'All'};
      final studentIds = <String>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('Quiz result data: $data');

        final result = QuizResult.fromMap(doc.id, data);
        results.add(result);

        print(
            'Parsed result - Student ID: ${result.studentId}, Subject: ${result.subject}');

        if (result.subject.isNotEmpty) {
          subjects.add(result.subject);
        }
        if (result.studentId.isNotEmpty) {
          studentIds.add(result.studentId);
        }
      }

      print('Total student IDs found: ${studentIds.length}');
      print('Student IDs: $studentIds');

      // Sort results by timestamp in memory (descending order)
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Fetch student names for all unique student IDs
      await _fetchStudentNames(studentIds.toList());

      setState(() {
        _quizResults = results;
        _subjects = subjects.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading quiz results: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<QuizResult> get _filteredResults {
    if (_selectedSubject == 'All') {
      return _quizResults;
    }
    return _quizResults
        .where((result) => result.subject == _selectedSubject)
        .toList();
  }

  Future<void> _fetchStudentNames(List<String> studentIds) async {
    try {
      print('Fetching names for ${studentIds.length} students: $studentIds');

      for (String studentId in studentIds) {
        if (!_studentNames.containsKey(studentId)) {
          print('Fetching name for student ID: $studentId');

          // Try to get from users collection first
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(studentId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data();
            print('User data for $studentId: $userData');

            final fullName = userData?['fullName'] ?? userData?['name'] ?? '';
            print('Full name found: "$fullName"');

            _studentNames[studentId] =
                fullName.isNotEmpty ? fullName : 'Unknown Student';
          } else {
            print(
                'User document does not exist for ID: $studentId, trying students collection...');

            // Try students collection as fallback
            final studentDoc = await FirebaseFirestore.instance
                .collection('students')
                .doc(studentId)
                .get();

            if (studentDoc.exists) {
              final studentData = studentDoc.data();
              print('Student data for $studentId: $studentData');

              final fullName =
                  studentData?['fullName'] ?? studentData?['name'] ?? '';
              print('Student name found: "$fullName"');

              _studentNames[studentId] =
                  fullName.isNotEmpty ? fullName : 'Unknown Student';
            } else {
              print('Student document also does not exist for ID: $studentId');
              _studentNames[studentId] = 'Unknown Student';
            }
          }
        }
      }

      print('Final student names map: $_studentNames');
    } catch (e) {
      print('Error fetching student names: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        scrolledUnderElevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        titleSpacing: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: const Text(
          'Student Results',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: _openFilterSheet,
            icon: const Icon(
              Icons.filter_list,
              color: Colors.black,
              size: 22,
            ),
            tooltip: 'Filter by Subject',
          ),
          IconButton(
            onPressed: () {
              print('Manual refresh requested');
              _loadQuizResults();
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
              size: 24,
            ),
            tooltip: 'Refresh Results',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Analytics Summary - Collapsible
            Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(154, 207, 247, 1).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      const Color.fromRGBO(154, 207, 247, 1).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Header with toggle button
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showAnalytics = !_showAnalytics;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.insights,
                                color: Colors.black54,
                                size: 24,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Analytics Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Icon(
                            _showAnalytics
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.black54,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Collapsible content
                  if (_showAnalytics) ...[
                    const Divider(
                      height: 1,
                      color: Color.fromRGBO(154, 207, 247, 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSimpleSummaryItem(
                                'Total Results', '${_quizResults.length}'),
                          ),
                          Expanded(
                            child: _buildSimpleSummaryItem(
                                'Students', '${_studentNames.length}'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredResults.isEmpty
                      ? _buildEmptyState()
                      : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No quiz results yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Students will appear here once they complete quizzes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final result = _filteredResults[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(QuizResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with student info and score
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      const Color.fromRGBO(154, 207, 247, 1).withOpacity(0.1),
                  child: Text(
                    _getStudentInitials(
                        _studentNames[result.studentId] ?? result.studentId),
                    style: const TextStyle(
                      color: Color.fromRGBO(77, 9, 202, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _studentNames[result.studentId] ?? 'Unknown Student',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.subject}${result.topic.isNotEmpty ? ' - ${result.topic}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildScoreBadge(result.score),
              ],
            ),
            const SizedBox(height: 3),
            const Divider(height: 16, color: Colors.black12),
            // Performance details
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Correct',
                      '${result.correctAnswers}/${result.totalQuestions}',
                      Colors.green,
                    ),
                  ),
                  Container(width: 1, height: 28, color: Colors.black12),
                  Expanded(
                    child: _buildStatItem(
                      'Score',
                      '${result.score.toStringAsFixed(1)}%',
                      _getScoreColor(result.score),
                    ),
                  ),
                  Container(width: 1, height: 28, color: Colors.black12),
                  Expanded(
                    child: _buildStatItem(
                      'Date',
                      _formatDate(result.timestamp),
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16, color: Colors.black12),
            const SizedBox(height: 1),
            // Expandable question details
            _buildQuestionDetails(result),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge(double score) {
    Color badgeColor;
    IconData icon;

    if (score >= 80) {
      badgeColor = Colors.green;
      icon = Icons.emoji_events;
    } else if (score >= 60) {
      badgeColor = Colors.orange;
      icon = Icons.check_circle;
    } else {
      badgeColor = Colors.red;
      icon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 16),
          const SizedBox(width: 6),
          Text(
            '${score.toStringAsFixed(0)}%',
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // Removed performance indicator to reduce card height

  Widget _buildQuestionDetails(QuizResult result) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent, width: 0),
        ),
        collapsedShape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent, width: 0),
        ),
        title: const Text(
          'Question Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
        children: result.questionResults.map((question) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: question.isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: question.isCorrect ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.questionText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      question.isCorrect ? Icons.check_circle : Icons.cancel,
                      color: question.isCorrect ? Colors.green : Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selected: ${question.selectedAnswer}',
                        style: TextStyle(
                          fontSize: 11,
                          color: question.isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!question.isCorrect) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.blue, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Correct: ${question.correctAnswer}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getStudentInitials(String name) {
    if (name.isEmpty) return '?';
    if (name.length <= 2) return name.toUpperCase();

    // Try to get initials from full name (e.g., "John Doe" -> "JD")
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }

    return name.substring(0, 2).toUpperCase();
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSimpleSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
