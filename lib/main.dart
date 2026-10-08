import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'data/provider_repository.dart';
import 'screen/onboarding_page.dart';
import 'screen/login_page.dart';
import 'screen/main_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox<String>('fixora');
  final repository = AssetProviderRepository();
  final state = AppState(repository, box);
  await state.initialize();
  runApp(ChangeNotifierProvider.value(value: state, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) => MaterialApp(
        title: 'Fixora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: state.themeMode,
        home: state.isAuthenticated
            ? const MainShell()
            : state.hasSeenOnboarding
                ? const LoginPage()
                : const OnboardingPage(),
      ),
    );
  }
}
