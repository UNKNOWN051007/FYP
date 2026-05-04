import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_theme.dart';
import 'providers/app_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';
import 'screens/splash_screen.dart';

// Replace with your real values from .env / build config
const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://your-project.supabase.co',
);
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'your-anon-key',
);
const _backendUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  final supabaseClient = Supabase.instance.client;
  final authService = AuthService(supabaseClient);
  final apiService = ApiService(baseUrl: _backendUrl);
  final supabaseService = SupabaseService(supabaseClient);

  final appProvider = AppProvider(
    authService: authService,
    apiService: apiService,
    supabaseService: supabaseService,
  );
  await appProvider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const WageWiseApp(),
    ),
  );
}

class WageWiseApp extends StatelessWidget {
  const WageWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WageWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      localizationsDelegates: const [
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
      home: const SplashScreen(),
    );
  }
}
