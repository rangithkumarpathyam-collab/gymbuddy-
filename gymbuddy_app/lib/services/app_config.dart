/// Centralized configuration for API keys and service endpoints.
/// Values are injected at compile time via --dart-define or Render environment variables.
class AppConfig {
  // Gemini API key injected via --dart-define=GEMINI_API_KEY=your_key
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  // Twilio credentials (injected via --dart-define or environment)
  static const String twilioAccountSid = String.fromEnvironment(
    'TWILIO_ACCOUNT_SID',
    defaultValue: '',
  );

  static const String twilioAuthToken = String.fromEnvironment(
    'TWILIO_AUTH_TOKEN',
    defaultValue: '',
  );

  static const String twilioWhatsappFrom = String.fromEnvironment(
    'TWILIO_WHATSAPP_FROM',
    defaultValue: '+17372508034',
  );

  static const String twilioContentSid = String.fromEnvironment(
    'TWILIO_CONTENT_SID',
    defaultValue: 'HXac51c61af94371da7904a767b414c2fc',
  );
}
