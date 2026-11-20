import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/plans.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'login.dart';
import 'shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final plan = plans[s.planIndex];
    final verified = s.planIndex >= 1;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.paddingOf(context).bottom + 24),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 30)),
        const SizedBox(height: 18),
        _PassportCard(name: s.name.isEmpty ? 'Student' : s.name, plan: plan.name, verified: verified, phone: s.phone)
            .animate()
            .fadeIn()
            .slideY(begin: .06, end: 0),
        const SizedBox(height: 22),
        _Tile(
          icon: Icons.edit_rounded,
          title: 'Edit name',
          subtitle: s.name.isEmpty ? 'Add your name' : s.name,
          onTap: () => _editName(context, s),
        ),
        _Tile(
          icon: Icons.workspace_premium_rounded,
          title: 'My plan',
          subtitle: '${plan.name}  ·  Validity ${plan.validity}',
          onTap: () => switchTab(context, 2),
        ),
        GlassCard(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: s.notifications,
            onChanged: s.setNotifications,
            activeThumbColor: Tk.accent,
            title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Job matches and reminders', style: TextStyle(color: Tk.mut, fontSize: 12.5)),
            secondary: const Icon(Icons.notifications_active_rounded, color: Tk.accent),
          ),
        ),
        const SizedBox(height: 10),
        _Tile(
          icon: Icons.help_outline_rounded,
          title: 'Help and support',
          subtitle: 'hello@yugti.com',
          onTap: () => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Write to us at hello@yugti.com'))),
        ),
        _Tile(
          icon: Icons.info_outline_rounded,
          title: 'About YUGTY Campus',
          subtitle: 'Version 0.1.0 (preview)',
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'YUGTY Campus',
            applicationVersion: '0.1.0 (preview)',
            applicationLegalese: 'Colleges readiness and professional training for job-ready students.',
          ),
        ),
        const SizedBox(height: 10),
        GradientButton(
          label: 'Log out',
          secondary: true,
          icon: Icons.logout_rounded,
          onPressed: () async {
            final nav = Navigator.of(context);
            await s.signOut();
            nav.pushAndRemoveUntil(fadeRoute(const LoginScreen()), (_) => false);
          },
        ),
      ],
    );
  }

  void _editName(BuildContext context, AppState s) {
    final c = TextEditingController(text: s.name);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Tk.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(22, 4, 22, MediaQuery.viewInsetsOf(ctx).bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your name', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontSize: 22)),
            const SizedBox(height: 14),
            TextField(
              controller: c,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              cursorColor: Tk.accent,
              decoration: InputDecoration(
                hintText: 'Full name',
                filled: true,
                fillColor: Colors.white.withValues(alpha: .06),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Tk.accent)),
              ),
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Save',
              onPressed: () async {
                final nav = Navigator.of(ctx);
                await s.setName(c.text);
                nav.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          onTap: onTap,
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Tk.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Tk.mut, fontSize: 12.5)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Tk.mut),
            ],
          ),
        ),
      );
}

class _PassportCard extends StatelessWidget {
  const _PassportCard({required this.name, required this.plan, required this.verified, required this.phone});
  final String name;
  final String plan;
  final bool verified;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1B3A8A), Color(0xFF0B1433), Color(0xFF3B2A8A)]),
        border: Border.all(color: Tk.accent.withValues(alpha: .4)),
        boxShadow: [BoxShadow(color: Tk.accent.withValues(alpha: .25), blurRadius: 40, spreadRadius: -12)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(size: 28),
                const SizedBox(height: 22),
                const Text('CAREER PASSPORT',
                    style: TextStyle(color: Tk.mut, fontSize: 10.5, letterSpacing: 2.2, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700)),
                if (phone.isNotEmpty)
                  Text('+91 ${phone.substring(0, math.min(2, phone.length))}••••••${phone.length >= 10 ? phone.substring(8) : ''}',
                      style: const TextStyle(color: Tk.mut, fontSize: 12.5)),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  PlanBadge(plan),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: (verified ? Tk.good : Tk.mut).withValues(alpha: .14),
                      border: Border.all(color: (verified ? Tk.good : Tk.mut).withValues(alpha: .4)),
                    ),
                    child: Text(verified ? 'VERIFIED' : 'BASIC',
                        style: TextStyle(color: verified ? Tk.good : Tk.mut, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: CustomPaint(size: const Size(84, 84), painter: _QrPainter(name.hashCode)),
          ),
        ],
      ),
    );
  }
}

/// Decorative QR-style pattern (not a scannable code).
class _QrPainter extends CustomPainter {
  _QrPainter(this.seed);
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 15;
    final cell = size.width / n;
    final rnd = math.Random(seed);
    final p = Paint()..color = const Color(0xFF0B1433);
    bool finder(int x, int y) => (x < 5 && y < 5) || (x > n - 6 && y < 5) || (x < 5 && y > n - 6);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (finder(x, y)) continue;
        if (rnd.nextDouble() > .52) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromLTWH(x * cell, y * cell, cell * .88, cell * .88), Radius.circular(cell * .2)), p);
        }
      }
    }
    void eye(double ox, double oy) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(ox, oy, cell * 5, cell * 5), Radius.circular(cell)), p);
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(ox + cell, oy + cell, cell * 3, cell * 3), Radius.circular(cell * .6)),
          Paint()..color = Colors.white);
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(ox + cell * 1.7, oy + cell * 1.7, cell * 1.6, cell * 1.6), Radius.circular(cell * .4)), p);
    }

    eye(0, 0);
    eye((n - 5) * cell, 0);
    eye(0, (n - 5) * cell);
  }

  @override
  bool shouldRepaint(_QrPainter o) => o.seed != seed;
}
