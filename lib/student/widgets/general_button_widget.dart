import 'package:flutter/material.dart';

class GeneralButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const GeneralButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF181DB4),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
