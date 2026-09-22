import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      imageAsset: 'assets/images/logo.png',
      title: 'Build streaks that stick',
      body: 'Track daily habits and watch your streak grow. '
          'Small wins, every day.',
    ),
    _OnboardPage(
      icon: Icons.notifications_active_rounded,
      title: 'Never forget',
      body: 'Set gentle reminders for each habit so you never break the chain.',
    ),
    _OnboardPage(
      icon: Icons.insights_rounded,
      title: 'See your progress',
      body: 'Heatmaps and charts show exactly how consistent you\'ve been.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: _pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? AppColors.accent
                        : AppColors.accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (_page == _pages.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(
                    _page == _pages.length - 1 ? 'Get started' : 'Next',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String? imageAsset;
  final IconData? icon;
  final String title;
  final String body;
  const _OnboardPage({
    this.imageAsset,
    this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageAsset != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                imageAsset!,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            )
          else
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: AppColors.accent),
            ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
          ),
        ],
      ),
    );
  }
}
