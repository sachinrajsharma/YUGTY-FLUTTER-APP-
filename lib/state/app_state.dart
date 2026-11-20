import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class PathTask {
  final String id;
  final int phase; // 0 college ready, 1 professionally trained, 2 job ready
  final String title;
  final String sub;
  const PathTask(this.id, this.phase, this.title, this.sub);
}

const phaseNames = ['College ready', 'Professionally trained', 'Job ready'];

const pathTasks = <PathTask>[
  PathTask('passport', 0, 'Set up your Career Passport', 'Your verified profile, in one place'),
  PathTask('course', 0, 'Start your first course', 'Pick a skill to build this month'),
  PathTask('resume', 1, 'Build an ATS-friendly resume', 'Pass the screening software'),
  PathTask('interview', 1, 'Practise a mock interview', 'Audio or video, with AI feedback'),
  PathTask('video', 2, 'Record a video resume', 'Let recruiters meet you'),
  PathTask('jobs', 2, 'Turn on job matching', 'Get matched jobs and internships'),
];

class AppState extends ChangeNotifier {
  AppState(this._prefs, this.auth) {
    onboarded = _prefs.getBool('onboarded') ?? false;
    loggedIn = _prefs.getBool('loggedIn') ?? false;
    name = _prefs.getString('name') ?? '';
    phone = _prefs.getString('phone') ?? '';
    planIndex = _prefs.getInt('plan') ?? 0;
    notifications = _prefs.getBool('notifications') ?? true;
    done = (_prefs.getStringList('done') ?? const <String>[]).toSet();
  }

  final SharedPreferences _prefs;
  final AuthService auth;

  late bool onboarded;
  late bool loggedIn;
  late String name;
  late String phone;
  late int planIndex;
  late bool notifications;
  late Set<String> done;

  String get firstName {
    final n = name.trim();
    if (n.isEmpty) return 'there';
    return n.split(' ').first;
  }

  double get progress => done.length / pathTasks.length;

  /// The phase the student is working on (0..2), or 3 when everything is done.
  int get currentPhase {
    for (var p = 0; p < 3; p++) {
      if (pathTasks.where((t) => t.phase == p).any((t) => !done.contains(t.id))) {
        return p;
      }
    }
    return 3;
  }

  static Future<AppState> load(AuthService auth) async =>
      AppState(await SharedPreferences.getInstance(), auth);

  Future<void> finishOnboarding() async {
    onboarded = true;
    await _prefs.setBool('onboarded', true);
    notifyListeners();
  }

  Future<void> signIn({String? phone, String? name}) async {
    loggedIn = true;
    if (phone != null) this.phone = phone;
    if (name != null && name.isNotEmpty) this.name = name;
    await _prefs.setBool('loggedIn', true);
    await _prefs.setString('phone', this.phone);
    await _prefs.setString('name', this.name);
    notifyListeners();
  }

  Future<void> signOut() async {
    loggedIn = false;
    await _prefs.setBool('loggedIn', false);
    notifyListeners();
  }

  Future<void> setName(String v) async {
    name = v.trim();
    await _prefs.setString('name', name);
    notifyListeners();
  }

  Future<void> setPlan(int i) async {
    planIndex = i;
    await _prefs.setInt('plan', i);
    notifyListeners();
  }

  Future<void> setNotifications(bool v) async {
    notifications = v;
    await _prefs.setBool('notifications', v);
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    done.contains(id) ? done.remove(id) : done.add(id);
    await _prefs.setStringList('done', done.toList());
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
