// lib/selection_screen.dart

import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class SelectionScreen extends StatefulWidget {
  final String category;
  final String title;

  SelectionScreen({required this.category, required this.title});

  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  int _numberOfQuestions = 10;
  String _difficulty = 'medium';
  String _type = 'multiple';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Select Number of Questions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              value: _numberOfQuestions.toDouble(),
              min: 5,
              max: 50,
              divisions: 9,
              label: _numberOfQuestions.toString(),
              onChanged: (double value) {
                setState(() {
                  _numberOfQuestions = value.toInt();
                });
              },
            ),
            SizedBox(height: 20),
            Text('Select Difficulty:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _difficulty,
              items: <String>['easy', 'medium', 'hard'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _difficulty = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Select Type:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _type,
              items: <String>['multiple', 'boolean'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _type = newValue!;
                });
              },
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  String apiUrl = 'https://opentdb.com/api.php?amount=$_numberOfQuestions&category=${widget.category}&difficulty=$_difficulty&type=$_type';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(apiUrl: apiUrl),
                    ),
                  );
                },
                child: Text('Start Quiz', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
