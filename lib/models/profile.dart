import 'package:flutter/material.dart';

class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.location,
    required this.age,
    required this.personality,
    required this.zodiac,
    required this.imageUrl,
    required this.gradient,
  });

  final int id;
  final String name;
  final String location;
  final int age;
  final String personality;
  final String zodiac;
  final String imageUrl;
  final Gradient gradient;
}
