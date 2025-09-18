import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart scripts/switch_api_config.dart [domain|ip]');
    print('  domain - Use domain URL (https://drivebuy.onrender.com)');
    print('  ip     - Use IP URL (https://216.24.57.4)');
    return;
  }

  final mode = args[0].toLowerCase();
  final configFile = File('lib/config/api_config.dart');
  
  if (!configFile.existsSync()) {
    print('Error: lib/config/api_config.dart not found');
    return;
  }

  String content;
  if (mode == 'ip') {
    content = '''class ApiConfig {
  // Use IP address for physical device testing when DNS fails
  static const bool useIpAddress = true;
  
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
}''';
    print('Switched to IP mode (https://216.24.57.4)');
  } else if (mode == 'domain') {
    content = '''class ApiConfig {
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
}''';
    print('Switched to domain mode (https://drivebuy.onrender.com)');
  } else {
    print('Error: Invalid mode. Use "domain" or "ip"');
    return;
  }

  configFile.writeAsStringSync(content);
  print('Configuration updated successfully!');
  print('Run "flutter clean && flutter pub get" to ensure changes take effect.');
} 