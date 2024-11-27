// lib/main.dart

import 'package:flutter/material.dart';
import 'selection_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trivia Quiz',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trivia Quiz'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to Trivia Quiz',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              _buildQuizButton(context, 'General Knowledge Quiz', '9', Icons.lightbulb_outline),
              SizedBox(height: 20),
              _buildQuizButton(context, 'Sports Quiz', '21', Icons.sports_baseball),
              SizedBox(height: 20),
              _buildQuizButton(context, 'Computer Quiz', '18', Icons.computer),
              SizedBox(height: 20),
              _buildQuizButton(context, 'History Quiz', '23', Icons.history),
              SizedBox(height: 20),
              _buildQuizButton(context, 'Geography Quiz', '22', Icons.map),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizButton(BuildContext context, String title, String category, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(title, style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: TextStyle(fontSize: 16),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectionScreen(category: category, title: title),
          ),
        );
      },
    );
  }
}
