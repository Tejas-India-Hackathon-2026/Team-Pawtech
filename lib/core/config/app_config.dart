class AppConfig {
  static const String appName = 'PashuRakhshak';
  static const String appVersion = '1.0.0';

  // Supabase Config
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://demo-pashurakhshak.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key',
  );

  // Razorpay Client Key ID (Secret key is strictly on backend Edge Functions)
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_pashu12345678',
  );

  // Pricing Plans (INR)
  static const int monthlySubscriptionPriceInr = 99;
  static const int yearlySubscriptionPriceInr = 999;

  // Supabase Edge Function Endpoints
  static String get identifyAnimalEndpoint =>
      '$supabaseUrl/functions/v1/identify-animal';
  static String get razorpayOrderEndpoint =>
      '$supabaseUrl/functions/v1/razorpay-order';
  static String get razorpayWebhookEndpoint =>
      '$supabaseUrl/functions/v1/razorpay-webhook';

  // Google Maps API Key
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  // Gemini AI Vision & Chatbot API Key
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  // Google Maps Geolocation API Key (Exact Coordinates Audit System)
  static const String googleGeolocationApiKey = String.fromEnvironment(
    'GOOGLE_GEOLOCATION_API_KEY',
    defaultValue: '',
  );

  // Google Maps Geocoding API Key (Address Audit System)
  static const String googleGeocodingApiKey = String.fromEnvironment(
    'GOOGLE_GEOCODING_API_KEY',
    defaultValue: '',
  );
}
