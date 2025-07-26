import 'dart:async';
import 'package:flutter/material.dart';
import 'HomeScreen.dart'; // تأكد إنه موجود

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد أنيميشن الـ Fade
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward(); // تشغيل الأنيميشن

    // الانتقال بعد 5 ثواني
    Timer(Duration(seconds: 5), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // تنظيف الأنيميشن
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C), // خلفية غامقة
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // صورة الـ GIF
              Image.asset(
                'assets/images/todo3.png', // تأكد إنك ضايفها
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              // اسم التطبيق
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Color.fromARGB(255, 161, 56, 253),
                      Color.fromARGB(255, 79, 0, 237),
                    ], // تدرج بنفسجي جذاب
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Text(
                  'ToDo App',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color:
                        Colors.white, // مطلوب عشان ShaderMask يستخدمه كـ base
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black45,
                        offset: Offset(2, 3),
                      ),
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
}
