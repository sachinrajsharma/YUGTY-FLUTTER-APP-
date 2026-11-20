import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash_onboarding.dart';
import 'services/auth_service.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Tk.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Swap MockAuthService for the real backend implementation when it is ready.
  final state = await AppState.load(MockAuthService());
  runApp(YugtyApp(state: state));
}

class YugtyApp extends StatelessWidget {
  const YugtyApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'YUGTY Campus',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        themeMode: ThemeMode.dark,
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.12,
          child: child!,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
