import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yugty_app/data/plans.dart';
import 'package:yugty_app/services/auth_service.dart';
import 'package:yugty_app/state/app_state.dart';

void main() {
  test('plans data matches the Seeker Packages PDF shape', () {
    expect(plans.map((p) => p.name), ['Explorer', 'Starter', 'Pro', 'Elite']);
    expect(plans.where((p) => p.popular).single.name, 'Pro');
    for (final f in features) {
      expect(f.values.length, plans.length, reason: f.label);
    }
    // 7 not-included cells, as in the PDF.
    final blanks = features.expand((f) => f.values).where((v) => v.isEmpty).length;
    expect(blanks, 7);
  });

  test('mock auth accepts only 6-digit codes', () async {
    final a = MockAuthService();
    expect(await a.verifyOtp('9876543210', '123456'), isTrue);
    expect(await a.verifyOtp('9876543210', '12345'), isFalse);
    expect(await a.verifyOtp('9876543210', 'abcdef'), isFalse);
  });

  test('app state persists progress and login', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await AppState.load(MockAuthService());
    expect(s.loggedIn, isFalse);
    expect(s.progress, 0);
    expect(s.currentPhase, 0);
    await s.signIn(phone: '9876543210', name: 'Asha Rao');
    await s.toggleTask('passport');
    await s.toggleTask('course');
    expect(s.firstName, 'Asha');
    expect(s.currentPhase, 1);
    final again = await AppState.load(MockAuthService());
    expect(again.loggedIn, isTrue);
    expect(again.done, {'passport', 'course'});
    for (final t in pathTasks) {
      if (!again.done.contains(t.id)) await again.toggleTask(t.id);
    }
    expect(again.currentPhase, 3);
    expect(again.progress, 1);
  });
}
