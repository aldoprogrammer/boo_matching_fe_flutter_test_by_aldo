import 'package:flutter/material.dart';
import '../controllers/matching_controller.dart';
import '../widgets/action_buttons.dart';
import '../widgets/profile_card.dart';

enum ActionType { skip, like, superLike }

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  late final MatchingController controller;
  ActionType? _currentAction;

  @override
  void initState() {
    super.initState();
    controller = MatchingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleAction(ActionType type) {
    setState(() {
      _currentAction = type;
    });
    controller.animateToNext();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _currentAction = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onFilter: () {}),
            const SizedBox(height: 12),
            const _CategoryTabs(),
            const SizedBox(height: 10),
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: controller.pageController,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        controller.updateIndex(index);
                      });
                    },
                    itemCount: controller.profiles.length,
                    itemBuilder: (context, index) {
                      final profile = controller.profiles[index];
                      final isActive = index == controller.currentIndex;
                      final action = isActive ? _currentAction : null;
                      final offset = switch (action) {
                        ActionType.skip => const Offset(-1.2, 0.1),
                        ActionType.like => const Offset(1.2, 0.1),
                        ActionType.superLike => const Offset(0, -1.0),
                        _ => Offset.zero,
                      };
                      final rotation = switch (action) {
                        ActionType.skip => -0.12,
                        ActionType.like => 0.12,
                        ActionType.superLike => -0.02,
                        _ => 0.0,
                      };
                      return AnimatedSlide(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOut,
                        offset: offset,
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeInOut,
                          turns: rotation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            child: ProfileCard(profile: profile),
                          ),
                        ),
                      );
                    },
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
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF27C9C2) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: const Color(0xFF27C9C2).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: textStyle.copyWith(
          color: isActive ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
