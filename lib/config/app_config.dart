class AppConfig {
  // Backend proxy base URL for AI requests.
  // Set at build/run time using --dart-define=BACKEND_BASE_URL=...
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue:
        'https://us-central1-business-setup-application.cloudfunctions.net',
  );

  // Optional: customize chat path if your backend uses a different route
  static const String backendChatPath = String.fromEnvironment(
    'BACKEND_CHAT_PATH',
    defaultValue: '/chatAI',
  );
}
