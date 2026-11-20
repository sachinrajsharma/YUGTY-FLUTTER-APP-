import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/plans.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';

class Tool {
  final String featureKey;
  final String name;
  final String blurb;
  final IconData icon;
  final List<Color> colors;
  const Tool(this.featureKey, this.name, this.blurb, this.icon, this.colors);
  Feature get feature => features.firstWhere((f) => f.key == featureKey);
}

const tools = <Tool>[
  Tool('resume', 'Resume Studio', 'Pick a template and build a polished resume.', Icons.description_rounded,
      [Color(0xFF2563EB), Color(0xFF38BDF8)]),
  Tool('ats', 'ATS Check', 'Score and optimise your resume for screening software.', Icons.fact_check_rounded,
      [Color(0xFF059669), Color(0xFF34D399)]),
  Tool('cover', 'Cover Letter', 'Write tailored cover letters in minutes.', Icons.mail_rounded,
      [Color(0xFF7C3AED), Color(0xFFA78BFA)]),
  Tool('interview', 'Interview Practice', 'Practise in audio or video and get AI feedback.', Icons.mic_rounded,
      [Color(0xFFEA580C), Color(0xFFFBBF24)]),
  Tool('courses', 'Courses', 'Build skills with courses and earn certificates.', Icons.menu_book_rounded,
      [Color(0xFF0891B2), Color(0xFF67E8F9)]),
  Tool('video', 'Video Resume', 'Introduce yourself to recruiters on camera.', Icons.videocam_rounded,
      [Color(0xFFDB2777), Color(0xFFF9A8D4)]),
  Tool('social', 'Social Branding', 'Posts and profile makeovers for LinkedIn and more.', Icons.share_rounded,
      [Color(0xFF4F46E5), Color(0xFF818CF8)]),
  Tool('jobs', 'Job Finder', 'Matched jobs and internships, with alerts.', Icons.work_rounded,
      [Color(0xFF16A34A), Color(0xFF86EFAC)]),
  Tool('guidance', 'Expert Guidance', 'Group sessions and a career roadmap.', Icons.groups_rounded,
      [Color(0xFF9333EA), Color(0xFFD8B4FE)]),
  Tool('mentor', 'Mentor Session', 'One-to-one time with a mentor.', Icons.support_agent_rounded,
      [Color(0xFFE11D48), Color(0xFFFDA4AF)]),
];

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.paddingOf(context).bottom + 24),
      children: [
        Text('Your toolkit', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 30)),
        const SizedBox(height: 6),
        Text('Everything on the ${plans[s.planIndex].name} plan, and what unlocks next.',
            style: const TextStyle(color: Tk.mut, fontSize: 14.5)),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tools.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: .66,
          ),
          itemBuilder: (_, i) {
            final t = tools[i];
            final included = t.feature.values[s.planIndex].isNotEmpty;
            return GlassCard(
              onTap: () => showToolSheet(context, t),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(colors: t.colors),
                        ),
                        child: Icon(t.icon, color: Colors.white),
                      ),
                      const Spacer(),
                      Icon(included ? Icons.check_circle_rounded : Icons.lock_rounded,
                          size: 20, color: included ? Tk.good : Tk.mut),
                    ],
                  ),
                  const Spacer(),
                  Text(t.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    included ? t.feature.values[s.planIndex] : 'Unlock on a higher plan',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: included ? Tk.mut : Tk.accent, fontSize: 11.5, height: 1.3),
                  ),
                ],
              ),
            ).animate(delay: (i * 45).ms).fadeIn().scale(begin: const Offset(.95, .95), end: const Offset(1, 1));
          },
        ),
      ],
    );
  }
}

/// Bottom sheet: what this tool gives on every plan.
void showToolSheet(BuildContext context, Tool t) {
  final outer = context;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Tk.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    builder: (ctx) {
      final s = AppScope.of(ctx);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), gradient: LinearGradient(colors: t.colors)),
                  child: Icon(t.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(t.name, style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontSize: 22))),
              ]),
              const SizedBox(height: 12),
              Text(t.blurb, style: const TextStyle(color: Tk.mut, fontSize: 14.5, height: 1.45)),
              if (t.feature.hint.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(t.feature.hint, style: const TextStyle(color: Tk.mut, fontSize: 12.5)),
              ],
              const SizedBox(height: 18),
              ...List.generate(plans.length, (i) {
                final v = t.feature.values[i];
                final mine = i == s.planIndex;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: mine ? Tk.accent.withValues(alpha: .1) : Colors.white.withValues(alpha: .04),
                    border: Border.all(color: mine ? Tk.accent.withValues(alpha: .6) : Tk.line),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(v.isEmpty ? Icons.close_rounded : Icons.check_rounded,
                          size: 18, color: v.isEmpty ? Tk.bad : Tk.good),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(plans[i].name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                              if (mine) ...[const SizedBox(width: 8), const PlanBadge('Your plan')],
                            ]),
                            const SizedBox(height: 3),
                            Text(v.isEmpty ? 'Not included' : v,
                                style: TextStyle(color: v.isEmpty ? Tk.mut : Tk.ink, fontSize: 13.5, height: 1.35)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              GradientButton(
                label: 'Compare plans',
                icon: Icons.workspace_premium_rounded,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  switchTab(outer, 2);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
