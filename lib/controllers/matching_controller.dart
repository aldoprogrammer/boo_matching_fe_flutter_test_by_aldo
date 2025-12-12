import 'package:flutter/material.dart';
import '../models/profile.dart';

class MatchingController {
  final List<Profile> profiles = [
    const Profile(
      name: 'Nanaa',
      location: 'Bengkulu, Indonesia',
      distance: '2 km away',
      info: 'INFP - Libra',
      compatibility: 'Level 92% match vibes',
      imageUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900',
      tags: ['INFP', 'Libra', 'Beach vibe'],
      gradient: LinearGradient(
        colors: [Color(0xFFFD859E), Color(0xFFFFD3A5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    const Profile(
      name: 'Sischa',
      location: 'Curup, Bengkulu',
      distance: '4 km away',
      info: 'ESFJ - Sagittarius',
      compatibility: 'Level 88% match vibes',
      imageUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900&sat=-100',
      tags: ['ESFJ', 'Sagittarius', 'Coffee lover'],
      gradient: LinearGradient(
        colors: [Color(0xFF77E8E2), Color(0xFFC7F0FF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    const Profile(
      name: 'Ani',
      location: 'Bengkulu, Indonesia',
      distance: '5 km away',
      info: 'INFP - Capricorn',
      compatibility: 'Level 84% match vibes',
      imageUrl:
          'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?w=900',
      tags: ['INFP', 'Capricorn', 'Music'],
      gradient: LinearGradient(
        colors: [Color(0xFFF5F5F5), Color(0xFFE8EEF3)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    const Profile(
      name: 'Luna',
      location: 'Jakarta, Indonesia',
      distance: '7 km away',
      info: 'ENFJ - Gemini',
      compatibility: 'Level 90% match vibes',
      imageUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900&sat=-50',
      tags: ['ENFJ', 'Gemini', 'Art'],
      gradient: LinearGradient(
        colors: [Color(0xFFC9D6FF), Color(0xFFE2E2E2)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ];

  late final PageController pageController = PageController(
    viewportFraction: 0.92,
  );

  int currentIndex = 0;

  void updateIndex(int index) {
    currentIndex = index;
  }

  void animateToNext() {
    final nextIndex = currentIndex + 1 < profiles.length ? currentIndex + 1 : 0;
    pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void dispose() {
    pageController.dispose();
  }
}
