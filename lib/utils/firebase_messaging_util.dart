import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

void handleMessage(RemoteMessage? message) {
  if (message == null) return;

  print('Push Title: ${message.notification?.title}');
  print('Push Body: ${message.notification?.body}');
  print('Push Payload: ${message.data}');
}

Future<String> getToken() async {
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken == null) {
    return '';
  }
  return fcmToken;
}

class FirebaseMessagingUtil {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  static final _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notification',
      description: 'This channel is used for important notifications',
      importance: Importance.defaultImportance);

  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static Future initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await getToken();
    print('Token: $fCMToken');
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    initPushNotifications();
    initLocalNotifications();
  }

  static Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                  _androidChannel.id, _androidChannel.name,
                  channelDescription: _androidChannel.description,
                  icon: '@drawable/ic_launcher')),
          payload: jsonEncode(message.toMap()));
    });
  }

  static Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(settings);
  }

  static Future sendPrescribedWorkoutNotif(
      String userToken, String workoutName, DateTime workoutDate) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer AAAAh14DqSY:APA91bHI1TXU99UCZglE7O1mhxe7hRX7zWj3TASYVGF4lKSkPnqK5IsEBRin8HWDV8WQkBs3QmcePGtBQLh1o6yhcwIFbk0P3KwI8seEZXwkT-YF-U-OLceRDDIy-piIHIq3ZuvMMc7h'
        },
        body: jsonEncode({
          "to": userToken,
          "notification": {
            "title":
                "Your trainer has prescribed you a new workout: $workoutName",
            "body":
                "$workoutName is scheduled on ${DateFormat('MMM dd yyyy').format(workoutDate)}"
          }
        }),
      );
    } catch (e) {
      print("Error making POST request: $e");
    }
  }

  static Future sendRemovedWorkoutNotif(
      String userToken, String workoutName, DateTime workoutDate) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer AAAAh14DqSY:APA91bHI1TXU99UCZglE7O1mhxe7hRX7zWj3TASYVGF4lKSkPnqK5IsEBRin8HWDV8WQkBs3QmcePGtBQLh1o6yhcwIFbk0P3KwI8seEZXwkT-YF-U-OLceRDDIy-piIHIq3ZuvMMc7h'
        },
        body: jsonEncode({
          "to": userToken,
          "notification": {
            "title": "Your trainer has cancelled this workout: $workoutName",
            "body":
                "$workoutName was originally scheduled on ${DateFormat('MMM dd yyyy').format(workoutDate)}"
          }
        }),
      );
    } catch (e) {
      print("Error making POST request: $e");
    }
  }

  static Future sendWorkoutDoneNotif(
      String userToken, String workoutName, DateTime workoutDate) async {
    try {
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer AAAAh14DqSY:APA91bHI1TXU99UCZglE7O1mhxe7hRX7zWj3TASYVGF4lKSkPnqK5IsEBRin8HWDV8WQkBs3QmcePGtBQLh1o6yhcwIFbk0P3KwI8seEZXwkT-YF-U-OLceRDDIy-piIHIq3ZuvMMc7h'
        },
        body: jsonEncode({
          "to": userToken,
          "notification": {
            "title": "Workout Entry Added!",
            "body":
                "Your workout for ${DateFormat('MMM dd yyyy').format(workoutDate)} has been successfully added to your workout history."
          }
        }),
      );
      if (response.statusCode == 200) {
        print('success');
      } else {
        print("Request failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error making POST request: $e");
    }
  }

  static Future sendMessageSentNotif(
      String userToken, String sender, String message) async {
    try {
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer AAAAh14DqSY:APA91bHI1TXU99UCZglE7O1mhxe7hRX7zWj3TASYVGF4lKSkPnqK5IsEBRin8HWDV8WQkBs3QmcePGtBQLh1o6yhcwIFbk0P3KwI8seEZXwkT-YF-U-OLceRDDIy-piIHIq3ZuvMMc7h'
        },
        body: jsonEncode({
          "to": userToken,
          "notification": {"title": sender, "body": message}
        }),
      );
      if (response.statusCode == 200) {
        print('success');
      } else {
        print("Request failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error making POST request: $e");
    }
  }
}
