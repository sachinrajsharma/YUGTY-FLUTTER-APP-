import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/plans.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';
import 'tools.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final plan = plans[s.planIndex];
    final pct = (s.progress * 100).round();
    final phase = s.currentPhase;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.paddingOf(context).bottom + 24),
      children: [
        Row(
          children: [
            GreetingAvatar(s.name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting(), style: const TextStyle(color: Tk.mut, fontSize: 13)),
                  Text('Hi, ${s.firstName}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('No new notifications.'))),
              icon: const Icon(Icons.notifications_none_rounded),
              style: IconButton.styleFrom(backgroundColor: Colors.white10),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 22),
        GlassCard(
          highlight: true,
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              ProgressRing(
                value: s.progress,
                size: 112,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$pct%', style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w800)),
                    const Text('ready', style: TextStyle(color: Tk.mut, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phase == 3 ? 'You are job ready!' : phaseNames[phase],
                      style: GoogleFonts.sora(fontSize: 19, fontWeight: FontWeight.w700, height: 1.15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      phase == 3
                          ? 'Every step on your path is done. Keep your profile fresh.'
                          : '${s.done.length} of ${pathTasks.length} steps done. Finish the next one to move forward.',
                      style: const TextStyle(color: Tk.mut, fontSize: 13.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate(delay: 100.ms).fadeIn().slideY(begin: .08, end: 0),
        const SizedBox(height: 18),
        _PathStepper(phase: phase).animate(delay: 180.ms).fadeIn(),
        const SizedBox(height: 28),
        const SectionTitle('Your path'),
        const SizedBox(height: 10),
        ...List.generate(pathTasks.length, (i) {
          final t = pathTasks[i];
          final done = s.done.contains(t.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TaskTile(task: t, done: done, onTap: () {
              HapticFeedback.mediumImpact();
              s.toggleTask(t.id);
            }),
          ).animate(delay: (240 + i * 60).ms).fadeIn().slideX(begin: .05, end: 0);
        }),
        const SizedBox(height: 22),
        SectionTitle('Your toolkit', action: 'See all', onAction: () => onOpenTab(1)),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tools.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _ToolChip(tool: tools[i]),
          ),
        ),
        const SizedBox(height: 26),
        GlassCard(
          onTap: () => onOpenTab(2),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: Tk.brandGradient),
                child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF04122A)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${plan.name} plan', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      s.planIndex == plans.length - 1
                          ? 'You have the complete toolkit.'
                          : 'Unlock more templates, mentors and job matches.',
                      style: const TextStyle(color: Tk.mut, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Tk.mut),
            ],
          ),
        ).animate(delay: 500.ms).fadeIn(),
      ],
    );
  }
}

class _PathStepper extends StatelessWidget {
  const _PathStepper({required this.phase});
  final int phase;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final done = i < phase;
        final on = i == phase;
        final color = done ? Tk.good : (on ? Tk.accent : Tk.mut);
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: 300.ms,
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? Tk.good.withValues(alpha: .18) : (on ? Tk.accent.withValues(alpha: .18) : Colors.white10),
                        border: Border.all(color: color.withValues(alpha: on || done ? 1 : .4), width: 1.6),
                      ),
                      child: done
                          ? const Icon(Icons.check_rounded, size: 18, color: Tk.good)
                          : Text('${i + 1}', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      i == 0 ? 'College\nready' : (i == 1 ? 'Pro\ntrained' : 'Job\nready'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: on || done ? Tk.ink : Tk.mut, fontSize: 11.5, height: 1.2),
                    ),
                  ],
                ),
              ),
              if (i < 2)
                Container(width: 22, height: 2, margin: const EdgeInsets.only(top: 16), color: done ? Tk.good : Colors.white12),
            ],
          ),
        );
      }),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.done, required this.onTap});
  final PathTask task;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 20,
      child: Row(
        children: [
          AnimatedContainer(
            duration: 250.ms,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? Tk.good : Colors.transparent,
              border: Border.all(color: done ? Tk.good : Tk.mut.withValues(alpha: .6), width: 1.6),
            ),
            child: done ? const Icon(Icons.check_rounded, size: 18, color: Color(0xFF04122A)) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: done ? Tk.mut : Tk.ink,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: Tk.mut,
                    )),
                const SizedBox(height: 2),
                Text(task.sub, style: const TextStyle(color: Tk.mut, fontSize: 12.5)),
              ],
            ),
          ),
          Text('${task.phase + 1}', style: TextStyle(color: Tk.mut.withValues(alpha: .5), fontWeight: FontWeight.w800, fontSize: 22)),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({required this.tool});
  final Tool tool;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: GlassCard(
        onTap: () => showToolSheet(context, tool),
        padding: const EdgeInsets.all(14),
        radius: 22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: LinearGradient(colors: tool.colors),
              ),
              child: Icon(tool.icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(tool.name, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

void openPlans(BuildContext context) => switchTab(context, 2);
