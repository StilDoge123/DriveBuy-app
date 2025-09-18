/// Service to handle datetime parsing and timezone conversions
/// Fixes the issue where backend timestamps are in a different timezone (UTC or server timezone)
/// and need to be converted to local device time for proper display
class DateTimeService {
  static final DateTimeService _instance = DateTimeService._internal();
  factory DateTimeService() => _instance;
  DateTimeService._internal();

  /// Parse a timestamp string from the backend and convert to local time
  /// This handles the timezone conversion to fix the 3-hour difference issue
  DateTime parseBackendTimestamp(String timestampStr) {
    try {
      // Parse the timestamp - this treats it as UTC if no timezone is specified
      DateTime parsedDateTime = DateTime.parse(timestampStr);
      
      // If the parsed datetime is in UTC, convert to local time
      if (parsedDateTime.isUtc) {
        return parsedDateTime.toLocal();
      }
      
      // If it's not UTC but still seems wrong (3 hours behind), 
      // assume it's UTC and convert to local
      final now = DateTime.now();
      final difference = now.difference(parsedDateTime).inHours.abs();
      
      // If the difference is around 3 hours, likely a timezone issue
      // Treat as UTC and convert to local
      if (difference >= 2 && difference <= 4) {
        print('🔍 DateTimeService: Detected timezone issue (${difference}h difference), converting to local time');
        return DateTime.utc(
          parsedDateTime.year,
          parsedDateTime.month,
          parsedDateTime.day,
          parsedDateTime.hour,
          parsedDateTime.minute,
          parsedDateTime.second,
          parsedDateTime.millisecond,
        ).toLocal();
      }
      
      // Otherwise, return as-is
      return parsedDateTime;
    } catch (e) {
      print('🔍 DateTimeService: Error parsing timestamp "$timestampStr": $e');
      // Fallback to current time
      return DateTime.now();
    }
  }

  /// Parse a timestamp with explicit UTC handling
  /// Use this when you know the backend sends UTC timestamps
  DateTime parseUtcTimestamp(String timestampStr) {
    try {
      DateTime parsedDateTime = DateTime.parse(timestampStr);
      
      // Force treat as UTC and convert to local
      if (!parsedDateTime.isUtc) {
        parsedDateTime = DateTime.utc(
          parsedDateTime.year,
          parsedDateTime.month,
          parsedDateTime.day,
          parsedDateTime.hour,
          parsedDateTime.minute,
          parsedDateTime.second,
          parsedDateTime.millisecond,
        );
      }
      
      return parsedDateTime.toLocal();
    } catch (e) {
      print('🔍 DateTimeService: Error parsing UTC timestamp "$timestampStr": $e');
      return DateTime.now();
    }
  }

  /// Parse with manual timezone offset (in hours)
  /// Use this if you know the exact timezone difference
  DateTime parseWithOffset(String timestampStr, int offsetHours) {
    try {
      DateTime parsedDateTime = DateTime.parse(timestampStr);
      
      // Add the offset to correct the timezone
      return parsedDateTime.add(Duration(hours: offsetHours));
    } catch (e) {
      print('🔍 DateTimeService: Error parsing timestamp with offset "$timestampStr": $e');
      return DateTime.now();
    }
  }

  /// Debug method to log timestamp information
  void debugTimestamp(String label, String timestampStr) {
    try {
      final parsed = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(parsed);
      
      print('🔍 DateTimeService: $label');
      print('  - Original string: $timestampStr');
      print('  - Parsed datetime: $parsed');
      print('  - Is UTC: ${parsed.isUtc}');
      print('  - Current time: $now');
      print('  - Difference: ${difference.inHours}h ${difference.inMinutes % 60}m');
      print('  - Converted to local: ${parsed.isUtc ? parsed.toLocal() : parsed}');
    } catch (e) {
      print('🔍 DateTimeService: Error debugging timestamp "$timestampStr": $e');
    }
  }
}
