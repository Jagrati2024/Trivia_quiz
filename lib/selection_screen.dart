import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class SelectionScreen extends StatefulWidget {
  final String category;
  final String title;

  const SelectionScreen({required this.category, required this.title});

  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  int _numberOfQuestions = 10;
  String _difficulty = 'medium';
  String _type = 'multiple';
  int _timePerQuestion = 20; // New feature: Time limit

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,style: TextStyle(color: Colors.white),),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

          ),

        ),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: Colors.purple.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeader(),
                      const SizedBox(height: 30),

                      // Number of Questions
                      _buildQuestionSlider(),
                      const SizedBox(height: 30),

                      // Difficulty Selector
                      _buildDifficultySelector(),
                      const SizedBox(height: 30),

                      // Question Type
                      _buildTypeSelector(),
                      const SizedBox(height: 30),

                      // Time Limit (New Feature)
                      _buildTimeLimitSelector(),
                      const SizedBox(height: 40),

                      // Action Buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.quiz, size: 32, color: Colors.purple),
        const SizedBox(width: 15),
        Text(
          'Setup Your Quiz',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Questions: $_numberOfQuestions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Slider(
          value: _numberOfQuestions.toDouble(),
          min: 5,
          max: 50,
          divisions: 9,
          label: '$_numberOfQuestions',
          activeColor: Colors.purple,
          inactiveColor: Colors.purple.shade100,
          thumbColor: Colors.white,
          onChanged: (value) => setState(() => _numberOfQuestions = value.toInt()),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty Level:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _difficulty,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.purple.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.speed, color: Colors.purple),
          ),
          items: ['easy', 'medium', 'hard'].map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value[0].toUpperCase() + value.substring(1),
                style: TextStyle(color: Colors.purple.shade800),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _difficulty = value!),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (index) {
            return Icon(
              Icons.star,
              color: _difficulty == 'easy' && index < 1 ||
                  _difficulty == 'medium' && index < 2 ||
                  _difficulty == 'hard' && index < 3
                  ? Colors.amber
                  : Colors.grey.shade300,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Type:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _type,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.purple.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.format_list_bulleted, color: Colors.purple),
          ),
          items: [
            {'value': 'multiple', 'label': 'Multiple Choice'},
            {'value': 'boolean', 'label': 'True/False'},
          ].map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']!,
                  style: TextStyle(color: Colors.purple.shade800)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _type = value!),
        ),
      ],
    );
  }

  Widget _buildTimeLimitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time per Question:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [10, 20, 30].map((seconds) {
            return ChoiceChip(
              label: Text('$seconds sec'),
              selected: _timePerQuestion == seconds,
              selectedColor: Colors.purple,
              labelStyle: TextStyle(
                color: _timePerQuestion == seconds ? Colors.white : Colors.purple,
              ),
              onSelected: (selected) => setState(() => _timePerQuestion = seconds),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Start Quiz Button
        ElevatedButton.icon(
          icon: Icon(Icons.play_arrow, size: 28),
          label: const Text('Start Quiz', style: TextStyle(fontSize: 20)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            foregroundColor: Colors.white,
            backgroundColor: Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            shadowColor: Colors.purple.withOpacity(0.3),
          ),
          onPressed: () {
            final apiUrl =
                'https://opentdb.com/api.php?amount=$_numberOfQuestions'
                '&category=${widget.category}&difficulty=$_difficulty'
                '&type=$_type';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(
                  apiUrl: apiUrl,
                  timePerQuestion: _timePerQuestion,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // Quick Start Button (New Feature)
        OutlinedButton.icon(
          icon: Icon(Icons.flash_on, color: Colors.purple),
          label: Text('Quick Start', style: TextStyle(color: Colors.purple)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(
                  apiUrl: 'https://opentdb.com/api.php?amount=10'
                      '&category=${widget.category}&difficulty=medium'
                      '&type=multiple',
                  timePerQuestion: 20,
                ),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.purple),
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
          ),
        ),
      ],
    );
  }
}
