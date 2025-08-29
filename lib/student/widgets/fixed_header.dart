import 'package:flutter/material.dart';

class FixedHeader extends StatelessWidget {
  final String studentName;
  final VoidCallback? onProfileTap;

  const FixedHeader({
    Key? key,
    required this.studentName,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onProfileTap ??
              () {
                // Default behavior: navigate to profile tab
                // This will be handled by the parent widget
              },
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF181DB4),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        // Removed settings icon and drawer functionality
      ],
    );
  }
}
