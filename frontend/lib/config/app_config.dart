/// AYRNOW app configuration.
/// In production, these values should come from dart-define or a build config.
/// For local dev, these defaults point to localhost.
class AppConfig {
  /// Backend API base URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  /// Stripe publishable key (safe for client-side, used for Stripe Elements / Apple Pay)
  /// Not required for current Checkout Session flow, but ready for future use.
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
}
