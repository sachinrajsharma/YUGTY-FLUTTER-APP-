import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

/// Soft animated glow background used on every screen.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Tk.bg),
        Positioned(
          top: -120,
          right: -80,
          child: _Glow(color: Tk.accent.withValues(alpha: .28), size: 340)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(begin: Offset.zero, end: const Offset(-30, 40), duration: 7.seconds, curve: Curves.easeInOut),
        ),
        Positioned(
          bottom: -140,
          left: -100,
          child: _Glow(color: const Color(0xFF7C5CFF).withValues(alpha: .26), size: 380)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(begin: Offset.zero, end: const Offset(40, -30), duration: 9.seconds, curve: Curves.easeInOut),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
          ),
        ),
      );
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.highlight = false,
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: r,
          border: Border.all(color: highlight ? Tk.accent.withValues(alpha: .55) : Tk.line),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: highlight
                ? [const Color(0xFF16275A), const Color(0xFF0B1433)]
                : [Colors.white.withValues(alpha: .07), Colors.white.withValues(alpha: .02)],
          ),
          boxShadow: highlight
              ? [BoxShadow(color: Tk.accent.withValues(alpha: .25), blurRadius: 40, spreadRadius: -12)]
              : null,
        ),
        child: InkWell(
          borderRadius: r,
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Primary call-to-action with a gradient fill, press-scale and loading state.
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.secondary = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool secondary;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final fg = widget.secondary ? Tk.ink : const Color(0xFF04122A);
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? .97 : 1,
        duration: 120.ms,
        child: AnimatedOpacity(
          opacity: enabled || widget.loading ? 1 : .45,
          duration: 200.ms,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: widget.secondary ? null : Tk.brandGradient,
              color: widget.secondary ? Colors.white.withValues(alpha: .07) : null,
              border: widget.secondary ? Border.all(color: Tk.line) : null,
              boxShadow: widget.secondary
                  ? null
                  : [BoxShadow(color: Tk.accent.withValues(alpha: .45), blurRadius: 28, spreadRadius: -10, offset: const Offset(0, 12))],
            ),
            child: widget.loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.6, color: fg),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[Icon(widget.icon, color: fg, size: 20), const SizedBox(width: 10)],
                      Text(widget.label,
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: fg)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// The YUGTY mark: gradient tile with a Y, plus optional wordmark.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40, this.wordmark = true});
  final double size;
  final bool wordmark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * .3),
            gradient: const LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F1B45), Color(0xFF060B1F)]),
            border: Border.all(color: Tk.line),
            boxShadow: [BoxShadow(color: const Color(0xFF7C5CFF).withValues(alpha: .45), blurRadius: size * .6, spreadRadius: -6)],
          ),
          child: CustomPaint(size: Size.square(size * .68), painter: _StepsPainter()),
        ),
        if (wordmark) ...[
          const SizedBox(width: 10),
          Text('YUGTY',
              style: GoogleFonts.sora(fontSize: size * .45, fontWeight: FontWeight.w700, letterSpacing: 2.2)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: Tk.accent.withValues(alpha: .5)),
            ),
            child: Text('CAMPUS',
                style: GoogleFonts.sora(fontSize: size * .26, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: Tk.accent)),
          ),
        ],
      ],
    );
  }
}

/// Animated circular progress ring.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.value, this.size = 110, this.stroke = 10, this.child});
  final double value;
  final double size;
  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: 900.ms,
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _RingPainter(v, stroke), child: Center(child: child)),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v, this.stroke);
  final double v;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final c = rect.center;
    final r = (size.shortestSide - stroke) / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: .1);
    canvas.drawCircle(c, r, track);
    if (v <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: const [Tk.accent, Tk.accent2, Tk.accent],
      ).createShader(rect);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * v, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.v != v || o.stroke != stroke;
}

Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: 450.ms,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, a, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(begin: const Offset(0, .03), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 19))),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(color: Tk.accent))),
        ],
      );
}

/// The app icon's three rising steps (College ready, Trained, Job ready) and the student dot.
class _StepsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Artwork box in icon units: x 170..854, y 140..860.
    const w = 684.0, h = 720.0;
    final k = (size.width / w) < (size.height / h) ? size.width / w : size.height / h;
    canvas.translate((size.width - w * k) / 2 - 170 * k, (size.height - h * k) / 2 - 140 * k);
    canvas.scale(k);
    void bar(double x, double y, double ht, Color a, Color b) {
      final r = Rect.fromLTWH(x, y, 210, ht);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(64)),
        Paint()..shader = LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [a, b]).createShader(r),
      );
    }

    bar(170, 600, 260, const Color(0xFF2563EB), const Color(0xFF38BDF8));
    bar(407, 450, 410, const Color(0xFF059669), const Color(0xFF34D399));
    bar(644, 300, 560, const Color(0xFF7C3AED), const Color(0xFFC4B5FD));
    canvas.drawCircle(const Offset(749, 205), 62, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_StepsPainter oldDelegate) => false;
}
