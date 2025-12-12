import 'package:flutter/material.dart';
import '../models/profile_detail.dart';
import '../models/profile.dart';

class MatchingController {
  final List<Profile> profiles = [
    const Profile(
      id: 1,
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
      id: 2,
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
      id: 3,
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
  ];

  // Dummy per-profile details keyed by id.
  final Map<int, ProfileDetail> profileDetails = {
    1: ProfileDetail(
      lookingFor: ['Dating', 'Friends', 'Short term'],
      languages: ['English', 'Bahasa'],
      interests: ['design', 'sunset walks', 'coffee', 'photography'],
      typeName: 'Protector',
      typeStatus: 'Has Potential',
      typeSummary:
          'Supportive, reliable, and patient. Values calm nights and sincere gestures.',
      cognitiveScores: {
        'Introverted': '--',
        'Sensing': '--',
        'Feeling': '--',
        'Judging': '--',
      },
    ),
    2: ProfileDetail(
      lookingFor: ['Dating', 'Coffee chat'],
      languages: ['English', 'Indonesian'],
      interests: ['travel', 'makeup', 'k-pop', 'ramen'],
      typeName: 'Caregiver',
      typeStatus: 'Most Popular',
      typeSummary:
          'Warm and organised. Loves shared adventures and daily care over big surprises.',
      cognitiveScores: {
        'Extroverted': '54%',
        'Sensing': '51%',
        'Feeling': '63%',
        'Judging': '55%',
      },
    ),
    3: ProfileDetail(
      lookingFor: ['Friends', 'Collab'],
      languages: ['English'],
      interests: ['hiking', 'acoustic', 'documentaries'],
      typeName: 'Mastermind',
      typeStatus: 'Challenging',
      typeSummary:
          'Reserved but loyal. Prefers slow, intentional connections and deep talks.',
      cognitiveScores: {
        'Introverted': '61%',
        'Intuitive': '58%',
        'Thinking': '62%',
        'Judging': '57%',
      },
    ),
  };

  int currentIndex = 0;

  Profile get currentProfile {
    if (profiles.isEmpty) {
      throw StateError('No profiles available.');
    }
    return profiles[currentIndex % profiles.length];
  }

  Profile get nextProfile {
    if (profiles.isEmpty) {
      throw StateError('No profiles available.');
    }
    return profiles[(currentIndex + 1) % profiles.length];
  }

  void advance() {
    if (profiles.isEmpty) return;
    currentIndex = (currentIndex + 1) % profiles.length;
  }

  ProfileDetail? detailFor(Profile profile) => profileDetails[profile.id];

  void dispose() {}
}
