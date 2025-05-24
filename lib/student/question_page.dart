import 'package:flutter/material.dart';

class QuestionPage extends StatefulWidget {
  final String subject;
  final String topic;
  final int questionNumber;
  final int totalQuestions;

  const QuestionPage({
    Key? key,
    this.subject = "English Language",
    this.topic = "Passage Comprehension",
    this.questionNumber = 7,
    this.totalQuestions = 20,
  }) : super(key: key);

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with back button and subject
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                widget.topic,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Question ${widget.questionNumber}/${widget.totalQuestions}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              // Move progress indicator to the right and a bit up
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Spacer(),
                    _buildProgressIndicator(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Question container
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/questioncard.png',
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: const Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc ut laoreet facilisis, massa erat dictum urna, at dictum velit enim non erat.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Options
              _buildOption(0, "Option A"),
              const SizedBox(height: 14),
              _buildOption(1, "Option B"),
              const SizedBox(height: 14),
              _buildOption(2, "Option C"),
              const SizedBox(height: 14),
              _buildOption(3, "Option D"),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedOption != null ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF181DB4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(int index, String text) {
    final optionLabels = ['A', 'B', 'C', 'D'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: _selectedOption == index ? const Color(0xFF181DB4) : Colors.black26,
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
                  color: _selectedOption == index ? const Color(0xFF181DB4) : Colors.black26,
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
                    color: _selectedOption == index ? const Color(0xFF181DB4) : Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              optionLabels[index],
              style: TextStyle(
                color: _selectedOption == index ? const Color(0xFF181DB4) : Colors.black,
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

  Widget _buildProgressIndicator() {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: widget.questionNumber / widget.totalQuestions,
            backgroundColor: Colors.black26,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
            strokeWidth: 14, // Even thicker
          ),
          Center(
            child: Text(
              "${widget.questionNumber}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
