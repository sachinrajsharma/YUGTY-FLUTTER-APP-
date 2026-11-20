import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'home.dart';
import 'plans.dart';
import 'profile.dart';
import 'tools.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _i = widget.initialTab;

  void go(int i) => setState(() => _i = i);

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.grid_view_rounded, Icons.grid_view_outlined, 'Toolkit'),
    (Icons.workspace_premium_rounded, Icons.workspace_premium_outlined, 'Plans'),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onOpenTab: go),
      const ToolsScreen(),
      const PlansScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      extendBody: true,
      body: AuroraBackground(
        child: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: 280.ms,
            switchInCurve: Curves.easeOut,
            child: KeyedSubtree(key: ValueKey(_i), child: pages[_i]),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          height: 68,
          decoration: BoxDecoration(
            color: Tk.surface.withValues(alpha: .94),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Tk.line),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .5), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final on = i == _i;
              final it = _items[i];
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    go(i);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: 250.ms,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          gradient: on ? Tk.brandGradient : null,
                        ),
                        child: Icon(on ? it.$1 : it.$2, size: 22, color: on ? const Color(0xFF04122A) : Tk.mut),
                      ),
                      const SizedBox(height: 3),
                      Text(it.$3,
                          style: TextStyle(
                              fontSize: 11, fontWeight: on ? FontWeight.w700 : FontWeight.w500, color: on ? Tk.ink : Tk.mut)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Finds the shell so inner screens can switch tabs.
void switchTab(BuildContext context, int i) {
  context.findAncestorStateOfType<_MainShellState>()?.go(i);
}

class GreetingAvatar extends StatelessWidget {
  const GreetingAvatar(this.name, {super.key, this.size = 46});
  final String name;
  final double size;
  @override
  Widget build(BuildContext context) {
    final t = name.trim();
    final letter = t.isEmpty ? 'Y' : t[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Tk.accent, Color(0xFF7C5CFF)]),
      ),
      child: Text(letter, style: TextStyle(fontSize: size * .42, fontWeight: FontWeight.w800, color: Colors.white)),
    );
  }
}

class PlanBadge extends StatelessWidget {
  const PlanBadge(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: Tk.accent.withValues(alpha: .14),
          border: Border.all(color: Tk.accent.withValues(alpha: .4)),
        ),
        child: Text(label.toUpperCase(),
            style: const TextStyle(color: Tk.accent, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      );
}

