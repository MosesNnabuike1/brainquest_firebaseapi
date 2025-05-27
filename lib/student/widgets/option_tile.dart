import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final int index;
  final String text;
  final int? selectedOption;
  final Function(int) onTap;

  const OptionTile({
    Key? key,
    required this.index,
    required this.text,
    required this.selectedOption,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final optionLabels = ['A', 'B', 'C', 'D'];
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selectedOption == index ? const Color(0xFF181DB4) : Colors.black26,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedOption == index ? const Color(0xFF181DB4) : Colors.black26,
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedOption == index ? const Color(0xFF181DB4) : Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              optionLabels[index],
              style: TextStyle(
                color: selectedOption == index ? const Color(0xFF181DB4) : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
