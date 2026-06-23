import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Backend URL with platform-aware host rewriting:
  /// - Web / iOS simulator / desktop: `localhost` works as-is.
  /// - Android emulator: `localhost` is the emulator itself, so rewrite to
  ///   the special `10.0.2.2` alias that maps to the host machine.
  /// - Physical device: user must set BACKEND_URL to the host's LAN IP
  ///   (e.g. http://172.22.144.193:8000) in `.env`.
  static String get backendUrl {
    final raw = dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';
    if (!kIsWeb && Platform.isAndroid) {
      return raw
          .replaceFirst('localhost', '10.0.2.2')
          .replaceFirst('127.0.0.1', '10.0.2.2');
    }
    return raw;
  }
}
