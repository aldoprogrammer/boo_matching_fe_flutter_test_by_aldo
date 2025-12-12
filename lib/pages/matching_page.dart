import 'dart:async';

import 'package:flutter/material.dart';
import '../controllers/matching_controller.dart';
import '../models/profile_detail.dart';
import '../models/profile.dart';
import '../widgets/action_buttons.dart';
import '../widgets/profile_card.dart';
import '../widgets/pass_overlay.dart';
import '../widgets/favorite_overlay.dart';

enum ActionType { skip, like, superLike }

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage>
    with SingleTickerProviderStateMixin {
  static const Duration _overlayDelay = Duration(seconds: 2);
  static const Duration _swipeDuration = Duration(milliseconds: 380);

  late final MatchingController controller;
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _swipeController;
  late final Animation<double> _swipeCurve;
  Timer? _swipeDelayTimer;

  ActionType? _overlayAction;
  ActionType? _swipeAction;

  @override
  void initState() {
    super.initState();
    controller = MatchingController();
    _swipeController = AnimationController(
      vsync: this,
      duration: _swipeDuration,
    );
    _swipeCurve = CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _swipeDelayTimer?.cancel();
    _swipeController.dispose();
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _handleAction(ActionType type) {
    // Prevent overlapping actions to keep timing perfectly in sync.
    if (_overlayAction != null || _swipeController.isAnimating) return;

    setState(() {
      // Tampilkan overlay segera, tapi kartu dan overlay baru bergerak
      // setelah sedikit delay.
      _overlayAction = type;
      _swipeAction = null;
    });

    _swipeDelayTimer?.cancel();
    _swipeDelayTimer = Timer(_overlayDelay, () {
      if (!mounted) return;
      _runSwipe(type);
    });
  }

  Future<void> _runSwipe(ActionType type) async {
    if (_overlayAction != type) return;

    setState(() {
      _swipeAction = type;
    });

    try {
      await _swipeController.forward(from: 0);
    } on TickerCanceled {
      return;
    }

    if (!mounted) return;

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    setState(() {
      controller.advance();
      _overlayAction = null;
      _swipeAction = null;
    });
    _swipeController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile = controller.currentProfile;
    final nextProfile = controller.nextProfile;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onFilter: () {}),
            Expanded(
              child: Stack(
                children: [
                  IgnorePointer(
                    child: _SwipeScreen(
                      profile: nextProfile,
                      detail: controller.detailFor(nextProfile),
                      scrollController: null,
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                      overlayAction: null,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _swipeCurve,
                    builder: (context, child) {
                      final size = MediaQuery.of(context).size;
                      final progress = _swipeCurve.value;
                      final dx = switch (_swipeAction) {
                        ActionType.skip => -size.width * 1.2 * progress,
                        ActionType.like => size.width * 1.2 * progress,
                        ActionType.superLike => size.width * 1.2 * progress,
                        _ => 0.0,
                      };
                      final angle = switch (_swipeAction) {
                        // Pivot from the bottom to create a "pulled" top edge feel.
                        ActionType.skip => -0.62 * progress,
                        ActionType.like => 0.62 * progress,
                        ActionType.superLike => 0.62 * progress,
                        _ => 0.0,
                      };
                      // Slight drop to avoid feeling perfectly linear.
                      final dy = 6.0 * progress;
                      return Transform.translate(
                        offset: Offset(dx, dy),
                        child: Transform.rotate(
                          alignment: Alignment.bottomCenter,
                          angle: angle,
                          child: child,
                        ),
                      );
                    },
                    child: _SwipeScreen(
                      profile: currentProfile,
                      detail: controller.detailFor(currentProfile),
                      scrollController: _scrollController,
                      scrollPhysics: _overlayAction == null
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      overlayAction: _overlayAction,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ActionButtons(
                    onSkip: () => _handleAction(ActionType.skip),
                    onLike: () => _handleAction(ActionType.like),
                    onSuperLike: () => _handleAction(ActionType.superLike),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SwipeScreen extends StatelessWidget {
  const _SwipeScreen({
    required this.profile,
    required this.detail,
    required this.scrollController,
    required this.scrollPhysics,
    required this.overlayAction,
  });

  final Profile profile;
  final ProfileDetail? detail;
  final ScrollController? scrollController;
  final ScrollPhysics scrollPhysics;
  final ActionType? overlayAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F5F7),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              const _CategoryTabs(),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    primary: false,
                    physics: scrollPhysics,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.62,
                          child: ProfileCard(profile: profile),
                        ),
                        const SizedBox(height: 14),
                        _ProfileDetailPanel(profile: profile, detail: detail),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          PassOverlay(visible: overlayAction == ActionType.skip),
          FavoriteOverlay(
            visible:
                overlayAction == ActionType.like ||
                overlayAction == ActionType.superLike,
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onFilter});

  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          const Text(
            'BOO',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: const [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text('Search', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.amber),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.tune), onPressed: onFilter),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs();

  @override
  Widget build(BuildContext context) {
    final pillTextStyle = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w700,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Pill(label: 'NEW SOULS', isActive: true, textStyle: pillTextStyle),
        const SizedBox(width: 10),
        _Pill(label: 'FOR YOU', isActive: false, textStyle: pillTextStyle),
      ],
    );
  }
}

class _ProfileDetailPanel extends StatelessWidget {
  const _ProfileDetailPanel({required this.profile, required this.detail});

  final Profile profile;
  final ProfileDetail? detail;

  @override
  Widget build(BuildContext context) {
    final d =
        detail ??
        const ProfileDetail(
          lookingFor: [],
          languages: [],
          interests: [],
          typeName: '',
          typeStatus: '',
          typeSummary: '',
          cognitiveScores: {},
        );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TabText(label: 'PROFILE', isActive: true),
              const SizedBox(width: 16),
              _TabText(label: 'POSTS'),
              const SizedBox(width: 16),
              _TabText(label: 'COMMENTS'),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Looking For',
            chips: d.lookingFor,
            extraBelow: [
              const SizedBox(height: 12),
              const _SubLabel('Interests'),
              const SizedBox(height: 6),
              _ChipWrap(chips: d.interests),
              const SizedBox(height: 12),
              const _SubLabel('Languages'),
              const SizedBox(height: 6),
              _ChipWrap(chips: d.languages),
            ],
          ),
          const SizedBox(height: 12),
          const _SectionCard(
            title: "We'll get along if",
            desc: 'Saling sapa dan ngobrol yang sopan.',
          ),
          const SizedBox(height: 12),
          const _SectionCard(
            title: "I'm crazy for",
            desc: 'Game and late-night co-op sessions.',
          ),
          const SizedBox(height: 12),
          const _SectionCard(
            title: 'I get way too excited about',
            desc: 'Kucing, cute memes, and small surprise moments.',
          ),
          const SizedBox(height: 12),
          _TypePanel(detail: d),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    this.chips,
    this.desc,
    this.extraBelow,
  });

  final String title;
  final List<String>? chips;
  final String? desc;
  final List<Widget>? extraBelow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          if (chips != null && chips!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ChipWrap(chips: chips!),
          ],
          if (desc != null) ...[
            const SizedBox(height: 8),
            Text(
              desc!,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
          if (extraBelow != null) ...extraBelow!,
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.chips});

  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips
          .map(
            (c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                c,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _TypePanel extends StatelessWidget {
  const _TypePanel({required this.detail});

  final ProfileDetail detail;

  @override
  Widget build(BuildContext context) {
    final scores = detail.cognitiveScores.isEmpty
        ? {
            'Introverted': '58%',
            'Sensing': '61%',
            'Feeling': '64%',
            'Judging': '61%',
          }
        : detail.cognitiveScores;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TabText(label: '16 TYPE', isActive: true),
              const SizedBox(width: 16),
              _TabText(label: 'COGNITIVE FUNCTIONS'),
              const SizedBox(width: 16),
              _TabText(label: 'ZODIAC'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE8F7F6),
                child: Text('🐼', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.typeName.isEmpty ? 'Protector' : detail.typeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      detail.typeStatus.isEmpty
                          ? 'Has Potential'
                          : detail.typeStatus,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  detail.typeName.isEmpty ? 'ISFJ' : detail.typeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: scores.entries
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          e.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Text(
            detail.typeSummary.isEmpty
                ? 'Protectors are supportive, reliable, and patient. They help the people around them and take responsibilities seriously.'
                : detail.typeSummary,
            style: const TextStyle(
              color: Colors.black87,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const _SubLabel('👍 Strengths'),
          const SizedBox(height: 8),
          const _ChipWrap(
            chips: [
              'idealistic',
              'harmonious',
              'open-minded',
              'flexible',
              'creative',
              'passionate',
            ],
          ),
          const SizedBox(height: 14),
          const _SubLabel('👎 Weaknesses'),
          const SizedBox(height: 8),
          const _ChipWrap(
            chips: [
              'sensitive',
              'too idealistic',
              'too altruistic',
              'impractical',
              'take things personally',
              'conflict averse',
            ],
          ),
          const SizedBox(height: 14),
          const _SubLabel('😍 Attracted By'),
          const SizedBox(height: 8),
          const _ChipWrap(
            chips: [
              'strong personality',
              'authentic',
              'supportive',
              'empathetic',
              'caring',
              'deep',
              'sincere',
            ],
          ),
          const SizedBox(height: 14),
          const _SubLabel('😡 Pet Peeves'),
          const SizedBox(height: 8),
          const _ChipWrap(
            chips: [
              'manipulative',
              'controlling',
              'cruel',
              'unethical',
              'superficial',
              'disrespectful',
            ],
          ),
          const SizedBox(height: 14),
          const _SubLabel('🎁 Love Languages'),
          const SizedBox(height: 8),
          const Text(
            '1. Quality Time   2. Words of Affirmation   3. Physical Touch',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          const _SubLabel('🧠 Love Philosophy'),
          const SizedBox(height: 8),
          const Text(
            'Peacemakers are sensitive and idealistic. They want a partner who respects their values, '
            'supports their creative side, and is honest and kind. They dislike conflict and harsh criticism, '
            'and need space to recharge and dream.',
            style: TextStyle(
              color: Colors.black87,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          const _SubLabel('🌹 Ideal Date'),
          const SizedBox(height: 8),
          const Text(
            'A quiet movie night with deep conversation after, or a peaceful walk in nature, '
            'taking photos and sharing music they love.',
            style: TextStyle(
              color: Colors.black87,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabText extends StatelessWidget {
  const _TabText({required this.label, this.isActive = false});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: isActive ? const Color(0xFF27C9C2) : Colors.grey,
      ),
    );
  }
}

// _BulletBlock is no longer used; removed to keep file clean.

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.isActive,
    required this.textStyle,
  });

  final String label;
  final bool isActive;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: isActive
          ? BoxDecoration(
              color: const Color(0xFF4EDCD8),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4EDCD8).withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            )
          : null, // inactive = no decoration at all
      child: Text(label, style: textStyle.copyWith(color: Colors.black)),
    );
  }
}
