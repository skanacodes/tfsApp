// ignore_for_file: avoid_print, duplicate_ignore, prefer_typing_uninitialized_variables, library_private_types_in_public_api

import 'dart:ui';

//import 'package:tfsappv1/screens/dashboard/dashboardScreen.dart';

import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/screens/login/login.dart';
// import 'package:tfsappv1/screens/dashboard/size_confige.dart';
// import 'package:tfsappv1/screens/otp/otp.dart';

import 'package:tfsappv1/services/size_config.dart';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginWay extends StatefulWidget {
  static String routeName = "/loginway";

  const LoginWay({Key? key}) : super(key: key);
  @override
  _LoginWayState createState() => _LoginWayState();
}

class _LoginWayState extends State<LoginWay> {
  bool isaUser = false;
  bool isLoading = false;
  String? username;
  String? useremail;
  String? password;
  String auth = '';
  String? role;

  final List<String> errors = [];
  var roles = [];

  Future<void> createUser(String token, String username, String id, String name,
      String phoneNo, String type, String companyName) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString('token', token);
      prefs.setString("name", name);
      prefs.setString("id", id);
      prefs.setString("phoneNo", phoneNo);
      prefs.setString("type", type);
      prefs.setString("email", username);
      prefs.setString("companyName", companyName);
      setState(() {
        role = type;
      });
    });
  }

  void addError({required String error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({required String error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  String? emailLog;
  getEmail() async {
    var mail = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('email'));
    setState(() {
      emailLog = mail;
    });

    print(emailLog!);
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getEmail();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          body: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: size.height,
                  child: Stack(children: [
                    Container(
                      color: Colors.black,
                    ),
                    SizedBox(
                      height: size.height,
                      child: Image.asset(
                        'assets/images/nature.jpeg',
                        // #Image Url: https://unsplash.com/photos/bOBM8CB4ZC4
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    Center(
                      child: AnimationLimiter(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 675),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: widget,
                            ),
                          ),
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaY: 25,
                                    sigmaX: 25,
                                    tileMode: TileMode.mirror),
                                child: SizedBox(
                                  width: size.width * .9,
                                  height: getProportionateScreenHeight(450),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: size.width * .15,
                                        ),
                                        child: Text('TFSApp',
                                            style: GoogleFonts.portLligatSans(
                                                color: Colors.green,
                                                fontSize: 25.sp)),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              HapticFeedback.lightImpact();

                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LoginScreen(
                                                            email: emailLog,
                                                          )));
                                              await SharedPreferences
                                                      .getInstance()
                                                  .then((prefs) {
                                                prefs.setString(
                                                    'system', 'Fremis');
                                              });
                                            },
                                            child: Container(
                                              height:
                                                  getProportionateScreenHeight(
                                                      60),
                                              width: size.width / 1.25,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                'Fremis Sign In',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.sp,
                                                    fontFamily:
                                                        "ChicagoMakersPersonalUse"
                                                    // fontWeight: FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                getProportionateScreenHeight(
                                                    10),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              HapticFeedback.lightImpact();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LoginScreen(
                                                            email: emailLog,
                                                          )));
                                              await SharedPreferences
                                                      .getInstance()
                                                  .then((prefs) {
                                                prefs.setString(
                                                    'system', 'PMIS');
                                              });
                                            },
                                            child: Container(
                                              height:
                                                  getProportionateScreenHeight(
                                                      60),
                                              width: size.width / 1.25,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                'PMIS Sign In',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.sp,
                                                    fontFamily:
                                                        "ChicagoMakersPersonalUse"),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                getProportionateScreenHeight(
                                                    10),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              HapticFeedback.lightImpact();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LoginScreen(
                                                            email: emailLog,
                                                          )));
                                              await SharedPreferences
                                                      .getInstance()
                                                  .then((prefs) {
                                                prefs.setString('system',
                                                    'honeytraceability');
                                              });
                                            },
                                            child: Container(
                                              height:
                                                  getProportionateScreenHeight(
                                                      60),
                                              width: size.width / 1.25,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                'HoneyTraceability Sign In',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.sp,
                                                    fontFamily:
                                                        "ChicagoMakersPersonalUse"),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                getProportionateScreenHeight(
                                                    10),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              HapticFeedback.lightImpact();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LoginScreen(
                                                            email: emailLog,
                                                          )));
                                              await SharedPreferences
                                                      .getInstance()
                                                  .then((prefs) {
                                                prefs.setString(
                                                    'system', 'seedmis');
                                              });
                                            },
                                            child: Container(
                                              height:
                                                  getProportionateScreenHeight(
                                                      60),
                                              width: size.width / 1.25,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                'SeedMis Sign In',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.sp,
                                                    fontFamily:
                                                        "ChicagoMakersPersonalUse"),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: getProportionateScreenHeight(30),
                            ),
                          ],
                        ),
                      )),
                    ),
                  ]),
                ),
              ))),
    );
  }

  Widget component(
      IconData icon, String hintText, bool isPassword, bool isEmail) {
    Size size = MediaQuery.of(context).size;
    return Container(
      //height: size.width / 4,
      width: size.width / 1.25,
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: size.width / 30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        style: TextStyle(
          color: Colors.white.withOpacity(.9),
        ),
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          // focusedBorder: const UnderlineInputBorder(
          //   borderSide: BorderSide(color: Colors.black87),
          // ),
          // prefixIcon: Icon(
          //   icon,
          //   color: Colors.white.withOpacity(.8),
          // ),
          border: InputBorder.none,
          hintMaxLines: 1,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(.5),
          ),
        ),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}
