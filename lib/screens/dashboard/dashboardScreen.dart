import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/screens/ExportImport/permitList.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/dashboard/drawer.dart';
import 'package:tfsappv1/screens/payments/paymentList.dart';
import 'package:tfsappv1/screens/verification/verificationScreen.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

import 'package:sizer/sizer.dart';

class DashboardScreen extends StatefulWidget {
  static String routeName = "/dashboard";
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? usernames;
  String? stationName;
  var userId;
  var devId;
  late Map<String, double> dataMap;

  Widget _title() {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
          text: 'Welcome: ',
          style: GoogleFonts.portLligatSlab(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: ' $usernames',
              style: TextStyle(color: Colors.green[400], fontSize: 15.sp),
            ),
          ]),
    );
  }

  Widget list(String title, String subtitle) {
    return Card(
      elevation: 10,
      shadowColor: kPrimaryColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kPrimaryColor,
          child: Icon(
            Icons.file_present,
            color: Colors.black,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios_outlined),
      ),
    );
  }

  Future getData() async {
    var fname = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('fname'));
    var lname = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('lname'));
    stationName = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('StationName'));
    setState(() {
      usernames = "$fname  $lname";
    });
  }

  @override
  void initState() {
    RealTimeCommunication().createConnection("3", androidId: devId, id: userId);
    getData();

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  message(String hint, String message) {
    return Alert(
      context: context,
      type: hint == "info" ? AlertType.info : AlertType.success,
      title: "",
      desc: message,
      buttons: [
        DialogButton(
          color: Colors.red,
          radius: BorderRadius.all(Radius.circular(10)),
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            await RealTimeCommunication().createConnection('2');
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/login', (Route<dynamic> route) => false);
          },
          width: 120,
        ),
        DialogButton(
          color: Colors.green,
          radius: BorderRadius.all(Radius.circular(10)),
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
          width: 120,
        )
      ],
    ).show();
  }

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    message("info", "Are You Sure You Want To Exit");
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    // String username = arguments.username.toString();
    final height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: kPrimaryColor,
            title: Text(
              '',
              style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
            ),
          ),
          drawer: CustomDrawer(),
          body: Container(
            height: height,
            child: Column(
              children: <Widget>[
                Stack(
                  children: [
                    Container(
                      height: getProportionateScreenHeight(70),
                      color: Colors.white,
                      // decoration: BoxDecoration(color: Colors.white),
                    ),
                    Container(
                      height: getProportionateScreenHeight(50),
                      decoration: BoxDecoration(color: kPrimaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Card(
                          elevation: 10,
                          child: ListTile(
                            leading: CircleAvatar(
                              foregroundColor: kPrimaryColor,
                              backgroundColor: Colors.black12,
                              child: Icon(Icons.verified_user_rounded),
                            ),
                            title: _title(),
                            trailing: Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                            tileColor: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                // _divider(),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: AnimationLimiter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 1375),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: ScaleAnimation(
                              child: widget,
                            ),
                          ),
                          children: <Widget>[
                            Container(
                                height: getProportionateScreenHeight(530),
                                child: GridView.extent(
                                  padding: const EdgeInsets.all(16),
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  maxCrossAxisExtent: 200.0,
                                  children: <Widget>[
                                    Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xfff3f3f4),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset.zero,
                                                  blurRadius: 2)
                                            ],
                                            // border:
                                            //     Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.grading_sharp,
                                              size: 40.sp,
                                              color: Colors.pink,
                                            ),
                                            Text(
                                              "DashBoard",
                                              style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        )),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          PaymentList.routeName,
                                        ).then((_) => RealTimeCommunication()
                                            .createConnection("3"));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xfff3f3f4),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset.zero,
                                                    blurRadius: 2)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.payment_rounded,
                                                size: 40.sp,
                                                color: Colors.purple,
                                              ),
                                              Text(
                                                "Payments",
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 10.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          VerificationScreen.routeName,
                                        ).then((_) => RealTimeCommunication()
                                            .createConnection("3"));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xfff3f3f4),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset.zero,
                                                    blurRadius: 2)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.qr_code,
                                                size: 40.sp,
                                                color: Colors.green,
                                              ),
                                              Text(
                                                "Verifications",
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 10.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          )),
                                    ),
                                    Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xfff3f3f4),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset.zero,
                                                  blurRadius: 3)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.history_rounded,
                                              color: Colors.cyan,
                                              size: 40.sp,
                                            ),
                                            Text(
                                              "Payment History",
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        )),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          PermittList.routeName,
                                        ).then((_) => RealTimeCommunication()
                                            .createConnection("3"));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xfff3f3f4),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset.zero,
                                                    blurRadius: 3)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.import_export_outlined,
                                                color: Colors.brown,
                                                size: 40.sp,
                                              ),
                                              Center(
                                                child: Text(
                                                  "Export & Import",
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            ],
                                          )),
                                    ),
                                    Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xfff3f3f4),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  offset: Offset.zero,
                                                  blurRadius: 2)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.receipt,
                                              color: Colors.blue,
                                              size: 40.sp,
                                            ),
                                            Text(
                                              "TP",
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        )),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  popBar(String email) {
    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: PopupMenuButton(
        tooltip: 'Menu',
        child: Icon(
          Icons.more_vert,
          size: 28.0,
          color: Colors.black,
        ),
        offset: Offset(20, 40),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.supervised_user_circle_rounded,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    email.toString(),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    stationName.toString(),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
