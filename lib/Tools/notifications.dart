import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'logging.dart';

Future<void> showNotification(List<String> text, int i) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('schoolapp bell', 'schoolapp bell',
          channelDescription: 'schoolapp bell notifies you the change in schoolapp',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await printActivityLog(
      "[" + DateTime.now().toString() + "] " + " : push singl notifying");
  await flutterLocalNotificationsPlugin.show(
      i, text[0], text[1], platformChannelSpecifics,
      payload: 'item x');
}

Future<void> showGroupedNotifications(List<List<String>> notifs) async {
  const String groupKey = 'com.android.ensam_assitant.ensam_assisstant';
  const String groupChannelId = 'schoolapp bells';
  const String groupChannelName = 'schoolapp bells';
  const String groupChannelDescription =
      'schoolapp bell notifies you the changes in schoolapp';

  List<String> lines = <String>[];

  for (int i = 0; i < notifs.length; i++) {
    const AndroidNotificationDetails NotificationAndroidSpecifics =
        AndroidNotificationDetails(
            groupChannelId, groupChannelName, channelDescription: groupChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            groupKey: groupKey);

    const NotificationDetails NotificationPlatformSpecifics =
        NotificationDetails(android: NotificationAndroidSpecifics);

    await printActivityLog(
        "[" + DateTime.now().toString() + "] " + " : push mult notifying");

    await flutterLocalNotificationsPlugin.show(
        i, notifs[i][0], notifs[i][1], NotificationPlatformSpecifics);

    lines.add("${notifs[i][0]} ${notifs[i][1]}");
  }

  // Create the summary notification to support older devices that pre-date
  /// Android 7.0 (API level 24).
  ///
  /// Recommended to create this regardless as the behaviour may vary as
  /// mentioned in https://developer.android.com/training/notify-user/group

  InboxStyleInformation inboxStyleInformation = InboxStyleInformation(lines,
      contentTitle: 'messages', summaryText: 'update');
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          groupChannelId, groupChannelName, channelDescription: groupChannelDescription,
          styleInformation: inboxStyleInformation,
          groupKey: groupKey,
          setAsGroupSummary: true);
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      notifs.length, 'Attention', 'message', platformChannelSpecifics);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();

String? selectedNotificationPayload;

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

initNotif() async {
  await _configureLocalTimeZone();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  //String initialRoute = HomePage.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    //initialRoute = SecondPage.routeName;
    //TO DO: configure rootes
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

// Notif Launch Config
/*class HomePage extends StatefulWidget {
  const HomePage(
    this.notificationAppLaunchDetails, {
    Key? key,
  }) : super(key: key);

  static const String routeName = '/';

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    //_configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }
  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        SecondPage(receivedNotification.payload),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigator.pushNamed(context, '/secondPage');
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }
}*/