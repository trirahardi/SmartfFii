class AiConfig {
  AiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: 'https://api.bangunweb.com/v1',
  );

  static const String model = String.fromEnvironment(
    'AI_MODEL',
    defaultValue: 'deepseek-v4.1-flash',
  );

  static const String apiKey = String.fromEnvironment(
    'AI_API_KEY',
    defaultValue: '',
  );

  static bool get hasApiKey => apiKey.trim().isNotEmpty;
}

