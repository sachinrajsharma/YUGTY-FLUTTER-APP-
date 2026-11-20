import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'login.dart';
import 'shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      final s = AppScope.of(context);
      final next = !s.onboarded
          ? const OnboardingScreen()
          : (s.loggedIn ? const MainShell() : const LoginScreen());
      Navigator.of(context).pushReplacement(fadeRoute(next));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 86, wordmark: false)
                  .animate()
                  .scale(begin: const Offset(.6, .6), duration: 700.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 500.ms),
              const SizedBox(height: 22),
              Text('YUGTY',
                      style: GoogleFonts.sora(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: 6))
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: .3, end: 0),
              const SizedBox(height: 6),
              Text('CAMPUS',
                      style: GoogleFonts.sora(fontSize: 13, letterSpacing: 5, color: Tk.accent, fontWeight: FontWeight.w600))
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String step;
  final String title;
  final String body;
  final List<Color> colors;
  const _Slide(this.icon, this.step, this.title, this.body, this.colors);
}

const _slides = <_Slide>[
  _Slide(Icons.school_rounded, 'STEP 1', 'Ready for college',
      'Settle in, build the right skills and plan your college years with confidence.',
      [Color(0xFF2563EB), Color(0xFF38BDF8)]),
  _Slide(Icons.workspace_premium_rounded, 'STEP 2', 'Professionally trained',
      'Resume Studio, interview practice and courses that employers actually look for.',
      [Color(0xFF059669), Color(0xFF34D399)]),
  _Slide(Icons.rocket_launch_rounded, 'STEP 3', 'Job ready',
      'Video resume, job matching and mentors to take you from classroom to workplace.',
      [Color(0xFF7C3AED), Color(0xFFA78BFA)]),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pc.addListener(() => setState(() => _page = _pc.page ?? 0));
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    await AppScope.of(context).finishOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(fadeRoute(const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final last = _page.round() == _slides.length - 1;
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
                child: Row(
                  children: [
                    const BrandMark(size: 34),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: last ? 0 : 1,
                      duration: 200.ms,
                      child: TextButton(
                        onPressed: last ? null : _done,
                        child: const Text('Skip', style: TextStyle(color: Tk.mut, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  itemCount: _slides.length,
                  itemBuilder: (_, i) {
                    final delta = (_page - i);
                    return Opacity(
                      opacity: (1 - delta.abs()).clamp(0, 1),
                      child: Transform.translate(
                        offset: Offset(delta * -60, 0),
                        child: _SlideView(slide: _slides[i]),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final on = (_page - i).abs() < .5;
                  return AnimatedContainer(
                    duration: 250.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: on ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: on ? Tk.brandGradient : null,
                      color: on ? null : Colors.white24,
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: GradientButton(
                  label: last ? 'Get started' : 'Next',
                  icon: last ? Icons.arrow_forward_rounded : null,
                  onPressed: () => last
                      ? _done()
                      : _pc.nextPage(duration: 450.ms, curve: Curves.easeOutCubic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight, colors: slide.colors),
                boxShadow: [BoxShadow(color: slide.colors.last.withValues(alpha: .5), blurRadius: 80, spreadRadius: -10)],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 1.5)),
                  ),
                  Icon(slide.icon, size: 96, color: Colors.white)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: -6, end: 6, duration: 2.seconds, curve: Curves.easeInOut),
                ],
              ),
            ),
          ),
          const SizedBox(height: 44),
          Text(slide.step,
              style: GoogleFonts.sora(color: Tk.accent, fontSize: 12.5, letterSpacing: 3, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(slide.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 34, height: 1.1)),
          const SizedBox(height: 14),
          Text(slide.body, style: const TextStyle(color: Tk.mut, fontSize: 16.5, height: 1.5)),
        ],
      ),
    );
  }
}
