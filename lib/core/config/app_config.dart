import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_endpoints.dart';

enum AppEnvironment {
  development,
  staging,
  production,
}

class AppConfig {
  final String apiBaseUrl;
  final String wsBaseUrl;
  final String stripePublishableKey;
  final String sentryDsn;
  final AppEnvironment environment;
  final bool enableAnalytics;
  final bool isMockFallbackEnabled;

  const AppConfig({
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.stripePublishableKey,
    required this.sentryDsn,
    required this.environment,
    required this.enableAnalytics,
    required this.isMockFallbackEnabled,
  });

  static AppConfig? _instance;
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError('AppConfig has not been initialized. Call AppConfig.initialize() first.');
    }
    return _instance!;
  }

  static Future<AppConfig> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Graceful fallback if .env is missing
    }

    final envStr = dotenv.maybeGet('ENVIRONMENT')?.toLowerCase() ?? 'development';
    final env = switch (envStr) {
      'production' => AppEnvironment.production,
      'staging' => AppEnvironment.staging,
      _ => AppEnvironment.development,
    };

    final config = AppConfig(
      apiBaseUrl: dotenv.maybeGet('API_BASE_URL') ?? ApiEndpoints.defaultBaseUrl,
      wsBaseUrl: dotenv.maybeGet('WS_BASE_URL') ?? ApiEndpoints.defaultWsUrl,
      stripePublishableKey: dotenv.maybeGet('STRIPE_PUBLISHABLE_KEY') ?? '',
      sentryDsn: dotenv.maybeGet('SENTRY_DSN') ?? '',
      environment: env,
      enableAnalytics: dotenv.maybeGet('ENABLE_ANALYTICS') == 'true',
      isMockFallbackEnabled: dotenv.maybeGet('ENABLE_MOCK_FALLBACK') != 'false',
    );

    _instance = config;
    return config;
  }

  bool get isProduction => environment == AppEnvironment.production;
  bool get isDevelopment => environment == AppEnvironment.development;
}
