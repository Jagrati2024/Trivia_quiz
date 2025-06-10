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
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category: ${widget.title}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.indigo)),

                    SizedBox(height: 30),
                    Text('Number of Questions:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Slider(
                      value: _numberOfQuestions.toDouble(),
                      min: 5,
                      max: 50,
                      divisions: 9,
                      label: _numberOfQuestions.toString(),
                      activeColor: Colors.indigo,
                      onChanged: (double value) {
                        setState(() {
                          _numberOfQuestions = value.toInt();
                        });
                      },
                    ),

                    SizedBox(height: 30),
                    Text('Difficulty:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: _difficulty,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.speed),
                      ),
                      items: ['easy', 'medium', 'hard'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value[0].toUpperCase() + value.substring(1)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _difficulty = newValue!;
                        });
                      },
                    ),

                    SizedBox(height: 30),
                    Text('Question Type:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.quiz),
                      ),
                      items: ['multiple', 'boolean'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value[0].toUpperCase() + value.substring(1)),
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
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.play_arrow),
                        label: Text('Start Quiz', style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          String apiUrl =
                              'https://opentdb.com/api.php?amount=$_numberOfQuestions&category=${widget.category}&difficulty=$_difficulty&type=$_type';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(apiUrl: apiUrl),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                          backgroundColor: Colors.indigo,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}