import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const RoadSurveyApp());
}

class RoadSurveyApp extends StatelessWidget {
  const RoadSurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoadSurvey',
      home: SplashScreen(),
    );
  }
}