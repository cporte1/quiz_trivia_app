import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'quiz_summary_screen.dart';
import 'package:html_unescape/html_unescape.dart';

class QuizScreen extends StatefulWidget {
  final int numQuestions;
  final int categoryId;
  final String difficulty;
  final String type;

  const QuizScreen({
    Key? key,
    required this.numQuestions,
    required this.categoryId,
    required this.difficulty,
    required this.type,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final HtmlUnescape unescape = HtmlUnescape();
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  int _timer = 15;
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final url = Uri.parse(
        'https://opentdb.com/api.php?amount=${widget.numQuestions}&category=${widget.categoryId}&difficulty=${widget.difficulty}&type=${widget.type}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['response_code'] == 0) {
        setState(() {
          _questions = List<Map<String, dynamic>>.from(data['results']).map((q) {
            return {
              'question': unescape.convert(q['question']),
              'options': _shuffleOptions(q),
              'correct_answer': unescape.convert(q['correct_answer']),
            };
          }).toList();
          _isLoading = false;
        });
        _startTimer();
      } else {
        throw Exception('No questions available for the selected options');
      }
    } else {
      throw Exception('Failed to fetch questions');
    }
  }

  List<String> _shuffleOptions(Map<String, dynamic> question) {
    List<String> options = List<String>.from(question['incorrect_answers']);
    options.add(question['correct_answer']);
    options.shuffle();
    return options;
  }

  void _startTimer() {
    _timer = 15;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timer > 0) {
          _timer--;
        } else {
          _countdownTimer.cancel();
          _nextQuestion();
        }
      });
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startTimer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizSummaryScreen(
            score: _score,
            totalQuestions: _questions.length,
            numQuestions: widget.numQuestions,
            categoryId: widget.categoryId,
            difficulty: widget.difficulty,
            type: widget.type,
          ),
        ),
      );
    }
  }

  void _checkAnswer(String answer) {
    if (answer == _questions[_currentIndex]['correct_answer']) {
      setState(() {
        _score++;
      });
    }
    _countdownTimer.cancel();
    _nextQuestion();
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentIndex + 1) / _questions.length),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _questions[_currentIndex]['question'],
              style: const TextStyle(fontSize: 18),
            ),
          ),
          ..._questions[_currentIndex]['options'].map((option) {
            return ElevatedButton(
              onPressed: () => _checkAnswer(option),
              child: Text(option),
            );
          }).toList(),
          Text('Time Left: $_timer seconds'),
        ],
      ),
    );
  }
}
