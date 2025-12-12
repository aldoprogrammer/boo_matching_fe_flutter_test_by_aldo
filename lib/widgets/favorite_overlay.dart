import 'package:flutter/material.dart';

class FavoriteOverlay extends StatelessWidget {
  const FavoriteOverlay({super.key, required this.visible});

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
            // Cyan-ish gradient tint for like action.
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4EDCD4).withValues(alpha: 0.4),
                    const Color(0xFF7EF5EB).withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
            // Top-left favorite GIF.
            Positioned(
              top: 8,
              right: 8,
              child: Transform.rotate(
                // Keep the net tilt similar to PassOverlay even when the whole
                // screen rotates during swipe.
                angle: -0.35,
                child: Image.asset(
                  'assets/global/icons/favorite.gif',
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
