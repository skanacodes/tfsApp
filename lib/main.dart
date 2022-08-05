// ignore_for_file: unused_import, avoid_print, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/screens/login/login.dart';
import 'package:tfsappv1/services/constants.dart';

import 'package:tfsappv1/services/routes.dart';
import 'package:tfsappv1/services/theme.dart';
import 'package:tfsappv1/screens/splash/splashscreen.dart';
import 'package:workmanager/workmanager.dart';

const simplePeriodicTask = "simplePeriodicTask";
FlutterLocalNotificationsPlugin? flutterNotificationPlugin;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
    callbackDispatcher,
    // isInDebugMode: true,
  );

  Workmanager().registerPeriodicTask("3", simplePeriodicTask,
      initialDelay: const Duration(seconds: 120),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ));

  //needs to be initialized before using workmanager package

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _timer;
  bool forceLogout = false;
  String role = "";
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _initializeTimer();
  }

  void _initializeTimer() {
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _logOutUser());
  }

  void _logOutUser() {
    // Log out the user if they're logged in, then cancel the timer.
    // You'll have to make sure to cancel the timer if the user manually logs out
    //   and to call _initializeTimer once the user logs in
    _timer!.cancel();
    setState(() {
      forceLogout = false;
    });
  }

  // You'll probably want to wrap this function in a debounce
  void _handleUserInteraction([_]) {
    // print("_handleUserInteraction");
    _timer!.cancel();
    _initializeTimer();
  }

  void navToHomePage(BuildContext context) {
    navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // if (forceLogout) {
    //   print("ForceLogout is $forceLogout");
    //   navToHomePage(context);
    // }
    return Sizer(builder: (context, orientation, deviceType) {
      return GestureDetector(
        onTap: _handleUserInteraction,
        onPanDown: _handleUserInteraction,
        onScaleStart: _handleUserInteraction,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'TFSApp',
          theme: theme(),
          // home: SplashScreen(),
          // We use routeName so that we dont need to remember the name
          initialRoute: SplashScreen.routeName,
          routes: routes,
        ),
      );
    });
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    HttpOverrides.global = MyHttpOverrides();
    switch (task) {
      case simplePeriodicTask:
        final prefs = await SharedPreferences.getInstance();

        String? role1 = prefs.getString('role1').toString();
        print(role1);
        String? role2 = prefs.getString('role2').toString();
        print(role2);
        String? role3 = prefs.getString('role3').toString();
        print(role3);
        List roles = [role1, role2, role3];
        print(roles);
        print("Notify Begin");
        if (roles.contains("HQ Officer")) {
          var url = Uri.parse('$baseUrl/api/v1/exp_appr_req/notification');

          final response = await http.get(
            url,
          );

          var res;

          //final sharedP prefs=await
          // print(response.statusCode);
          // print(response.body);

          if (response.statusCode == 200) {
            res = json.decode(response.body);
            print(res);
            if (res["success"]) {
              List resp = res["data"];
              // print(res);
              var initializationSettingsAndroid =
                  const AndroidInitializationSettings('app_icon');

              var initializationSettings = InitializationSettings(
                android: initializationSettingsAndroid,
              );
              print("Notify Middle");
              flutterNotificationPlugin = FlutterLocalNotificationsPlugin();

              flutterNotificationPlugin!.initialize(
                initializationSettings,
              );

              for (var i = 0; i < resp.length; i++) {
                resp[i]["number"] > 0
                    ? await notificationDefaultSound(
                        index: i.toString(),
                        body:
                            'Request for ${resp[i]["type"]} Approval - ${resp[i]["number"]}',
                        title: resp[i]["number"].toString())
                    : null;
                print("Notify");
                Future.delayed(const Duration(milliseconds: 500), () {
                  print("Delay");
                });
              }
            } else {
              print("Notification Failed To Launch");
            }
          } else {
            print("API Failed To Launch");
          }
        } else if (roles.contains("ZM")) {
          String? zoneId = prefs.getString('zoneId').toString();
          var url = Uri.parse('$baseUrl/api/v1/tp/notification/$zoneId');

          final response = await http.get(
            url,
          );

          var res;

          //final sharedP prefs=await
          // print(response.statusCode);
          // print(response.body);

          if (response.statusCode == 200) {
            res = json.decode(response.body);
            print(res);
            if (res["success"]) {
              List resp = res["data"];
              // print(res);
              var initializationSettingsAndroid =
                  const AndroidInitializationSettings('app_icon');

              var initializationSettings = InitializationSettings(
                android: initializationSettingsAndroid,
              );
              print("Notify Middle");
              flutterNotificationPlugin = FlutterLocalNotificationsPlugin();

              flutterNotificationPlugin!.initialize(
                initializationSettings,
              );

              for (var i = 0; i < resp.length; i++) {
                resp[i]["number"] > 0
                    ? await notificationDefaultSound(
                        index: i.toString(),
                        body:
                            'Request for TP ${resp[i]["type"]} - ${resp[i]["number"]}',
                        title: "")
                    : null;
                print("Notify");
                Future.delayed(const Duration(milliseconds: 500), () {
                  print("Delay");
                });
              }
            } else {
              print("Notification Failed To Launch");
            }
          } else {
            print("API Failed To Launch");
          }
        } else {
          _determinePosition();
          final prefs = await SharedPreferences.getInstance();
          var on = prefs.getString("power_on").toString();
          var deviceId = prefs.getString("deviceId").toString();
          var lat = prefs.getString("latitude").toString();
          var long = prefs.getString("longitude").toString();

          var url = Uri.parse(
            'http://41.59.82.189:5555/api/v1/pos-management',
          );
          final response = await http.post(url, body: {
            "android_id": deviceId,
            "power_on": on,
            "last_seen": DateTime.now().toString(),
            "latitude": lat,
            "longitude": long
          });
          //final sharedP prefs=await
          print(response.statusCode);
          // print(response.body.toString());

          print("$simplePeriodicTask was executed");
          break;
        }

      //       String? role1 = SharedPreferences.getInstance()
      //           .then((prefs) => prefs.getString('role1'))
      //           .toString();
      //       String? role2 = SharedPreferences.getInstance()
      //           .then((prefs) => prefs.getString('role2'))
      //           .toString();
      //       String? role3 = SharedPreferences.getInstance()
      //           .then((prefs) => prefs.getString('role3'))
      //           .toString();
      //       List roles = [role1, role2, role3];
      //       if (roles.contains("HQ Officer")) {
      //         print("Notify Begin");
      //         var initializationSettingsAndroid =
      //             const AndroidInitializationSettings('app_icon');

      //         var initializationSettings = InitializationSettings(
      //           android: initializationSettingsAndroid,
      //         );
      //         print("Notify Middle");
      //         flutterNotificationPlugin = FlutterLocalNotificationsPlugin();

      //         flutterNotificationPlugin!.initialize(
      //           initializationSettings,
      //         );
      //         await notificationDefaultSound();
      //         print("Notify");
      //       } else {
      //         _determinePosition();
      //         final prefs = await SharedPreferences.getInstance();
      //         var on = prefs.getString("power_on").toString();
      //         var deviceId = prefs.getString("deviceId").toString();
      //         var lat = prefs.getString("latitude").toString();
      //         var long = prefs.getString("longitude").toString();

      //         var url = Uri.parse(
      //           'http://41.59.82.189:5555/api/v1/pos-management',
      //         );
      //         final response = await http.post(url, body: {
      //           "android_id": deviceId,
      //           "power_on": on,
      //           "last_seen": DateTime.now().toString(),
      //           "latitude": lat,
      //           "longitude": long
      //         });
      //         //final sharedP prefs=await
      //         print(response.statusCode);
      //         // print(response.body.toString());

      //         print("$simplePeriodicTask was executed");
      //         break;
      //       }
    }
    return Future.value(true);
  });
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  var x;
  try {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // print("sfnisfniwnfiewnf");
    // print("location");
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    x = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true);

    // print(x);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("latitude", x.latitude.toString());
    prefs.setString("longitude", x.longitude.toString());
    print(x);

    // Geolocator.getCurrentPosition(
    //         desiredAccuracy: LocationAccuracy.best,
    //         forceAndroidLocationManager: true)
    //     .then((Position position) {
    //   _currentPosition = position;
    //   print(_currentPosition);
    // }).catchError((e) {
    //  print(e);
    // });
  } catch (e) {
    print(e.toString());
  }
  return x;
}

Future notificationDefaultSound(
    {String? title, String? body, String? index}) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    index.toString(),
    'Channel Name',
    channelDescription: 'Description',
    importance: Importance.max,
    priority: Priority.high,
    enableVibration: true,
    playSound: true,
    groupKey: index,
    setAsGroupSummary: true,
    visibility: NotificationVisibility.public,
  );

  // var iOSPlatformChannelSpecifics = const IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  flutterNotificationPlugin!.show(
    int.parse(index.toString()),
    '$body',
    '',
    platformChannelSpecifics,
    payload: 'Default Sound',
  );
}
