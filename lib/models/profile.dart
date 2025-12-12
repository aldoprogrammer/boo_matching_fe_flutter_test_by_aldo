import 'package:flutter/material.dart';

class Profile {
  const Profile({
    required this.name,
    required this.location,
    required this.distance,
    required this.info,
    required this.age,
    required this.personality,
    required this.zodiac,
    required this.imageUrl,
    required this.compatibility,
    required this.gradient,
  });

  final String name;
  final String location;
  final String distance;
  final String info;
  final int age;
  final String personality;
  final String zodiac;
  final String imageUrl;
  final String compatibility;
  final Gradient gradient;
}
