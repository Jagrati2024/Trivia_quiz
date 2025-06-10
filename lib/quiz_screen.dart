import 'dart:async';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:percent_indicator/percent_indicator.dart';
import 'models/question_model.dart';

class QuizScreen extends StatefulWidget {
  final String apiUrl;
  final int timePerQuestion;
 const QuizScreen({
   required this.apiUrl,
   required this.timePerQuestion,});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  final unescape = HtmlUnescape();
  late Timer _timer;
  int _timerSeconds = 15;
  bool _answerSelected = false;
  int? _selectedAnswerIndex;
  int? _correctAnswerIndex;
  bool _fiftyFiftyUsed = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
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
          _correctAnswerIndex = question.answers.indexOf(question.correctAnswer);
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
          _handleTimeOut();
        }
      });
    });
  }

  void _resetTimer() {
    _timer.cancel();
    _timerSeconds = 15;
    _startTimer();
  }

  void _handleAnswer(int selectedIndex) {
    if (_answerSelected) return;

    setState(() {
      _answerSelected = true;
      _selectedAnswerIndex = selectedIndex;
      _correctAnswerIndex = _questions[_currentIndex].answers.indexOf(
          _questions[_currentIndex].correctAnswer
      );

      if (_questions[_currentIndex].correctAnswer ==
          _questions[_currentIndex].answers[selectedIndex]) {
        _score++;
      }

      _animationController.forward();
      _timer.cancel();
    });
  }

  void _handleTimeOut() {
    setState(() {
      _answerSelected = true;
      _correctAnswerIndex = _questions[_currentIndex].answers.indexOf(
          _questions[_currentIndex].correctAnswer
      );
    });
    Future.delayed(Duration(seconds: 2), _nextQuestion);
  }

  void _nextQuestion() {
    _animationController.reset();
    setState(() {
      _currentIndex++;
      _answerSelected = false;
      _selectedAnswerIndex = null;
      _correctAnswerIndex = null;
      if (_currentIndex < _questions.length) {
        _resetTimer();
      }
    });
  }

  void _useFiftyFifty() {
    setState(() {
      _fiftyFiftyUsed = true;
      final question = _questions[_currentIndex];
      final correctIndex = question.answers.indexOf(question.correctAnswer);
      final incorrectAnswers = List<int>.generate(
          question.answers.length,
              (index) => index
      )..remove(correctIndex);
      incorrectAnswers.shuffle();

      question.answers = [
        question.answers[correctIndex],
        question.answers[incorrectAnswers.first]
      ]..shuffle();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnswerButton(int index, String answer) {
    final isCorrect = index == _correctAnswerIndex;
    final isSelected = index == _selectedAnswerIndex;
    final isDisabled = _answerSelected && !isCorrect && !isSelected;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? 1 + _animationController.value * 0.1 : 1,
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isSelected && !_answerSelected)
              BoxShadow(
                color: Colors.indigo.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              )
          ],
        ),
        child: ElevatedButton(
          onPressed: _answerSelected ? null : () => _handleAnswer(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: _answerSelected
                ? (isCorrect
                ? Colors.green.shade400
                : (isSelected ? Colors.red.shade400 : Colors.grey.shade200))
                : Colors.indigo.shade600,
            foregroundColor: _answerSelected && !isCorrect && !isSelected
                ? Colors.grey
                : Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_answerSelected && isCorrect)
                Icon(Icons.check_circle, color: Colors.white)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 100, color: Colors.amber),
            SizedBox(height: 30),
            Text(
              'Quiz Completed!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Your Score: $_score/${_questions.length}',
              style: TextStyle(fontSize: 24, color: Colors.indigo.shade700),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('Play Again'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.indigo.shade50,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentIndex >= _questions.length) {
      return _buildResultsScreen();
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Question ${_currentIndex + 1}/${_questions.length}'),
        actions: [
          if (!_fiftyFiftyUsed && !_answerSelected)
            IconButton(
              icon: Icon(Icons.live_help, color: Colors.white),
              onPressed: _useFiftyFifty,
              tooltip: '50-50 Lifeline',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 40,
              lineWidth: 6,
              percent: _timerSeconds / 15,
              center: Text(
                '$_timerSeconds',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _timerSeconds > 5 ? Colors.indigo : Colors.red,
                ),
              ),
              progressColor: _timerSeconds > 5 ? Colors.indigo : Colors.red,
              backgroundColor: Colors.indigo.shade100,
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  question.question,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: question.answers.length,
                itemBuilder: (context, index) {
                  return _buildAnswerButton(index, question.answers[index]);
                },
              ),
            ),
            if (_answerSelected)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: Text(
                  'Next Question',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
