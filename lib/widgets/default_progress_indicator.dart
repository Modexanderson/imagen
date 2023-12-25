import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DefaultProgressIndicator extends StatelessWidget {
  const DefaultProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/default-loader.json',
      frameRate: FrameRate(20),
      alignment: Alignment.center,
      height: 100,
      repeat: true,
      animate: true,
    );
  }
}
