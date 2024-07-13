import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lesson_76/restaurant_app/ui/screens/login_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset("assets/icons/restaurant_location.json"),
          ),
          SizedBox(height: 42),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 47),
            child: Text(
              'Find delicious food places quickly and easily',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 126),
          SizedBox(height: 18),
          ZoomTapAnimation(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Container(
              width: 327,
              height: 52,
              decoration: BoxDecoration(
                color: Color(0xff002DE3),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  "Start Searching",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
