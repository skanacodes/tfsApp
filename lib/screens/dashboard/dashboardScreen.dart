// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/screens/ExportImport/permitList.dart';
import 'package:tfsappv1/screens/Inventory/forestInventoryScreen.dart';
import 'package:tfsappv1/screens/NfrScreen/nfrScreen.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/dashboard/drawer.dart';
import 'package:tfsappv1/screens/dashboard/managementOperations.dart';
import 'package:tfsappv1/screens/loginway.dart/loginway.dart';
import 'package:tfsappv1/screens/payments/billsDashboard.dart';

import 'package:tfsappv1/screens/verification/verificationScreen.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

import 'package:sizer/sizer.dart';

import 'appBarItem.dart';

class DashboardScreen extends StatefulWidget {
  static String routeName = "/dashboard";

  const DashboardScreen({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? usernames;
  String? stationName;
  String? checkpoint;
  String? sys;
  List roles = [];
  List dataFremis = [];
  List dataExport = [];
  List dataDealers = [];
  List dataSeed = [];
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
          style: TextStyle(
              fontFamily: "Port Lligat Slab",
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor),
          children: [
            TextSpan(
              text: ' $usernames',
              style: TextStyle(
                color: Colors.green[400],
                fontSize: 10.sp,
              ),
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
      return null;
    }
  }

  Future getData() async {
    var fname = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('fname'));
    var lname = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('lname'));
    stationName = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('StationName'));
    checkpoint = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('checkpointName'));
    sys = await SharedPreferences.getInstance()
        .then((value) => value.getString("system"));
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
          onPressed: () async {
            Navigator.of(context).pushNamedAndRemoveUntil(
              LoginWay.routeName,
              (Route<dynamic> route) => false,
            );
            await RealTimeCommunication().createConnection('2');
          },
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          color: Colors.green,
          radius: const BorderRadius.all(Radius.circular(10)),
          onPressed: () async {
            Navigator.pop(context);
          },
          width: 120,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
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
                              leading: SizedBox(
                                  // height: double.maxFinite,
                                  width: getProportionateScreenHeight(50),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey[200],
                                    child: Image.asset(
                                        "${filepathImages}user.png"),
                                  )),
                              title: _title(),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Divider(
                                    color: Colors.purple,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: roles.contains("HQ Officer")
                                            ? const Text(
                                                "Station: Conservation Commissioner",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w400),
                                              )
                                            : Text(
                                                "Station: $stationName",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
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
                                                Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                        "CheckPoint: $checkpoint")),
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
                      ? SizedBox(
                          height: getProportionateScreenHeight(600),
                          child: ListView(
                            children: const [
                              ManagementOperation(),
                            ],
                          ),
                        )
                      // ManagementScreen(),
                      //CardList(),

                      : Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                            height: height - 180,
                            // width: 400,
                            color: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: AnimationLimiter(
                              child: GridView.count(
                                padding: const EdgeInsets.all(16),
                                crossAxisSpacing: 10,
                                childAspectRatio: 4 / 3,

                                ///shrinkWrap: true,
                                mainAxisSpacing: 10,

                                crossAxisCount: 2,
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
                                    InkWell(
                                      onTap: () {
                                        if (sys == "PMIS") {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BillsDashBoard(
                                                          "PMIS"))).then((_) =>
                                              RealTimeCommunication()
                                                  .createConnection("3"));
                                        } else if (sys == "seedmis") {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BillsDashBoard(
                                                          "seedmis"))).then(
                                              (_) => RealTimeCommunication()
                                                  .createConnection("3"));
                                        } else if (sys == "Fremis") {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BillsDashBoard(
                                                          "Fremis"))).then(
                                              (_) => RealTimeCommunication()
                                                  .createConnection("3"));
                                        } else if (sys == "honeytraceability") {
                                          Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const BillsDashBoard(
                                                              "honeytraceability")))
                                              .then((_) =>
                                                  RealTimeCommunication()
                                                      .createConnection("3"));
                                        } else {
                                          showModal();
                                        }
                                      },
                                      child: Container(
                                          // height:
                                          //     getProportionateScreenHeight(100),
                                          decoration: BoxDecoration(
                                              color: const Color(0xfff3f3f4),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset.zero,
                                                    blurRadius: 2)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  // height: double.maxFinite,
                                                  width:
                                                      getProportionateScreenHeight(
                                                          50),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    child: Image.asset(
                                                        "${filepathImages}billing.png"),
                                                  )),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: Text(
                                                    "Bills And Payments",
                                                    style: TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 9.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
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
                                              color: const Color(0xfff3f3f4),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset.zero,
                                                    blurRadius: 2)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  // height: double.maxFinite,
                                                  width:
                                                      getProportionateScreenHeight(
                                                          50),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    child: Image.asset(
                                                        "${filepathImages}verify.png"),
                                                  )),
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Verifications",
                                                    style: TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 9.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // Navigator.pushNamed(
                                        //   context,
                                        //   IllegalProductScreen
                                        //       .routeName,
                                        // ).then((_) =>
                                        //     RealTimeCommunication()
                                        //         .createConnection("3"));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: const Color(0xfff3f3f4),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset.zero,
                                                    blurRadius: 3)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  // height: double.maxFinite,
                                                  width:
                                                      getProportionateScreenHeight(
                                                          50),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    child: Image.asset(
                                                        "${filepathImages}forbiden.png"),
                                                  )),
                                              Text(
                                                "Illegal Product",
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 9.sp,
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
                                          NFRScreen.routeName,
                                        ).then((_) => RealTimeCommunication()
                                            .createConnection("3"));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: const Color(0xfff3f3f4),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset.zero,
                                                    blurRadius: 2)
                                              ],
                                              // border:
                                              //     Border.all(color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  // height: double.maxFinite,
                                                  width:
                                                      getProportionateScreenHeight(
                                                          40),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    child: Image.asset(
                                                        "${filepathImages}tourism.png"),
                                                  )),
                                              Text(
                                                " Tourism",
                                                style: TextStyle(
                                                    fontSize: 9.sp,
                                                    color: Colors.black87,
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
                                          PermittList.routeName,
                                        ).then((_) => RealTimeCommunication()
                                            .createConnection("3"));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: const Color(0xfff3f3f4),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset.zero,
                                                    blurRadius: 3)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  // height: double.maxFinite,
                                                  width:
                                                      getProportionateScreenHeight(
                                                          50),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    child: Image.asset(
                                                        "${filepathImages}export.png"),
                                                  )),
                                              Center(
                                                child: Text(
                                                  "Export & Import",
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 9.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            ],
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          ForestInventoryScreen.routeName,
                                        ).then((_) => RealTimeCommunication()
                                            .createConnection("3"));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: const Color(0xfff3f3f4),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset.zero,
                                                    blurRadius: 2)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  // height: double.maxFinite,
                                                  width:
                                                      getProportionateScreenHeight(
                                                          50),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    child: Image.asset(
                                                        "${filepathImages}location.png"),
                                                  )),
                                              Text(
                                                "Tallying",
                                                style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 9.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          )),
                                    ),
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
        child: const Icon(
          Icons.more_vert,
          size: 28.0,
          color: Colors.black,
        ),
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
