import 'package:flutter/material.dart';

class PassOverlay extends StatelessWidget {
  const PassOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: visible ? const Duration(milliseconds: 220) : Duration.zero,
        curve: Curves.easeInOut,
        child: Stack(
          children: [
            // Gradient tint background.
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFE8080).withValues(alpha: 0.45),
                    const Color(0xFFFEA9A9).withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
            // Top-left ghost / close GIF.
            Positioned(
              top: 39,
              left: 5,
              child: Transform.rotate(
                angle: -0.25, // miring ke kiri (sekitar -14 derajat)
                child: Image.asset(
                  'assets/global/icons/close.gif',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
