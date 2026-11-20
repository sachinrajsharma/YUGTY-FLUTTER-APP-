import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';

/// One screen, three ways in: phone OTP (default), Google, or explore as guest.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  bool _busy = false;
  bool _google = false;

  bool get _valid => RegExp(r'^[6-9]\d{9}$').hasMatch(_phone.text);

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final s = AppScope.of(context);
    await s.auth.sendOtp(_phone.text);
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).push(fadeRoute(OtpScreen(phone: _phone.text)));
  }

  Future<void> _googleSignIn() async {
    setState(() => _google = true);
    final s = AppScope.of(context);
    final name = await s.auth.signInWithGoogle();
    if (!mounted) return;
    setState(() => _google = false);
    if (name == null) return;
    await s.signIn(name: name);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(const MainShell()), (_) => false);
  }

  Future<void> _guest() async {
    final s = AppScope.of(context);
    await s.signIn(name: 'Guest');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(const MainShell()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuroraBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const BrandMark(size: 38).animate().fadeIn(duration: 400.ms),
                      const Expanded(child: _Hero()),
                      Text('Ready for college.',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 38, height: 1.05))
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: .15, end: 0),
                      ShaderMask(
                        shaderCallback: (r) => Tk.brandGradient.createShader(r),
                        child: Text('Ready for work.',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(fontSize: 38, height: 1.1, color: Colors.white)),
                      ).animate(delay: 120.ms).fadeIn(duration: 500.ms).slideY(begin: .15, end: 0),
                      const SizedBox(height: 12),
                      const Text('Sign in with your mobile number. No password to remember.',
                              style: TextStyle(color: Tk.mut, fontSize: 15.5, height: 1.45))
                          .animate(delay: 220.ms)
                          .fadeIn(),
                      const SizedBox(height: 28),
                      _PhoneField(controller: _phone, onChanged: (_) => setState(() {}), onSubmit: _valid ? _sendOtp : null)
                          .animate(delay: 300.ms)
                          .fadeIn()
                          .slideY(begin: .1, end: 0),
                      const SizedBox(height: 14),
                      GradientButton(
                        label: 'Get OTP',
                        icon: Icons.sms_rounded,
                        loading: _busy,
                        onPressed: _valid ? _sendOtp : null,
                      ).animate(delay: 380.ms).fadeIn(),
                      const SizedBox(height: 22),
                      Row(children: [
                        const Expanded(child: Divider(color: Tk.line)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text('or continue with', style: TextStyle(color: Tk.mut.withValues(alpha: .8), fontSize: 13)),
                        ),
                        const Expanded(child: Divider(color: Tk.line)),
                      ]),
                      const SizedBox(height: 22),
                      GradientButton(
                        label: 'Continue with Google',
                        secondary: true,
                        loading: _google,
                        icon: Icons.g_mobiledata_rounded,
                        onPressed: _googleSignIn,
                      ).animate(delay: 450.ms).fadeIn(),
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton(
                          onPressed: _guest,
                          child: const Text('Explore as guest', style: TextStyle(color: Tk.accent, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          'By continuing you agree to the Terms and Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Tk.mut, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller, required this.onChanged, this.onSubmit});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Tk.line),
      ),
      child: Row(
        children: [
          Text('🇮🇳', style: GoogleFonts.inter(fontSize: 22)),
          const SizedBox(width: 8),
          Text('+91', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
          Container(width: 1, height: 26, color: Tk.line, margin: const EdgeInsets.symmetric(horizontal: 14)),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmit?.call(),
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.5),
              cursorColor: Tk.accent,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Mobile number',
                hintStyle: GoogleFonts.inter(fontSize: 16, color: Tk.mut, letterSpacing: 0, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _ctl = TextEditingController();
  final _focus = FocusNode();
  bool _busy = false;
  bool _error = false;
  int _left = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _startTimer() {
    _left = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _left--);
      if (_left <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _error = false;
    });
    final s = AppScope.of(context);
    final ok = await s.auth.verifyOtp(widget.phone, _ctl.text);
    if (!mounted) return;
    if (!ok) {
      HapticFeedback.heavyImpact();
      setState(() {
        _busy = false;
        _error = true;
      });
      return;
    }
    await s.signIn(phone: widget.phone, name: s.name.isEmpty ? 'Student' : s.name);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(fadeRoute(const MainShell()), (_) => false);
  }

  Future<void> _resend() async {
    await AppScope.of(context).auth.sendOtp(widget.phone);
    if (!mounted) return;
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A new code has been sent.')));
  }

  @override
  Widget build(BuildContext context) {
    final code = _ctl.text;
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(backgroundColor: Colors.white10),
                ),
                const SizedBox(height: 28),
                Text('Enter the code', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 34)),
                const SizedBox(height: 10),
                Text('We sent a 6-digit code to +91 ${widget.phone}',
                    style: const TextStyle(color: Tk.mut, fontSize: 15.5, height: 1.4)),
                const SizedBox(height: 32),
                Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        final filled = i < code.length;
                        final active = i == code.length && _focus.hasFocus;
                        return AnimatedContainer(
                          duration: 160.ms,
                          width: (MediaQuery.sizeOf(context).width - 48 - 5 * 10) / 6,
                          height: 62,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: filled ? .1 : .05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _error ? Tk.bad : (active ? Tk.accent : Tk.line),
                              width: active || _error ? 1.8 : 1,
                            ),
                          ),
                          child: Text(filled ? code[i] : '',
                              style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w700)),
                        );
                      }),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: _ctl,
                          focusNode: _focus,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                          onChanged: (v) {
                            setState(() => _error = false);
                            if (v.length == 6) _verify();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: 200.ms,
                  child: _error
                      ? const Text('That code is not valid. Try again.',
                          key: ValueKey('e'), style: TextStyle(color: Tk.bad, fontSize: 13.5))
                      : const SizedBox(key: ValueKey('n'), height: 18),
                ),
                const SizedBox(height: 18),
                GradientButton(
                  label: 'Verify and continue',
                  loading: _busy,
                  onPressed: code.length == 6 ? _verify : null,
                ),
                const SizedBox(height: 14),
                Center(
                  child: _left > 0
                      ? Text('Resend code in 0:${_left.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Tk.mut, fontSize: 14))
                      : TextButton(
                          onPressed: _resend,
                          child: const Text('Resend code', style: TextStyle(color: Tk.accent, fontWeight: FontWeight.w600)),
                        ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Tk.gold.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Tk.gold.withValues(alpha: .35)),
                  ),
                  child: const Text(
                    'Demo mode: no SMS is sent. Enter any 6 digits to continue.',
                    style: TextStyle(color: Tk.gold, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated hero: a glowing orb with floating feature chips.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    Widget chip(IconData icon, String text, Alignment a, int ms) => Align(
          alignment: a,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Tk.surface.withValues(alpha: .85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Tk.line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 16, color: Tk.accent),
              const SizedBox(width: 6),
              Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ]),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true), delay: ms.ms)
              .moveY(begin: -5, end: 5, duration: 2.4.seconds, curve: Curves.easeInOut),
        );
    return LayoutBuilder(
      builder: (context, c) {
        final d = (c.maxHeight.clamp(120.0, 230.0)).toDouble();
        return Center(
          child: SizedBox(
            width: double.infinity,
            height: d + 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: d,
                  height: d,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2563EB), Color(0xFF7C5CFF)]),
                    boxShadow: [BoxShadow(color: Tk.accent.withValues(alpha: .45), blurRadius: 70, spreadRadius: -8)],
                  ),
                  child: Icon(Icons.school_rounded, size: d * .46, color: Colors.white),
                ).animate().scale(begin: const Offset(.8, .8), duration: 600.ms, curve: Curves.easeOutBack),
                chip(Icons.description_rounded, 'Resume Studio', const Alignment(-1, -.7), 0),
                chip(Icons.mic_rounded, 'Mock interviews', const Alignment(1, -.1), 500),
                chip(Icons.work_rounded, 'Job matches', const Alignment(-.8, .85), 900),
              ],
            ),
          ),
        );
      },
    );
  }
}
