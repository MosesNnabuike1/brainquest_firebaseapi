import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_quizzapp/models/category.dart';
import 'package:firebase_quizzapp/widgets/category_card.dart';
import 'package:firebase_quizzapp/widgets/general_button_widget.dart';

// import 'package:firebase_quizzapp/student/widgets/fixed_header.dart';

class TutorManageCategoryScreen extends StatefulWidget {
  final String tutorName;
  final String? tutorId;
  final bool showAddCategoryDialogOnLoad;

  const TutorManageCategoryScreen({
    Key? key,
    this.tutorName = "Tutor Name",
    this.tutorId,
    this.showAddCategoryDialogOnLoad = false,
  }) : super(key: key);

  @override
  State<TutorManageCategoryScreen> createState() =>
      _TutorManageCategoryScreenState();
}

class _TutorManageCategoryScreenState extends State<TutorManageCategoryScreen> {
  final Map<String, bool> _expandedStates = {};
  List<CategoryData> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      if (widget.tutorId == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _categories = [];
        });
        return;
      }
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      final categories =
          await CategoryDataProvider.getCategories(widget.tutorId!);
      if (!mounted) return;
      setState(() {
        _categories = categories;
        for (var category in categories) {
          _expandedStates[category.title.toLowerCase()] = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _categories = [];
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories: \\${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      _expandedStates[category] = !(_expandedStates[category] ?? false);
    });
  }

  Future<void> _deleteCategory(String categoryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: 'Delete Category',
        content: const Text(
            'Are you sure you want to delete this category? This action cannot be undone.'),
        actions: [
          GeneralButtonWidget(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            backgroundColor: const Color(0xFFFFBA31), // Use app's orange accent
            fontSize: 15,
            fontWeight: FontWeight.bold,
            textColor: Colors.black,
          ),
          GeneralButtonWidget(
            text: 'Delete',
            onPressed: () => Navigator.pop(context, true),
            backgroundColor: Colors.red,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Category deleted.'),
                backgroundColor: Colors.green),
          );
          _loadCategories();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to delete category: \\${e.toString()}'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _editCategory(CategoryData category) async {
    final titleController = TextEditingController(text: category.title);
    final descriptionController =
        TextEditingController(text: category.description);
    final imageController = TextEditingController(text: category.iconPath);
    final questionsController = TextEditingController(
        text: category.topics.isNotEmpty
            ? category.topics[0].questions.toString()
            : '');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: 'Edit Category',
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              TextField(
                controller: questionsController,
                decoration:
                    const InputDecoration(labelText: 'Number of Questions'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          GeneralButtonWidget(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            backgroundColor: const Color(0xFFFFBA31), // Use app's orange accent
            fontSize: 15,
            fontWeight: FontWeight.bold,
            textColor: Colors.black,
          ),
          GeneralButtonWidget(
            text: 'Save',
            onPressed: () => Navigator.pop(context, true),
            backgroundColor: const Color(0xFF181DB4),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
    if (result == true) {
      try {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(category.id)
            .update({
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'imageAsset': imageController.text.trim(),
          'numberofQuestions':
              int.tryParse(questionsController.text.trim()) ?? 0,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Category updated.'),
                backgroundColor: Colors.green),
          );
          _loadCategories();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update category: \\${e.toString()}'),
                backgroundColor: Colors.red),
          );
        }
      }
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
          "Category Management",
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
      ),
      backgroundColor: Colors.white,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              context.push('/tutor/add-category', extra: {
                'tutorId': widget.tutorId,
              });
            },
            backgroundColor: const Color(0xFF181DB4),
            tooltip: 'Add Category',
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //   child: FixedHeader(
            //     studentName: widget.tutorName,
            //     onProfileTap: () {
            //       Scaffold.of(context).openDrawer();
            //     },
            //     onSettingsTap: () {},
            //     onDrawerOpen: () {},
            //   ),
            // ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                "Add new categories, edit and update existing categories.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _categories.isEmpty
                      ? const Center(child: Text('No categories available.'))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          child: Column(
                            children: _categories.map((category) {
                              return Dismissible(
                                key: ValueKey(category.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  color: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    await _editCategory(category);
                                    return false; // Don't actually dismiss
                                  }
                                  return false;
                                },
                                child: GestureDetector(
                                  onLongPress: () {
                                    _deleteCategory(category.id);
                                  },
                                  child: CategoryCard(
                                    category: category,
                                    isExpanded: _expandedStates[
                                            category.title.toLowerCase()] ??
                                        false,
                                    onToggle: () => _toggleCategory(
                                        category.title.toLowerCase()),
                                    categoryId: category.id,
                                    tutorId: widget.tutorId!,
                                    isTutor: true,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
