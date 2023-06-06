import 'package:flutter/material.dart';
import './widgets/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Greenage Admin Side",
      theme: ThemeData(
        primaryColor: Colors.lightGreen,
        primarySwatch: Colors.green,
        textTheme:
            TextTheme(titleLarge: TextStyle(color: Colors.green.shade700)),
      ),
      home: const Home(),
    );
  }
}
