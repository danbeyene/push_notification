import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:push_notification/new_screen.dart';
import 'package:push_notification/notification_badge.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? mToken = '';
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late int _totalNotification;
  @override
  void initState() {
    requestPermission();
    getToken();
    initInfo();
    _totalNotification = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NotificationBadge(totalNotification: _totalNotification),
              const SizedBox(height: 40,),
              TextFormField(
                controller: username,
              ),
              TextFormField(
                controller: title,
              ),
              TextFormField(
                controller: body,
              ),
              GestureDetector(
                onTap: () async {
                  String name = username.text.trim();
                  String titleText = title.text;
                  String bodyText = body.text;
                  if (name != "") {
                    DocumentSnapshot snap = await FirebaseFirestore.instance
                        .collection('UserTokens')
                        .doc(name)
                        .get();
                    String token = snap['token'];
                    debugPrint(token);
                    sendMessage(token, titleText, bodyText);
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(20),
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.redAccent.withOpacity(0.5))
                      ]),
                  child: Center(
                    child: Text('Button'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('user granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('user granted provisional permission');
    } else {
      debugPrint('user declined or has not accepted permission');
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mToken = token;
        debugPrint('my Token is $mToken');
      });
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection('UserTokens')
        .doc('User2')
        .set({'token': token});
  }

  Future<void> initInfo() async {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const IOSInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onSelectNotification: (String? payload) async {
      try {
        if (payload != null && payload.isNotEmpty) {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
            return NewScreen(info: payload.toString());
          }));
        } else {}
      } catch (e) {}
      return;
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('-----------------onMessage------------------');
      debugPrint(
          'onMessage : ${message.notification?.title}/${message.notification?.body}');

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'push_notification', 'push_notification', importance: Importance.max,
        styleInformation: bigTextStyleInformation, priority: Priority.max,
        playSound: true,
        //sound: RawResourceAndroidNotificationSound('notification')
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: IOSNotificationDetails());

      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);
      setState(() {
        _totalNotification++;
      });
    });
  }

  void sendMessage(String token, String title, String body) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAA7VLHFvQ:APA91bG0Hgvz3KqeYx--l0jF72hMh5cdOTZdCpQZI7nc1ZenNtVVjZ6bMZtEtaUSrboSOwSUn5APCiSzt0oTtK4jw5Gu6rcIqCO99HTzKsngr_gPlcQDIAzrMePIliXvja489QsA_J6k'
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click-action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'title': title,
              'body': body
            },
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'android_channel_id': 'push_notification'
            },
            'to': token
          }
        ),
      );
    } catch (e) {
      debugPrint('error push notification : ${e.toString()}');
    }
  }
}
