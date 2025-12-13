import 'dart:ui';

import 'package:boo_matching_fe_flutter_test_by_aldo/widgets/icons/boost_icon.dart';
import 'package:boo_matching_fe_flutter_test_by_aldo/widgets/icons/close_x_icon.dart';
import 'package:boo_matching_fe_flutter_test_by_aldo/widgets/icons/dm_icon.dart';
import 'package:boo_matching_fe_flutter_test_by_aldo/widgets/icons/like_heart_icon.dart';
import 'package:boo_matching_fe_flutter_test_by_aldo/widgets/icons/super_like_heart_icon.dart';
import 'package:flutter/material.dart';

class BottomControls extends StatelessWidget {
  const BottomControls({
    super.key,
    required this.onSkip,
    required this.onLike,
    required this.onSuperLike,
    this.activeIndex = 0,
    this.onMenuTap,
  });

  final VoidCallback onSkip;
  final VoidCallback onLike;
  final VoidCallback onSuperLike;
  final int activeIndex;
  final ValueChanged<int>? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ActionButtons(
            onSkip: onSkip,
            onLike: onLike,
            onSuperLike: onSuperLike,
          ),
          const SizedBox(height: 10),
          _BottomMenu(activeIndex: activeIndex, onTap: onMenuTap),
        ],
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.onSkip,
    required this.onLike,
    required this.onSuperLike,
  });

  final VoidCallback onSkip;
  final VoidCallback onLike;
  final VoidCallback onSuperLike;

  @override
  Widget build(BuildContext context) {
    const double bigSize = 66;
    const double medSize = 60;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionCircle(
              size: medSize,
              tooltip: 'Boost',
              onTap: () {},
              child: const BoostIcon(size: 28),
            ),
            _ActionCircle(
              size: bigSize,
              tooltip: 'Pass',
              onTap: onSkip,
              child: const CloseXIcon(size: 32),
            ),
            _ActionCircle(
              size: bigSize,
              tooltip: 'Love',
              onTap: onLike,
              child: const LikeHeartIcon(size: 32),
            ),
            _ActionCircle(
              size: medSize,
              tooltip: 'Super Love',
              onTap: onSuperLike,
              child: const SuperLikeHeartIcon(size: 30),
            ),
            _ActionCircle(
              size: medSize,
              tooltip: 'DM',
              onTap: () {},
              child: Transform.rotate(
                angle: -20 * 3.1415926535 / 180,
                child: const DmIcon(size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.size,
    required this.child,
    required this.tooltip,
    required this.onTap,
  });

  final double size;
  final Widget child;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Tooltip(message: tooltip, child: child),
        ),
      ),
    );
  }
}

class _BottomMenu extends StatelessWidget {
  const _BottomMenu({required this.activeIndex, required this.onTap});

  final int activeIndex;
  final ValueChanged<int>? onTap;

  static const _activeColor = Color(0xFF4EDCD8);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: _BottomMenuItem(
                      label: 'Match',
                      isActive: activeIndex == 0,
                      activeColor: _activeColor,
                      icon: const SuperLikeHeartIcon(size: 20),
                      onTap: () => onTap?.call(0),
                    ),
                  ),
                  Expanded(
                    child: _BottomMenuItem(
                      label: 'Search',
                      isActive: activeIndex == 1,
                      activeColor: _activeColor,
                      icon: const Icon(Icons.search, size: 20),
                      onTap: () => onTap?.call(1),
                    ),
                  ),
                  Expanded(
                    child: _BottomMenuItem(
                      label: 'Create',
                      isActive: activeIndex == 2,
                      activeColor: _activeColor,
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onTap: () => onTap?.call(2),
                    ),
                  ),
                  Expanded(
                    child: _BottomMenuItem(
                      label: 'Universes',
                      isActive: activeIndex == 3,
                      activeColor: _activeColor,
                      icon: const Icon(Icons.public, size: 20),
                      onTap: () => onTap?.call(3),
                    ),
                  ),
                  Expanded(
                    child: _BottomMenuItem(
                      label: 'Messages',
                      isActive: activeIndex == 4,
                      activeColor: _activeColor,
                      icon: const Icon(Icons.mail_outline, size: 20),
                      onTap: () => onTap?.call(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomMenuItem extends StatelessWidget {
  const _BottomMenuItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : Colors.black54;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme(
                data: IconThemeData(color: color, size: 24),
                child: icon,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
