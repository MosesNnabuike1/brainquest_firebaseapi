import 'category_quiz_row.dart';
import '../../models/category.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final CategoryData category;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String categoryId;
  final String tutorId;
  final bool isTutor;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.isExpanded,
    required this.onToggle,
    required this.categoryId,
    required this.tutorId,
    this.isTutor = false,
  }) : super(key: key);

  // Helper to convert Google Drive share link to direct link
  String _convertGoogleDriveLink(String url) {
    // First, try to extract file ID using a more flexible approach
    if (url.contains('drive.google.com/file/d/')) {
      final fileIdMatch = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
      if (fileIdMatch != null) {
        final fileId = fileIdMatch.group(1);
        final convertedUrl =
            'https://drive.google.com/uc?export=view&id=$fileId';
        return convertedUrl;
      }
    }

    // Handle different Google Drive URL formats as fallback
    final patterns = [
      RegExp(r'drive\.google\.com\/file\/d\/([\w-]+)\/view\?usp=drive_link'),
      RegExp(r'drive\.google\.com\/file\/d\/([\w-]+)\/view'),
      RegExp(r'drive\.google\.com\/file\/d\/([\w-]+)\/'),
      RegExp(r'drive\.google\.com\/open\?id=([\w-]+)'),
      RegExp(r'drive\.google\.com\/uc\?id=([\w-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final fileId = match.group(1);
        final convertedUrl =
            'https://drive.google.com/uc?export=view&id=$fileId';
        return convertedUrl;
      }
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(250, 250, 250, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      child: Column(
        children: [
          _buildHeader(),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Container(
                    color: Colors.white,
                    child: Column(
                      children: category.topics.map((topic) {
                        return Column(
                          children: [
                            CategoryQuizRow(
                              title: topic.title,
                              questions: topic.questions,
                              buttonColor: const Color(0xFFFFBA31),
                              textColor: Colors.black,
                              subject: topic.subject,
                              categoryId: categoryId,
                              tutorId: tutorId,
                              showAddQuestionButton: isTutor,
                            ),
                            if (topic != category.topics.last)
                              const Divider(height: 1, color: Colors.black12),
                          ],
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () {
        onToggle();
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (category.iconPath.isNotEmpty)
              Builder(
                builder: (context) {
                  return Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: category.iconPath.startsWith('http')
                          ? Builder(
                              builder: (context) {
                                final convertedUrl =
                                    _convertGoogleDriveLink(category.iconPath);
                                return Image.network(
                                  convertedUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 24,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          : Image.asset(
                              category.iconPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                    ),
                  );
                },
              )
            else
              Builder(
                builder: (context) {
                  return const SizedBox.shrink();
                },
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
