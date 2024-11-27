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
          question.incorrectAnswers = question.incorrectAnswers.map((answer) => unescape.convert(answer)).toList();
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

  void _nextQuestion(int selectedAnswer) {
    if (selectedAnswer != -1 &&
        _questions[_currentIndex].correctAnswer == _questions[_currentIndex].answers[selectedAnswer]) {
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
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Trivia Quiz'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentIndex >= _questions.length) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Trivia Quiz'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Your Score: $_score/${_questions.length}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Play Again', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final answers = question.answers;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trivia Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Question ${_currentIndex + 1} of ${_questions.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              question.question,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ...answers.map((answer) {
              int index = answers.indexOf(answer);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () {
                    _nextQuestion(index);
                  },
                  child: Text(answer, style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            _answeredCorrectly != null
                ? Text(
              _answeredCorrectly! ? 'Correct!' : 'Incorrect!',
              style: TextStyle(fontSize: 16, color: _answeredCorrectly! ? Colors.green : Colors.red),
            )
                : Container(),
            SizedBox(height: 20),
            Text(
              '$_timerSeconds seconds left',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
