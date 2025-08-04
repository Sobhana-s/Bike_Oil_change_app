import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Initialize the notification service
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(initializationSettings);
    
    // Request notification permissions
    await Permission.notification.request();
  }
  
  // Show a local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'oil_change_channel',
      'Oil Change Notifications',
      channelDescription: 'Notifications for bike oil change reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
  
  // Send SMS notification
  Future<void> sendSmsNotification(String phoneNumber, String message) async {
    try {
      // Request SMS permission
      final status = await Permission.sms.request();
      
      if (status.isGranted) {
        await sendSMS(message: message, recipients: [phoneNumber]);
      } else {
        print('SMS permission denied');
      }
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }
  
  // Check if oil change is needed and notify user if necessary
  Future<bool> checkAndNotifyOilChange(
    String bikeNumber,
    String? phoneNumber,
    int distanceSinceLastOilChange,
  ) async {
    const int oilChangeThreshold = 2000; // 2000 km threshold
    
    if (distanceSinceLastOilChange >= oilChangeThreshold) {
      // Show local notification
      await showNotification(
        id: 1,
        title: 'Oil Change Required',
        body: 'Your engine is waiting for a new drink! You\'ve reached $distanceSinceLastOilChange km since the last oil change.',
      );
      
      // Send SMS if phone number is available
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        await sendSmsNotification(
          phoneNumber,
          'Your engine is waiting for a new drink! Your bike ($bikeNumber) has reached $distanceSinceLastOilChange km since the last oil change.',
        );
      }
      
      return true;
    }
    
    return false;
  }
}
