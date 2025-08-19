import 'package:flutter/material.dart';

class GeneralButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color textColor;

  const GeneralButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.fontSize = 14,
    this.fontWeight = FontWeight.bold,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.backgroundColor = const Color(0xFF181DB4),
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}

// Reusable AppDialog widget for consistent dialogs
class AppDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  final List<Widget> actions;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  const AppDialog({
    Key? key,
    required this.title,
    this.content,
    required this.actions,
    this.borderRadius = 16,
    this.contentPadding = const EdgeInsets.all(24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: contentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (content != null) ...[
              const SizedBox(height: 18),
              content!,
            ],
            const SizedBox(height: 24),
            ..._buildActions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    // Stack actions vertically with spacing
    return actions
        .asMap()
        .entries
        .map((entry) => Padding(
              padding: EdgeInsets.only(top: entry.key == 0 ? 0 : 12),
              child: entry.value,
            ))
        .toList();
  }
}
