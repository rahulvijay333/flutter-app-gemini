import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gemni_app/key.dart';
import 'package:gemni_app/screen_home.dart';

void main() {
  Gemini.init(apiKey: apiKey);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ScreenHome());
  }
}
