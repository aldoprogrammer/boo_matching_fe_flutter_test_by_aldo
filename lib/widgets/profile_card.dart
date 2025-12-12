import 'package:flutter/material.dart';
import '../models/profile.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final Profile profile;

  static Color _personalityColor(String type) {
    switch (type.toUpperCase()) {
      case 'INFP':
      case 'INFJ':
        return const Color(0xFFFFE08A); // warm yellow
      case 'ENFJ':
      case 'ENFP':
        return const Color(0xFFB2F2E6); // soft teal
      case 'ESFJ':
      case 'ESFP':
        return const Color(0xFFFFF1B8); // pale yellow
      case 'INTJ':
      case 'INTP':
        return const Color(0xFFD9C2FF); // lavender
      default:
        return Colors.white.withValues(alpha: 0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: profile.gradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    profile.imageUrl,
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.22),
                    colorBlendMode: BlendMode.darken,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) => Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // <-- ini bikin konten di bawah
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // biar rata kiri
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    profile.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.lightBlueAccent,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 23,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    profile.location,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _InfoChip(
                            label: '${profile.age}',
                            bg: const Color(0xFFF47BA5),
                            fg: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            label: profile.personality,
                            bg: _personalityColor(profile.personality),
                            fg: Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            label: profile.zodiac,
                            bg: Colors.black87,
                            fg: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}
