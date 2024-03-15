import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PlanetSpinnerAnimation extends StatelessWidget {
  const PlanetSpinnerAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/planet-loader.json',
      frameRate: FrameRate(60),
      repeat: true,
      reverse: true,
      alignment: Alignment.center,
      height: 150,
    );
  }
}
