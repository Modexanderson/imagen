import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PlanetSpinnerAnimation extends StatelessWidget {
  const PlanetSpinnerAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          // Background layer for 3D effect
          Lottie.asset(
            'assets/animations/planet-loader.json',
            frameRate: FrameRate(60),
            repeat: true,
            reverse: true,
            alignment: Alignment.center,
            height: 300,
          ),
          // Foreground layer for shadow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Adjust darkness here
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      
    );
  }
}
