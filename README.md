# YUGTY Campus (Flutter)

Mobile app for college students: **Ready for college. Ready for work.**
Built from the live Campus page (vidaara.org/yugticampus) and the *Seeker Packages* sheet.

## What is in this build

| Screen | What it does |
|---|---|
| Splash + onboarding | Animated logo, three-step story (College ready, Professionally trained, Job ready) |
| Login | Mobile number + OTP (six boxes, auto-verify, resend timer), Continue with Google, Explore as guest |
| Home | Job-ready progress ring, three-phase stepper, tappable readiness path, toolkit carousel, plan banner |
| Toolkit | 10 tools; each shows what your plan includes and what unlocks on higher plans |
| Plans | Explorer / Starter / Pro / Elite cards (swipe), exact features from the Seeker Packages PDF |
| Profile | Career Passport card, edit name, plan, notifications, log out |

Dark theme, Sora + Inter, haptics, motion, large touch targets.

## Demo mode (read this)

There is no backend yet:

- `lib/services/auth_service.dart`: `MockAuthService` sends no SMS and accepts **any 6-digit code**; Google sign-in is simulated. Implement `AuthService` against the real API and swap it in `lib/main.dart`.
- Choosing a paid plan only switches the plan **on the device**. No payment is taken.
- Progress, name, plan and login are stored locally with `shared_preferences`.
- The QR-style pattern on the Career Passport is decorative, not a scannable code.

## Run

```
flutter pub get
flutter run            # device or emulator
flutter test
flutter analyze
```

## Structure

```
lib/
  main.dart            entry, theme, app state scope
  theme.dart           design tokens (colours, fonts)
  data/plans.dart      packages and features (source of truth: Seeker Packages.pdf)
  state/app_state.dart persisted state and readiness path
  services/            AuthService + mock
  widgets/common.dart  aurora background, glass card, buttons, progress ring
  screens/             splash, onboarding, login/OTP, shell, home, toolkit, plans, profile
```
