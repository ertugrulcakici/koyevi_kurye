import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koyevi_kurye/core/services/cache/cache_manager.dart';
import 'package:koyevi_kurye/core/services/navigation/navigation_service.dart';
import 'package:koyevi_kurye/view/auth/splash/splash_view.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheManager.initCache();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        home: const SplashView(),
      ),
    );
  }
}
