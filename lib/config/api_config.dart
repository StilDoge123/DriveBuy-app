class ApiConfig {
  // Use IP address for physical device testing when DNS fails
  static const bool useIpAddress = false;
  
  // Domain-based URL (works on Mac/emulator but may fail on physical devices)
  static const String domainUrl = 'https://drivebuy.onrender.com';
  
  // IP-based URL (temporary solution for physical device DNS issues)
  static const String ipUrl = 'https://216.24.57.4';
  
  // Current base URL
  static String get baseUrl => useIpAddress ? ipUrl : domainUrl;
  
  // Headers for API requests
  static const Map<String, String> defaultHeaders = {
    'User-Agent': 'Mozilla/5.0 (Android 10; Mobile; rv:91.0) Gecko/91.0 Firefox/91.0',
    'Content-Type': 'application/json',
  };
}