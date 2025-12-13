import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../controllers/matching_controller.dart';
import '../models/profile_detail.dart';
import '../models/profile.dart';
import '../widgets/action_buttons.dart';
import '../widgets/icons/power_ups_icon.dart';
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
  static const double _bottomControlsInset = 190;
  static const double _topBarHeight = 56;

  late final MatchingController controller;
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _swipeController;
  late final Animation<double> _swipeCurve;
  Timer? _swipeDelayTimer;

  ActionType? _overlayAction;
  ActionType? _swipeAction;
  bool _isTopBarBlurred = true;

  @override
  void initState() {
    super.initState();
    controller = MatchingController();
    _scrollController.addListener(_handleScroll);
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

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final shouldBlur = _scrollController.offset <= 1;
    if (shouldBlur == _isTopBarBlurred) return;
    setState(() {
      _isTopBarBlurred = shouldBlur;
    });
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
    final bottomInset =
        MediaQuery.of(context).padding.bottom + _bottomControlsInset;
    final topInset = _topBarHeight + 8;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Stack(
                children: [
                  IgnorePointer(
                    child: _SwipeScreen(
                      profile: nextProfile,
                      detail: controller.detailFor(nextProfile),
                      scrollController: null,
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                      overlayAction: null,
                      bottomInset: bottomInset,
                      topInset: topInset,
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
                      bottomInset: bottomInset,
                      topInset: topInset,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: BottomControls(
                        onSkip: () => _handleAction(ActionType.skip),
                        onLike: () => _handleAction(ActionType.like),
                        onSuperLike: () => _handleAction(ActionType.superLike),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: _TopBar(onFilter: () {}, blurred: _isTopBarBlurred),
            ),
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
    required this.bottomInset,
    required this.topInset,
  });

  final Profile profile;
  final ProfileDetail? detail;
  final ScrollController? scrollController;
  final ScrollPhysics scrollPhysics;
  final ActionType? overlayAction;
  final double bottomInset;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F5F7),
      child: Stack(
        children: [
          Column(
            children: [
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
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: topInset,
                        bottom: bottomInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _CategoryTabs(),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.62,
                            child: ProfileCard(profile: profile),
                          ),
                          const SizedBox(height: 24),
                          const _ProfileContentTabs(),
                          const SizedBox(height: 24),
                          _ProfileDetailPanel(profile: profile, detail: detail),
                          const SizedBox(height: 50),
                          const Center(
                            child: Text(
                              'REPORT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black38,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
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
  const _TopBar({required this.onFilter, required this.blurred});

  final VoidCallback onFilter;
  final bool blurred;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = blurred
        ? Colors.white.withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.30);
    final bottomBorder = BorderSide(
      color: blurred
          ? Colors.black.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.07),
      width: 1,
    );

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: blurred ? 16 : 6),
      builder: (context, sigma, child) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: child,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(bottom: bottomBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 56,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
                  IconButton(
                    icon: const PowerUpsIcon(size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const Center(
              child: Text(
                'BOO',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.g_translate_outlined),
                    onPressed: onFilter,
                  ),
                  IconButton(icon: const Icon(Icons.tune), onPressed: onFilter),
                ],
              ),
            ),
          ],
        ),
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
        _Pill(label: 'DISCOVERY', isActive: false, textStyle: pillTextStyle),
      ],
    );
  }
}

class _ProfileContentTabs extends StatelessWidget {
  const _ProfileContentTabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _TabText(label: 'PROFILE', isActive: true),
        _TabText(label: 'POSTS'),
        _TabText(label: 'COMMENTS'),
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
          bio: null,
          whoCares: [],
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
          _LookingForBlock(detail: d),
          const SizedBox(height: 12),
          if (d.interests.isNotEmpty || d.languages.isNotEmpty) ...[
            _SectionCard(
              extraBelow: [
                if (d.interests.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const _SubLabel('Interests'),
                  const SizedBox(height: 6),
                  _ChipWrap(chips: _asHashtags(d.interests)),
                ],
                if (d.languages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const _SubLabel('Languages'),
                  const SizedBox(height: 6),
                  _ChipWrap(
                    chips: d.languages,
                    textColor: const Color(0xFF4EDCD8),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
          ],
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
          _TypePanelV2(detail: d, personalityCode: profile.personality),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

List<String> _asHashtags(List<String> values) {
  return values
      .where((v) => v.trim().isNotEmpty)
      .map((v) => v.trim().startsWith('#') ? v.trim() : '#${v.trim()}')
      .toList(growable: false);
}

String _personalityAssetPath(String personalityCode) {
  switch (personalityCode.trim().toUpperCase()) {
    case 'ESFJ':
      return 'assets/global/personality/esfj.jpg';
    case 'INFP':
      return 'assets/global/personality/infp.jpg';
    default:
      return 'assets/global/personality/infp.jpg';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({this.title, this.desc, this.extraBelow});

  final String? title;
  final String? desc;
  final List<Widget>? extraBelow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
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
          if (title != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            if (desc != null) const SizedBox(height: 8),
          ],
          if (desc != null)
            Text(
              desc!,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          if (extraBelow != null) ...extraBelow!,
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.chips, this.textColor, this.iconFor});

  final List<String> chips;
  final Color? textColor;
  final IconData Function(String value)? iconFor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips
          .map(
            (c) => _Chip(
              text: c,
              textColor: textColor,
              leading: iconFor == null
                  ? null
                  : Icon(iconFor!(c), size: 16, color: const Color(0xFF4EDCD8)),
            ),
          )
          .toList(),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, this.leading, this.textColor});

  final String text;
  final Widget? leading;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10, // px-2.5
        vertical: leading == null ? 6 : 4, // py-1.5 / py-1 (with icon)
      ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _LookingForBlock extends StatelessWidget {
  const _LookingForBlock({required this.detail});

  final ProfileDetail detail;

  IconData _iconForWhoCares(String v) {
    final s = v.toLowerCase();
    if (s.contains('college')) return Icons.school_rounded;
    if (s.contains('never')) return Icons.block_rounded;
    if (s.contains('someday')) return Icons.favorite_border_rounded;
    if (s.contains('sometimes')) return Icons.auto_awesome_rounded;
    return Icons.tune_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final bio = (detail.bio ?? '').trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'LOOKING FOR',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: Colors.black87,
                ),
              ),
              ...detail.lookingFor.map((c) => _Chip(text: c)),
            ],
          ),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              bio,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ],
          if (detail.whoCares.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Who cares?',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _ChipWrap(chips: detail.whoCares, iconFor: _iconForWhoCares),
          ],
        ],
      ),
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
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _TypePanelV2 extends StatelessWidget {
  const _TypePanelV2({required this.detail, required this.personalityCode});

  final ProfileDetail detail;
  final String personalityCode;

  _StatusPalette _statusPalette(String status) {
    final s = status.trim().toLowerCase();
    if (s.contains('challeng')) {
      return const _StatusPalette(
        start: Color(0xFFFF5B5B),
        end: Color(0xFFFFA3A3),
        valueColor: Color(0xFFFF5B5B),
      );
    }
    if (s.contains('popular')) {
      return const _StatusPalette(
        start: Color(0xFFFE8080),
        end: Color(0xFFFEA9A9),
        valueColor: Color(0xFFFE8080),
      );
    }
    return const _StatusPalette(
      start: Color(0xFFFFD54F),
      end: Color(0xFFFFE082),
      valueColor: Color(0xFFFF6F00),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusText = detail.typeStatus.isEmpty
        ? 'Has Potential'
        : detail.typeStatus;
    final palette = _statusPalette(statusText);
    final scores = detail.cognitiveScores.isEmpty
        ? const <String, String>{
            'Introverted': '58%',
            'Sensing': '61%',
            'Feeling': '64%',
            'Judging': '61%',
          }
        : detail.cognitiveScores;
    final scoreEntries = scores.entries.take(4).toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final leftW = (constraints.maxWidth * 0.25)
                  .clamp(88.0, 120.0)
                  .toDouble();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: leftW,
                    child: Column(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            _personalityAssetPath(personalityCode),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [palette.start, palette.end],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            personalityCode,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.typeName.isEmpty
                              ? 'Mastermind'
                              : detail.typeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [palette.start, palette.end],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            statusText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(4, (i) {
                            final entry = i < scoreEntries.length
                                ? scoreEntries[i]
                                : const MapEntry('', '--');
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: i == 3 ? 0 : 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: palette.valueColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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

class _StatusPalette {
  const _StatusPalette({
    required this.start,
    required this.end,
    required this.valueColor,
  });

  final Color start;
  final Color end;
  final Color valueColor;
}

// ignore: unused_element
class _TypePanel extends StatelessWidget {
  const _TypePanel({required this.detail, required this.personalityCode});

  final ProfileDetail detail;
  final String personalityCode;

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
        fontWeight: FontWeight.w900,
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
