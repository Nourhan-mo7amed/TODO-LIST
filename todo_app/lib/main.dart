import 'package:flutter/material.dart';
import 'package:todo_app/data/Sqldb.dart'; // ← مهم
import 'package:todo_app/screens/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = Sqldb();
  //await db.deleteDatabaseFile(); // 🧨 امسحيها بعد أول تشغيل

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      // theme: ThemeData.dark(),
      home: SplashScreen(),
    );
  }
}
