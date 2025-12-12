import 'package:flutter/material.dart';
import 'pages/matching_page.dart';

void main() {
  runApp(const MatchingApp());
}

class MatchingApp extends StatelessWidget {
  const MatchingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boo Matching',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF27C9C2),
          brightness: Brightness.light,
        ),
      ),
      home: const MatchingPage(),
    );
  }
}
