// ignore_for_file: unused_import, file_names, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/screens/ExportImport/permitList.dart';
import 'package:tfsappv1/screens/Inventory/forestInventoryScreen.dart';
import 'package:tfsappv1/screens/NfrScreen/nfrScreen.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/dashboard/card_list.dart';
import 'package:tfsappv1/screens/dashboard/drawer.dart';
import 'package:tfsappv1/screens/dashboard/managementOperations.dart';
import 'package:tfsappv1/screens/dashboard/managementscreen.dart';
import 'package:tfsappv1/screens/illegalproduct/illegal_product_screen.dart';
import 'package:tfsappv1/screens/payments/billsDashboard.dart';

import 'package:tfsappv1/screens/payments/systemsList.dart';
import 'package:tfsappv1/screens/verification/verificationScreen.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

import 'package:sizer/sizer.dart';

import 'appBarItem.dart';

class DashboardScreen extends StatefulWidget {
  static String routeName = "/dashboard";

  const DashboardScreen({Key? key}) : super(key: key);
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? usernames;
  String? stationName;
  String? checkpoint;
  List roles = [];
  String? role1;
  String? role2;
  String? role3;
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
        leading: const CircleAvatar(
          backgroundColor: kPrimaryColor,
          child: Icon(
            Icons.file_present,
            color: Colors.black,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_outlined),
      ),
    );
  }

// This function will convert a valid input to a list
// In case the input is invalid, it will print out a message
  List? convert(String input) {
    List output;
    try {
      output = json.decode(input);
      return output;
    } catch (err) {
      print(err.toString());
      print('The input is not a string representation of a list');
      return null;
    }
  }

  Future getData() async {
    String? rol;
    var fname = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('fname'));
    var lname = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('lname'));
    stationName = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('StationName'));
    checkpoint = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('checkpointName'));

    role1 = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('role1'));
    role2 = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('role2'));
    role3 = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('role3'));
    setState(() {
      roles = [role1 ?? "", role2 ?? "", role3 ?? ""];
    });

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
          radius: const BorderRadius.all(Radius.circular(10)),
          child: const Text(
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
          radius: const BorderRadius.all(Radius.circular(10)),
          child: const Text(
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: kPrimaryColor,
            actions: [
              AppBarActionItems(
                checkpoint: checkpoint,
                roles: roles,
                username: usernames,
                station: stationName,
              )
            ],
          ),
          drawer: const CustomDrawer(),
          body: SingleChildScrollView(
            child: SizedBox(
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
                        decoration: const BoxDecoration(color: kPrimaryColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Card(
                            elevation: 10,
                            child: ListTile(
                              leading: const CircleAvatar(
                                foregroundColor: kPrimaryColor,
                                backgroundColor: Colors.black12,
                                child: Icon(Icons.verified_user_rounded),
                              ),
                              title: _title(),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Divider(
                                    color: Colors.purple,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Station: $stationName",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400),
                                      ),
                                      const Spacer()
                                    ],
                                  ),
                                  roles.contains("HQ Officer")
                                      ? Container()
                                      : checkpoint == "null"
                                          ? Container()
                                          : Row(
                                              children: [
                                                Text("CheckPoint: $checkpoint"),
                                                const Spacer()
                                              ],
                                            )
                                ],
                              ),
                              // trailing: Icon(
                              //   Icons.person,
                              //   color: Colors.black,
                              // ),
                              tileColor: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  // _divider(),
                  roles.contains("HQ Officer")
                      ? Column(
                          children: const [
                            ManagementOperation(),
                            ManagementScreen(),
                            CardList(),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: AnimationLimiter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    AnimationConfiguration.toStaggeredList(
                                  duration: const Duration(milliseconds: 1375),
                                  childAnimationBuilder: (widget) =>
                                      SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: widget,
                                    ),
                                  ),
                                  children: <Widget>[
                                    Container(
                                        height:
                                            getProportionateScreenHeight(514),
                                        color: Colors.transparent,
                                        child: GridView.extent(
                                          padding: const EdgeInsets.all(16),
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          maxCrossAxisExtent: 200.0,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {
                                                showModal();
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xfff3f3f4),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color: Colors.grey,
                                                            offset: Offset.zero,
                                                            blurRadius: 2)
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.payment_rounded,
                                                        size: 40.sp,
                                                        color: Colors.purple,
                                                      ),
                                                      Text(
                                                        "Bills And Payments",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  VerificationScreen.routeName,
                                                ).then((_) =>
                                                    RealTimeCommunication()
                                                        .createConnection("3"));
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xfff3f3f4),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color: Colors.grey,
                                                            offset: Offset.zero,
                                                            blurRadius: 2)
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.qr_code,
                                                        size: 40.sp,
                                                        color: Colors.green,
                                                      ),
                                                      Text(
                                                        "Verifications",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  IllegalProductScreen
                                                      .routeName,
                                                ).then((_) =>
                                                    RealTimeCommunication()
                                                        .createConnection("3"));
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xfff3f3f4),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color: Colors.grey,
                                                            offset: Offset.zero,
                                                            blurRadius: 3)
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .do_not_disturb_alt_sharp,
                                                        color: Colors.cyan,
                                                        size: 40.sp,
                                                      ),
                                                      Text(
                                                        "Illegal Product",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  NFRScreen.routeName,
                                                ).then((_) =>
                                                    RealTimeCommunication()
                                                        .createConnection("3"));
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xfff3f3f4),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color: Colors.grey,
                                                            offset: Offset.zero,
                                                            blurRadius: 2)
                                                      ],
                                                      // border:
                                                      //     Border.all(color: Colors.grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .animation_outlined,
                                                        size: 40.sp,
                                                        color: Colors.pink,
                                                      ),
                                                      Text(
                                                        " Tourism",
                                                        style: TextStyle(
                                                            fontSize: 10.sp,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  PermittList.routeName,
                                                ).then((_) =>
                                                    RealTimeCommunication()
                                                        .createConnection("3"));
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xfff3f3f4),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color: Colors.grey,
                                                            offset: Offset.zero,
                                                            blurRadius: 3)
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .import_export_outlined,
                                                        color: Colors.brown,
                                                        size: 40.sp,
                                                      ),
                                                      Center(
                                                        child: Text(
                                                          "Export & Import",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 10.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                // Navigator.pushNamed(
                                                //   context,
                                                //   ForestInventoryScreen.routeName,
                                                // ).then((_) => RealTimeCommunication()
                                                //     .createConnection("3"));
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xfff3f3f4),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                            color: Colors.grey,
                                                            offset: Offset.zero,
                                                            blurRadius: 2)
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.nature_outlined,
                                                        color: kPrimaryColor,
                                                        size: 40.sp,
                                                      ),
                                                      Text(
                                                        "Mensuration",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ],
                                                  )),
                                            ),
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
            ),
          )),
    );
  }

  popBar(String email) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: PopupMenuButton(
        tooltip: 'Menu',
        child: const Icon(
          Icons.more_vert,
          size: 28.0,
          color: Colors.black,
        ),
        offset: const Offset(20, 40),
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
                  padding: const EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    email.toString(),
                    style: const TextStyle(
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
                  padding: const EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    stationName.toString(),
                    style: const TextStyle(
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

  showModal() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: Icon(
                  Icons.select_all_outlined,
                  color: Colors.green,
                ),
                title: Text(
                  "Select System",
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                title: const Text("FreMIS Bills"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const BillsDashBoard("Fremis"))).then(
                      (_) => RealTimeCommunication().createConnection("3"));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                title: const Text("SeedMIS Bills"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const BillsDashBoard("seedMIS"))).then(
                      (_) => RealTimeCommunication().createConnection("3"));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                title: const Text('HoneyTraceability Bills'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const BillsDashBoard("HoneyTraceability"))).then(
                      (_) => RealTimeCommunication().createConnection("3"));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                title: const Text('E-Auction Bills'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const BillsDashBoard("E-Auction"))).then(
                      (_) => RealTimeCommunication().createConnection("3"));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                title: const Text('PMIS Bills'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigator.pushNamed(
                  //   context,
                  //   TPEditing.routeName,
                  // ).then((_) => RealTimeCommunication().createConnection("1"));
                },
              ),
            ],
          );
        });
  }
}
