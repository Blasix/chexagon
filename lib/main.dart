import 'package:chexagon/screens/auth/login.dart';
import 'package:chexagon/screens/auth/register.dart';
import 'package:chexagon/screens/game/game_board.dart';
import 'package:chexagon/screens/game/game_select.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'nonweb_url_strategy.dart'
    if (dart.library.html) 'web_url_strategy.dart';

import 'firebase_options.dart';

// GoRouter configuration
final _router = GoRouter(
  initialLocation:
      FirebaseAuth.instance.currentUser == null ? '/register' : '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const GameSelect(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/game:gameId',
      builder: (context, state) => GameBoard(
        gameID: state.pathParameters['gameId']!,
      ),
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  configureUrl();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Chexagon',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.white,
          onSecondary: Colors.black,
          error: Colors.red,
          onError: Colors.white,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
    );
  }
}
