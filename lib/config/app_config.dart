class AppConfig {
  // OpenAI API Configuration
  // IMPORTANT: In production, store this securely using:
  // 1. Environment variables
  // 2. Flutter Secure Storage
  // 3. Backend API that proxies OpenAI requests
  //
  // For development, you can set your API key here temporarily
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '', // Leave empty and set via --dart-define
  );

  // Check if API key is configured
  static bool get hasOpenAiKey => openAiApiKey.isNotEmpty;
}
