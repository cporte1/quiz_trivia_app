import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class QuizSummaryScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int numQuestions;
  final int categoryId;
  final String difficulty;
  final String type;

  const QuizSummaryScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.numQuestions,
    required this.categoryId,
    required this.difficulty,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Summary')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Score: $score / $totalQuestions', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      numQuestions: numQuestions,
                      categoryId: categoryId,
                      difficulty: difficulty,
                      type: type,
                    ),
                  ),
                );
              },
              child: const Text('Retake Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
