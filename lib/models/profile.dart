import 'package:flutter/material.dart';

class Profile {
  const Profile({
    required this.name,
    required this.location,
    required this.distance,
    required this.info,
    required this.imageUrl,
    required this.tags,
    required this.compatibility,
    required this.gradient,
  });

  final String name;
  final String location;
  final String distance;
  final String info;
  final String imageUrl;
  final List<String> tags;
  final String compatibility;
  final Gradient gradient;
}
