import 'package:flutter/material.dart';
import '../models/profile.dart';

class MatchingController {
  final List<Profile> profiles = [
    const Profile(
      name: 'Nanaa',
      location: 'Bengkulu, Indonesia',
      age: 22,
      personality: 'INFP',
      zodiac: 'Libra',
      imageUrl:
          'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=900',
      gradient: LinearGradient(
        colors: [Color(0xFFFD859E), Color(0xFFFFD3A5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    const Profile(
      name: 'Sischa',
      location: 'Curup, Bengkulu',
      age: 18,
      personality: 'ESFJ',
      zodiac: 'Sagittarius',
      imageUrl:
          'https://images.pexels.com/photos/247322/pexels-photo-247322.jpeg?auto=compress&cs=tinysrgb&w=900',
      gradient: LinearGradient(
        colors: [Color(0xFF77E8E2), Color(0xFFC7F0FF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    const Profile(
      name: 'Ani',
      location: 'Bengkulu, Indonesia',
      age: 21,
      personality: 'INFP',
      zodiac: 'Capricorn',
      imageUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?ixlib=rb-4.0.3&auto=format&fit=crop&w=900&q=80',
      gradient: LinearGradient(
        colors: [Color(0xFFF5F5F5), Color(0xFFE8EEF3)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    const Profile(
      name: 'Luna',
      location: 'Jakarta, Indonesia',
      age: 24,
      personality: 'ENFJ',
      zodiac: 'Gemini',
      imageUrl:
          'https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=900',
      gradient: LinearGradient(
        colors: [Color(0xFFC9D6FF), Color(0xFFE2E2E2)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ];

  late final PageController pageController = PageController(
    viewportFraction: 1.0,
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
