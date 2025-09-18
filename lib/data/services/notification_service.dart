import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  int _notificationCounter = 0;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final result = await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = result ?? false;
    print('🔍 NotificationService: Initialized with result: $_isInitialized');

    // Request notification permission for Android 13+
    if (_isInitialized) {
      await _requestNotificationPermission();
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final bool? granted = await androidPlugin.requestNotificationsPermission();
        print('🔍 NotificationService: Android notification permission granted: $granted');
        
        if (granted == false) {
          print('🔍 NotificationService: Notification permission denied, notifications will not work');
        }
      }
    } catch (e) {
      print('🔍 NotificationService: Error requesting notification permission: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('🔍 NotificationService: Notification tapped: ${response.payload}');
    // Handle notification tap - could navigate to specific chat
    // For now, just log it
  }

  /// Generate a unique notification ID to ensure each notification is shown separately
  int _generateUniqueNotificationId() {
    _notificationCounter = (_notificationCounter + 1) % 100000; // Reset after 100k to avoid overflow
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Combine counter with timestamp to ensure uniqueness
    // Use modulo to keep the ID within reasonable bounds
    return (timestamp % 1000000) + _notificationCounter;
  }

  Future<void> showMessageNotification({
    required String title,
    required String body,
    required int chatId,
  }) async {
    print('🔍 NotificationService: ====== SHOW NOTIFICATION REQUEST ======');
    print('🔍 NotificationService: Chat ID: $chatId');
    print('🔍 NotificationService: Title: $title');
    print('🔍 NotificationService: Body: $body');
    print('🔍 NotificationService: Initialized: $_isInitialized');
    print('🔍 NotificationService: Counter: $_notificationCounter');
    
    if (!_isInitialized) {
      print('🔍 NotificationService: Not initialized, attempting to reinitialize...');
      await initialize();
      if (!_isInitialized) {
        print('🔍 NotificationService: Reinitialization failed, cannot show notification');
        return;
      }
    }

    // Check if we have notification permission (Android 13+)
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final bool? hasPermission = await androidPlugin.areNotificationsEnabled();
      print('🔍 NotificationService: Notifications enabled: $hasPermission');
      
      if (hasPermission == false) {
        print('🔍 NotificationService: Notifications are disabled, cannot show notification');
        return;
      }
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      // Ensure each notification is shown separately
      autoCancel: true,
      ongoing: false,
      onlyAlertOnce: false, // Allow multiple alerts
      channelShowBadge: true,
      // Add these to ensure notifications don't get grouped or suppressed
      groupKey: null, // Don't group notifications
      setAsGroupSummary: false,
      // Make sure the notification is visible
      visibility: NotificationVisibility.public,
      ticker: 'New message', // Shows in status bar
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      // Generate a unique notification ID for each message
      // This ensures each notification is shown separately rather than replacing the previous one
      final notificationId = _generateUniqueNotificationId();
      print('🔍 NotificationService: Generated unique notification ID: $notificationId');
      
      await _notifications.show(
        notificationId,
        title,
        body,
        details,
        payload: chatId.toString(), // Keep chatId in payload for tap handling
      );

      print('🔍 NotificationService: ✅ SUCCESS - Notification ID $notificationId shown for chat $chatId');
      print('🔍 NotificationService: ====== END NOTIFICATION REQUEST ======');
    } catch (e) {
      print('🔍 NotificationService: ❌ ERROR showing notification: $e');
      // Log more details about the error for debugging
      if (e.toString().contains('permission')) {
        print('🔍 NotificationService: Error is permission-related. User may have denied notification permission.');
      }
      print('🔍 NotificationService: ====== END NOTIFICATION REQUEST (ERROR) ======');
    }
  }

  Future<void> cancelNotification(int chatId) async {
    // Since we now use unique notification IDs instead of chatId,
    // we can't cancel specific chat notifications without tracking them.
    // For now, this method will cancel all notifications.
    // In the future, we could maintain a mapping of chatId -> List<notificationId>
    await _notifications.cancelAll();
    print('🔍 NotificationService: Cancelled all notifications (requested for chat $chatId)');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🔍 NotificationService: Cancelled all notifications');
  }
}
