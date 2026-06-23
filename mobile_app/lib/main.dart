import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_theme.dart';
import 'config/env.dart';
import 'providers/app_provider.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'widgets/main_scaffold.dart';
import 'package:wagewise/app_localizations.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const WageWiseApp(),
    ),
  );
}

class WageWiseApp extends StatefulWidget {
  const WageWiseApp({super.key});
  @override
  State<WageWiseApp> createState() => _WageWiseAppState();
}

class _WageWiseAppState extends State<WageWiseApp> {
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    // Listen to Supabase auth events — force redirect on session expiry,
    // token revocation, or any sign-out regardless of how it happens.
    _authSub = AuthService.authStateChanges.listen((event) {
      if (event.event == AuthChangeEvent.passwordRecovery) {
        // User clicked the reset-password email link. Supabase has issued a
        // temporary session — route to the dedicated screen so the user can
        // set a new password instead of being silently logged in to /main.
        AuthService.isRecovering = true;
        _navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/reset-password', (_) => false);
      } else if (event.event == AuthChangeEvent.signedOut) {
        AuthService.isRecovering = false;
        _navigatorKey.currentContext?.read<AppProvider>().clearUser();
        _navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/login', (_) => false);
      } else if (event.event == AuthChangeEvent.signedIn ||
                 event.event == AuthChangeEvent.tokenRefreshed ||
                 event.event == AuthChangeEvent.initialSession) {
        // Skip the auto-redirect while a password-recovery flow is in progress
        // — otherwise the temporary recovery session would push the user to
        // /main before they get a chance to set their new password.
        if (AuthService.isRecovering) return;
        // On web, Supabase recovers the session asynchronously after splash
        // has already navigated to /login. If the user is now authenticated,
        // redirect to /main without requiring a manual login.
        final ctx = _navigatorKey.currentContext;
        if (ctx != null && event.session != null) {
          final provider = ctx.read<AppProvider>();
          if (provider.user == null) {
            provider.init().then((_) {
              if (provider.user != null) {
                _navigatorKey.currentState
                    ?.pushNamedAndRemoveUntil('/main', (_) => false);
              }
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  /// Route guard — called for every navigation including direct URL access.
  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final isAuth = AuthService.isSignedIn;
    final name = settings.name ?? '/splash';

    // ── Protected routes ────────────────────────────────────────
    // Accessing /main without a valid Supabase session → redirect to login.
    // MainScaffold itself handles the case where the session exists but the
    // profile hasn't loaded yet (shows a spinner instead of looping).
    if (name == '/main' && !isAuth) {
      return _route(const LoginScreen(), '/login');
    }

    // NOTE: We intentionally do NOT redirect authenticated users away from
    // /login or /register here because that caused an infinite redirect loop
    // when the Supabase session was valid but the profile hadn't loaded yet.
    // MainScaffold's own guard handles that case safely.

    switch (name) {
      case '/splash':         return _route(const SplashScreen(), name);
      case '/onboarding':     return _route(const OnboardingScreen(), name);
      case '/login':          return _route(const LoginScreen(), name);
      case '/register':       return _route(const RegisterScreen(), name);
      case '/reset-password': return _route(const ResetPasswordScreen(), name);
      case '/main':           return _route(const MainScaffold(), name);
      default:                return _route(const SplashScreen(), '/splash');
    }
  }

  static MaterialPageRoute<void> _route(Widget page, String name) =>
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: name),
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (_, provider, __) => MaterialApp(
        title: 'WageWise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.forIndex(provider.themeIndex),
        navigatorKey: _navigatorKey,
        locale: Locale(provider.language),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ms'),
          Locale('zh'),
          Locale('ta'),
        ],
        initialRoute: '/splash',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}
