import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DefaultErrorIndicator extends StatelessWidget {
  const DefaultErrorIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/error-indicator.json',
      frameRate: FrameRate(20),
      alignment: Alignment.center,
      height: 100,
      width: 100,
      repeat: true,
      animate: true,
    );
  }
}