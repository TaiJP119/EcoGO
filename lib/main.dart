import 'package:flutter/material.dart';

import 'waste sort by ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 56, 228, 128)),
        useMaterial3: false,
      ),
      home: const WasteSortScreen(),
    );
  }
}
