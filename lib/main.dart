import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:chat_app/view/screens/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';

//global object for accessing device screen size
late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  //for setting orientation to portrait only
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    _initializeFirebase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define a custom primary color
  static const Color myPrimaryColor = Color(0xFF8C8AFF); // Hex color: #8C8AFF

  // Generate shades for the custom primary color
  static MaterialColor myPrimaryColorSwatch =
  MaterialColor(myPrimaryColor.value, <int, Color>{
    50: myPrimaryColor.withOpacity(0.1),
    100: myPrimaryColor.withOpacity(0.2),
    200: myPrimaryColor.withOpacity(0.3),
    300: myPrimaryColor.withOpacity(0.4),
    400: myPrimaryColor.withOpacity(0.5),
    500: myPrimaryColor.withOpacity(0.6),
    600: myPrimaryColor.withOpacity(0.7),
    700: myPrimaryColor.withOpacity(0.8),
    800: myPrimaryColor.withOpacity(0.9),
    900: myPrimaryColor.withOpacity(1.0),
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context,child) {
        return MaterialApp(
            title: 'Chat App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: myPrimaryColorSwatch,
                primaryColor: myPrimaryColorSwatch,
                appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 1,
                iconTheme: IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.normal, fontSize: 19),
                backgroundColor: Colors.white,
            )),
            home: const SplashScreen());
      }
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');
  log('\nNotification Channel Result: $result');
}
