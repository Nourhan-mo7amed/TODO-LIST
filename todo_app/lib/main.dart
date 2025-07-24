import 'dart:core';
import 'package:flutter/material.dart';

import 'screens/HomeScreen.dart';

void main() async {
  runApp(TaskerApp());
}

class TaskerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
