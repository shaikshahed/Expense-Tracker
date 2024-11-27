import 'package:expensetracker/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isFinished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/expense_tracker.jpg',
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
            child: SwipeableButtonView(
              onFinish: () async {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: DetailsScreen(),
                  ),
                );
                setState(() {
                  isFinished = true;
                });
              },
              onWaitingProcess: () {
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    isFinished = true;
                  });
                });
              },
              activeColor: Colors.orange,
              buttonWidget: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey,
              ),
              buttonText: "Get Started",
              isFinished: isFinished,
            ),
          ),
        ],
      ),
    );
  }
}
