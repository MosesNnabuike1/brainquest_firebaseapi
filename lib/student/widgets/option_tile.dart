import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final int index;
  final String text;
  final int? selectedOption;
  final Function(int) onTap;
  final bool isCorrect;
  final bool showCorrectAnswer;
  final bool enabled;

  const OptionTile({
    Key? key,
    required this.index,
    required this.text,
    required this.selectedOption,
    required this.onTap,
    required this.isCorrect,
    this.showCorrectAnswer = false,
    this.enabled = true,
  }) : super(key: key);

  static const List<String> optionLabels = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedOption == index;
    final bool showCorrectColor = isSelected && isCorrect && showCorrectAnswer;
    final bool showIncorrectColor =
        isSelected && !isCorrect && showCorrectAnswer;

    return GestureDetector(
      onTap: enabled ? () => onTap(index) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        decoration: BoxDecoration(
          color: showCorrectColor
              ? const Color.fromRGBO(255, 186, 49, 1) // Yellow for correct
              : showIncorrectColor
                  ? const Color.fromARGB(255, 255, 0, 0) // Red for incorrect
                  : (isSelected
                      ? Colors
                          .blue[50] // Light blue for selected but not submitted
                      : Colors.white), // White for unselected
          borderRadius: BorderRadius.circular(44),
          border: Border.all(
            color: showCorrectColor
                ? const Color.fromRGBO(
                    255, 186, 49, 1) // Yellow border for correct
                : showIncorrectColor
                    ? const Color.fromARGB(
                        255, 255, 12, 12) // Red border for incorrect
                    : (isSelected
                        ? Colors
                            .blue // Blue border for selected but not submitted
                        : Colors.grey.shade300), // Grey border for unselected
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (showCorrectColor
                          ? const Color.fromRGBO(
                              255, 186, 49, 1) // Yellow for correct
                          : showIncorrectColor
                              ? const Color.fromARGB(
                                  255, 255, 12, 12) // Red for incorrect
                              : Colors
                                  .blue) // Blue for selected but not submitted
                      : Colors.grey.shade400, // Grey for unselected
                  width: 2,
                ),
                color: isSelected
                    ? (showCorrectColor
                        ? const Color.fromRGBO(
                            255, 186, 49, 1) // Yellow for correct
                        : showIncorrectColor
                            ? const Color.fromARGB(
                                255, 255, 12, 12) // Red for incorrect
                            : Colors
                                .blue) // Blue for selected but not submitted
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: showCorrectColor
                                  ? const Color.fromRGBO(
                                      255, 186, 49, 1) // Yellow for correct
                                  : showIncorrectColor
                                      ? const Color.fromARGB(
                                          255, 255, 12, 12) // Red for incorrect
                                      : Colors
                                          .blue, // Blue for selected but not submitted
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Option label (A. B. C. D.)
            Text(
              '${optionLabels[index]}.',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            // Option text
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
