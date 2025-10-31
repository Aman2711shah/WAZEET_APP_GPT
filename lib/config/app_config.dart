import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // OpenAI API Configuration
  // Loaded from .env file for security
  // The .env file is in .gitignore to prevent accidentally committing API keys
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // Check if API key is configured
  static bool get hasOpenAiKey => openAiApiKey.isNotEmpty;
}
