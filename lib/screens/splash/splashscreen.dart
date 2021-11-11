import 'dart:async';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:system_clock/system_clock.dart';
//import 'package:tfsappv1/screens/login/login.dart';
import 'package:tfsappv1/screens/login/login.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  void initState() {
    super.initState();
    // _determinePosition();
    Timer(Duration(seconds: 5), () async {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.camera,
        Permission.storage,
        Permission.photos,
        Permission.accessMediaLocation,

        Permission.manageExternalStorage
        //add more permission to request here.
      ].request();

      if (statuses[Permission.location]!.isDenied) {
        //check each permission status after.
        print("Location permission is denied.");
      }

      if (statuses[Permission.camera]!.isDenied) {
        //check each permission status after.
        print("Camera permission is denied.");
      }
      _determinePosition();
      initPlatformState();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    final prefs = await SharedPreferences.getInstance();
    final bootSinceEpoch = DateTime.now().microsecondsSinceEpoch -
        SystemClock.uptime().inMicroseconds;
    print(DateTime.fromMicrosecondsSinceEpoch(bootSinceEpoch));
    var formattedDate = DateTime.fromMicrosecondsSinceEpoch(bootSinceEpoch);

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;

      prefs.setString("deviceId", _deviceData['androidId'].toString());
      prefs.setString("brand", _deviceData['brand'].toString());
      prefs.setBool("timer", true);

      prefs.setString("power_on", formattedDate.toString());
    });
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
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

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    var x = await Geolocator.getCurrentPosition();
    print("ks");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("latitude", x.latitude.toString());
    prefs.setString("longitude", x.longitude.toString());

    return x;
  }

  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen
    SizeConfig().init(context);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20.0.h,
          ),
          SizedBox(
            width: double.infinity,
            child: TextLiquidFill(
              text: 'TFSApp',
              waveColor: Colors.black,
              boxBackgroundColor: Colors.white,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                fontSize: 30.0,
                //fontFamily: 'Pacifico',
                fontWeight: FontWeight.bold,
              ),
              boxHeight: 150.0,
            ),
          ),
          //_deviceData['id'].toString()
          Container(
            height: 25.0.h,
            width: 40.0.w,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 10.0.h,
          ),
          SpinKitFadingCircle(
            color: kPrimaryColor,
            size: 35.0.sp,
          )
        ],
      ),
    );
  }
}
