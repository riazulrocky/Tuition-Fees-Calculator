import 'package:flutter/material.dart';
import 'package:tuition_calculator/tuition_calculator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUB Tuition Fees Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade50,
      ),
      home: TuitionCalculator(),
      debugShowCheckedModeBanner: false,
    );
  }
}
