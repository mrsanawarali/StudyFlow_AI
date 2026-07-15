/// App flavour (build configuration) enum for StudyFlow AI.
enum Flavor {
  development,
  staging,
  production,
}

/// Singleton configuration holder for the active [Flavor].
///
/// Initialise at app start before [runApp] is called:
/// ```dart
/// FlavorConfig.initialize(Flavor.development);
/// ```
class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.enableAnalytics,
  });

  final Flavor flavor;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enableAnalytics;

  static FlavorConfig? _instance;

  /// Returns the active [FlavorConfig] instance.
  /// Throws [StateError] if [initialize] has not been called yet.
  static FlavorConfig get instance {
    if (_instance == null) {
      throw StateError(
        'FlavorConfig has not been initialised. '
        'Call FlavorConfig.initialize() before accessing the instance.',
      );
    }
    return _instance!;
  }

  /// Initialises the singleton with settings for the given [flavor].
  static void initialize(Flavor flavor) {
    switch (flavor) {
      case Flavor.development:
        _instance = FlavorConfig._(
          flavor: flavor,
          apiBaseUrl: 'http://192.168.1.10:5000/api',
          enableLogging: true,
          enableAnalytics: false,
        );
      case Flavor.staging:
        _instance = FlavorConfig._(
          flavor: flavor,
          apiBaseUrl: 'https://staging-api.studyflow.com/api',
          enableLogging: true,
          enableAnalytics: true,
        );
      case Flavor.production:
        _instance = FlavorConfig._(
          flavor: flavor,
          apiBaseUrl: 'https://api.studyflow.com/api',
          enableLogging: false,
          enableAnalytics: true,
        );
    }
  }

  bool get isDevelopment => flavor == Flavor.development;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProduction => flavor == Flavor.production;

  @override
  String toString() =>
      'FlavorConfig(flavor: $flavor, apiBaseUrl: $apiBaseUrl)';
}
