import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/plans.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});
  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late final PageController _pc;
  double _page = 2; // start on the most popular plan

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: .86, initialPage: 2);
    _pc.addListener(() => setState(() => _page = _pc.page ?? 2));
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Packages for the Seeker', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28)),
              const SizedBox(height: 6),
              const Text('Start free, then step up as your job search gets serious.',
                  style: TextStyle(color: Tk.mut, fontSize: 14.5)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: PageView.builder(
            controller: _pc,
            itemCount: plans.length,
            itemBuilder: (_, i) {
              final d = (_page - i).abs().clamp(0, 1).toDouble();
              return Transform.scale(
                scale: 1 - .06 * d,
                child: Opacity(
                  opacity: 1 - .35 * d,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 18, 6, 108),
                    child: _PlanCard(index: i, current: i == s.planIndex),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.index, required this.current});
  final int index;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final p = plans[index];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: GlassCard(
            highlight: p.popular,
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
            radius: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(p.name.toUpperCase(),
                      style: GoogleFonts.sora(color: Tk.accent, fontSize: 12.5, letterSpacing: 3, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (current) const PlanBadge('Current'),
                ]),
                const SizedBox(height: 8),
                Text(p.tagline, style: const TextStyle(color: Tk.mut, fontSize: 13.5, height: 1.35)),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (p.isFree)
                      Text('Free', style: GoogleFonts.sora(fontSize: 44, fontWeight: FontWeight.w800, height: 1))
                    else ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text('₹', style: GoogleFonts.sora(fontSize: 22, color: Tk.mut, fontWeight: FontWeight.w600)),
                      ),
                      Text(p.price.substring(1), style: GoogleFonts.sora(fontSize: 44, fontWeight: FontWeight.w800, height: 1)),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: Colors.white.withValues(alpha: .06),
                    border: Border.all(color: Tk.line),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Tk.good),
                    ),
                    const SizedBox(width: 7),
                    Text('Validity: ${p.validity}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ]),
                ),
                const SizedBox(height: 16),
                const Divider(color: Tk.line, height: 1),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 14, bottom: 90),
                    itemCount: features.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      if (i == features.length) {
                        return const Text(conditionsNote, style: TextStyle(color: Tk.mut, fontSize: 11.5, height: 1.4));
                      }
                      return _FeatureRow(feature: features[i], value: features[i].values[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (p.popular)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  gradient: Tk.brandGradient,
                  boxShadow: [BoxShadow(color: Tk.accent.withValues(alpha: .7), blurRadius: 24, spreadRadius: -6)],
                ),
                child: const Text('★  MOST POPULAR',
                    style: TextStyle(color: Color(0xFF04122A), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.4)),
              ),
            ),
          ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: GradientButton(
            label: current ? 'Your current plan' : (p.isFree ? 'Switch to Explorer' : 'Choose ${p.name}'),
            secondary: !p.popular,
            onPressed: current ? null : () => _confirm(context, index),
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature, required this.value});
  final Feature feature;
  final String value;

  @override
  Widget build(BuildContext context) {
    final yes = value.isNotEmpty;
    return Opacity(
      opacity: yes ? 1 : .5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (yes ? Tk.good : Tk.bad).withValues(alpha: .16),
            ),
            child: Icon(yes ? Icons.check_rounded : Icons.close_rounded, size: 14, color: yes ? Tk.good : Tk.bad),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.label.toUpperCase(),
                    style: GoogleFonts.sora(fontSize: 10.5, color: Tk.mut, letterSpacing: .9, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(yes ? value : 'Not included',
                    style: TextStyle(fontSize: 13.5, height: 1.35, color: yes ? Tk.ink : Tk.mut, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _confirm(BuildContext context, int index) {
  final p = plans[index];
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Tk.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.isFree ? 'Switch to Explorer?' : 'Choose ${p.name}',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              p.isFree
                  ? 'You keep lifetime access to the free essentials.'
                  : '${p.price} for ${p.validity}. ${p.tagline}',
              style: const TextStyle(color: Tk.mut, fontSize: 14.5, height: 1.4),
            ),
            if (!p.isFree) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Tk.gold.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Tk.gold.withValues(alpha: .35)),
                ),
                child: const Text(
                  'Preview build: payments are not connected yet, so no money is charged. '
                  'This only switches the plan on this device.',
                  style: TextStyle(color: Tk.gold, fontSize: 12.5, height: 1.4),
                ),
              ),
            ],
            const SizedBox(height: 20),
            GradientButton(
              label: p.isFree ? 'Switch plan' : 'Continue with ${p.name}',
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final s = AppScope.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                await s.setPlan(index);
                messenger.showSnackBar(SnackBar(content: Text('You are now on the ${p.name} plan.')));
              },
            ),
          ],
        ),
      ),
    ),
  );
}
