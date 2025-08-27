import '../logout_drawer.dart';
import '../../models/category.dart';
import '../widgets/fixed_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/widgets/category_card.dart';
import 'package:firebase_quizzapp/widgets/general_button_widget.dart';

class StudentCategoryScreen extends StatefulWidget {
  final String studentName;
  final String? tutorId;

  const StudentCategoryScreen({
    Key? key,
    this.studentName = "Student Name",
    this.tutorId,
  }) : super(key: key);

  @override
  State<StudentCategoryScreen> createState() => _StudentCategoryScreenState();
}

class _StudentCategoryScreenState extends State<StudentCategoryScreen> {
  final Map<String, bool> _expandedStates = {};
  List<CategoryData> _categories = [];
  bool _isLoading = true;
  bool _isTutor = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userRole = userDoc.data()?['role'];
          setState(() {
            _isTutor = userRole == 'tutor';
          });
        }
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      print('\n=== Starting Category Loading in StudentCategoryScreen ===');
      print('Tutor ID from widget: ${widget.tutorId}');

      if (widget.tutorId == null) {
        print('Tutor ID is null, setting empty categories');
        setState(() {
          _isLoading = false;
          _categories = [];
        });
        return;
      }

      setState(() {
        _isLoading = true;
      });

      print('Calling CategoryDataProvider.getCategories...');
      final categories =
          await CategoryDataProvider.getCategories(widget.tutorId!);
      print('Received ${categories.length} categories from provider');

      // Fetch actual question counts for each category
      for (var category in categories) {
        final questionCount = await _getQuestionCountForCategory(category.id);
        // Update the category's topic with actual question count
        if (category.topics.isNotEmpty) {
          category.topics[0] = QuizTopic(
            title: category.topics[0].title,
            questions: questionCount,
            subject: category.topics[0].subject,
          );
        }
      }

      if (mounted) {
        setState(() {
          print('Updating state with categories...');
          _categories = categories;
          // Initialize expanded states for each category
          for (var category in categories) {
            _expandedStates[category.title.toLowerCase()] = false;
          }
          _isLoading = false;
          print('State update complete');
        });
      }
    } catch (e, stackTrace) {
      print('\n=== Error in StudentCategoryScreen ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _categories = [];
        });
      }
    }
  }

  Future<int> _getQuestionCountForCategory(String categoryId) async {
    try {
      final questionsSnap = await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .collection('questions')
          .get();
      return questionsSnap.docs.length;
    } catch (e) {
      print('Error fetching question count for category $categoryId: $e');
      return 0;
    }
  }

  void _toggleCategory(String category) {
    print('\n=== Toggling Category ===');
    print('Category: $category');
    print('Current expanded state: ${_expandedStates[category]}');

    setState(() {
      _expandedStates[category] = !(_expandedStates[category] ?? false);
    });

    print('New expanded state: ${_expandedStates[category]}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LogoutDrawer(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FixedHeader(
                studentName: widget.studentName,
                onProfileTap: () {
                  // TODO: Implement profile tap
                },
                onSettingsTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AppDialog(
                      title: 'Settings',
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete_outline),
                            title: const Text('Clear App Data'),
                            onTap: () async {
                              Navigator.pop(context);
                              // Show confirmation dialog
                              final shouldClear = await showDialog<bool>(
                                context: context,
                                builder: (context) => AppDialog(
                                  title: 'Clear App Data',
                                  content: const Text(
                                      'This will clear all app data and cache. You will need to log in again. Are you sure?'),
                                  actions: [
                                    GeneralButtonWidget(
                                      text: 'Cancel',
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      backgroundColor: const Color(0xFFFFBA31),
                                      textColor: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    GeneralButtonWidget(
                                      text: 'Clear',
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      backgroundColor: const Color(0xFF181DB4),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              );
                              if (shouldClear == true && context.mounted) {
                                if (!context.mounted) return;
                                context.go('/');
                              }
                            },
                          ),
                        ],
                      ),
                      actions: [
                        GeneralButtonWidget(
                          text: 'Close',
                          onPressed: () => Navigator.pop(context),
                          backgroundColor: const Color(0xFFFFBA31),
                          textColor: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  );
                },
                onDrawerOpen: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageTitle(),
                    const SizedBox(height: 30),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildCategoryList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose a Quiz Category",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Here you can choose a quiz category and practice",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    print('\n=== Building Category List ===');
    print('Tutor ID: ${widget.tutorId}');
    print('Categories count: ${_categories.length}');
    print('Loading state: $_isLoading');
    print('Expanded states: $_expandedStates');

    if (widget.tutorId == null) {
      print('No tutor ID, showing message');
      return const Center(
        child: Text('Please enter a valid Tutor ID'),
      );
    }

    if (_isLoading) {
      print('Still loading, showing progress indicator');
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_categories.isEmpty) {
      print('No categories found, showing message');
      return const Center(
        child: Text('No categories available for this tutor'),
      );
    }

    print('Building ListView with ${_categories.length} categories');
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        print('\nBuilding category card for: ${category.title}');
        print('Category ID: ${category.id}');
        print('Is expanded: ${_expandedStates[category.title.toLowerCase()]}');

        return CategoryCard(
          category: category,
          isExpanded: _expandedStates[category.title.toLowerCase()] ?? false,
          onToggle: () => _toggleCategory(category.title.toLowerCase()),
          categoryId: category.id,
          tutorId: widget.tutorId!,
          isTutor: _isTutor,
        );
      },
    );
  }
}
