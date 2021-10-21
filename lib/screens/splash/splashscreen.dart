import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
//import 'package:tfsappv1/screens/login/login.dart';
import 'package:tfsappv1/screens/login/login.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();

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
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
      // SharedPreferences.getInstance().then((prefs) {
      //   print(prefs.get('id').toString());
      //   if (prefs.get('id').toString() != 'null') {
      //     // Navigator.push(context,
      //     //     MaterialPageRoute(builder: (context) => InventoryListScreen()));
      //   } else {
      //     Navigator.push(
      //         context, MaterialPageRoute(builder: (context) => LoginScreen()));
      //   }
      // });
    });
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
