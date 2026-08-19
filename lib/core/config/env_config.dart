enum Environment { dev, staging, prod }

class EnvConfig {
  final Environment environment;
  final String baseUrl;
  final String apiVersion;

  const EnvConfig({
    required this.environment,
    required this.baseUrl,
    this.apiVersion = 'v1',
  });

  /// Production Live Server (https://agmkhair.com/alphie_core/public/api/v1)
  static const EnvConfig production = EnvConfig(
    environment: Environment.prod,
    baseUrl: 'https://agmkhair.com/alphie_core/public/api',
    apiVersion: 'v1',
  );

  /// Local Development Server
  static const EnvConfig development = EnvConfig(
    environment: Environment.dev,
    baseUrl: 'http://127.0.0.1:8000/api',
    apiVersion: 'v1',
  );

  /// Active Runtime Configuration
  static EnvConfig current = production;
}
