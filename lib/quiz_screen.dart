import 'dart:async';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/question_model.dart';

class QuizScreen extends StatefulWidget {
  final String apiUrl;

  QuizScreen({required this.apiUrl});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  final unescape = HtmlUnescape();
  late Timer _timer;
  int _timerSeconds = 10;
  bool? _answeredCorrectly;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final response = await http.get(Uri.parse(widget.apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _questions = (data['results'] as List).map((json) => Question.fromJson(json)).toList();
        _questions.forEach((question) {
          question.question = unescape.convert(question.question);
          question.correctAnswer = unescape.convert(question.correctAnswer);
          question.incorrectAnswers =
              question.incorrectAnswers.map((answer) => unescape.convert(answer)).toList();
          question.answers = [...question.incorrectAnswers, question.correctAnswer];
          question.answers.shuffle();
        });
        _startTimer();
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _timer.cancel();
          _nextQuestion(-1);
        }
      });
    });
  }

  void _resetTimer() {
    _timer.cancel();
    _timerSeconds = 10;
    _startTimer();
  }

  void _nextQuestion(int selectedIndex) {
    if (selectedIndex != -1 &&
        _questions[_currentIndex].correctAnswer ==
            _questions[_currentIndex].answers[selectedIndex]) {
      _score++;
      _answeredCorrectly = true;
    } else {
      _answeredCorrectly = false;
    }

    setState(() {
      _currentIndex++;
      if (_currentIndex < _questions.length) {
        _resetTimer();
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.indigo.shade50,
        appBar: AppBar(
          title: Text('Trivia Quiz'),
          backgroundColor: Colors.indigo,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentIndex >= _questions.length) {
      return Scaffold(
        backgroundColor: Colors.indigo.shade50,
        appBar: AppBar(
          title: Text('Trivia Quiz'),
          backgroundColor: Colors.indigo,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              SizedBox(height: 20),
              Text(
                'Your Score: $_score/${_questions.length}',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text('Play Again', style: TextStyle(fontSize: 18, color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Trivia Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Question ${_currentIndex + 1} of ${_questions.length}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: _timerSeconds / 10,
            backgroundColor: Colors.grey.shade300,
            color: Colors.indigo,
            minHeight: 8,
          ),
          SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                question.question,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 20),
          ...question.answers.map((answer) {
            int index = question.answers.indexOf(answer);
            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ElevatedButton(
                onPressed: () => _nextQuestion(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(answer, style: TextStyle(fontSize: 16)),
              ),
            );
          }),
          SizedBox(height: 20),
          if (_answeredCorrectly != null)
            Center(
              child: Text(
                _answeredCorrectly! ? '✅ Correct!' : '❌ Incorrect!',
                style: TextStyle(
                  fontSize: 18,
                  color: _answeredCorrectly! ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Spacer(),
          Center(
            child: Text(
              '⏳ $_timerSeconds seconds left',
              style: TextStyle(fontSize: 16, color: Colors.indigo.shade700),
            ),
          ),
          SizedBox(height: 10),
        ]),
      ),
    );
  }
}