// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_typing_uninitialized_variables, avoid_//print, library_private_types_in_public_api, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/payments/ListPendingBills.dart';
import 'package:tfsappv1/screens/payments/billManagement.dart';
import 'package:tfsappv1/screens/payments/expiredBillsList.dart';
import 'package:tfsappv1/screens/payments/paymentList.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:sizer/sizer.dart';
import 'package:badges/badges.dart';

class BillsDashBoard extends StatefulWidget {
  static String routeName = "/billsDashboard";
  final String system;
  const BillsDashBoard(this.system);
  @override
  _BillsDashBoardState createState() => _BillsDashBoardState();
}

class _BillsDashBoardState extends State<BillsDashBoard> {
  late Map<String, double> dataMap;
  var seedToken;
  bool isLoading = false;
  var dataStats;

  Widget _title() {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
          text: widget.system == "honeytraceability"
              ? ' HoneyTraceability'
              : widget.system == "seedmis"
                  ? ' SeedMIS'
                  : widget.system == "HoneyTraceability"
                      ? "Honey-TraceAbility"
                      : widget.system == "E-Auction"
                          ? "E-Auction"
                          : widget.system == "PMIS"
                              ? "PMIS"
                              : "Fremis",
          style: GoogleFonts.portLligatSlab(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: ' Bills',
              style: TextStyle(color: Colors.green[400], fontSize: 15.sp),
            ),
            TextSpan(
              text: " Management",
              style: TextStyle(color: kPrimaryColor, fontSize: 15.sp),
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

  @override
  void initState() {
    widget.system == "seedmis"
        ? getDataSeed()
        : widget.system == "HoneyTraceability"
            ? getUserDetails()
            : widget.system == "E-Auction"
                ? ""
                : getStats();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // String username = arguments.username.toString();
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            '',
            style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
          ),
        ),
        // ignore: sized_box_for_whitespace
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
                            child: Icon(Icons.payment_outlined),
                          ),
                          title: _title(),
                          trailing: const Icon(
                            Icons.schedule,
                            color: Colors.pink,
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
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: AnimationLimiter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 1375),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                            child: widget,
                          ),
                        ),
                        children: <Widget>[
                          Container(
                              height: getProportionateScreenHeight(530),
                              color: Colors.transparent,
                              child: GridView.extent(
                                padding: const EdgeInsets.all(16),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                maxCrossAxisExtent: 200.0,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      // //print(widget.system);
                                      widget.system == "E-Auction" ||
                                              widget.system == "PMIS" ||
                                              widget.system ==
                                                  "honeytraceability"
                                          ? ""
                                          : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BillManagement(
                                                        widget.system ==
                                                                "seedmis"
                                                            ? "seedmis"
                                                            : widget.system ==
                                                                    "HoneyTraceability"
                                                                ? "HoneyTraceability"
                                                                : "Fremis",
                                                      ))).then((_) =>
                                              RealTimeCommunication()
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
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Badge(
                                                      badgeColor: kPrimaryColor,
                                                      animationType:
                                                          BadgeAnimationType
                                                              .scale,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      badgeContent: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
                                                          child: Text(
                                                            dataStats == null
                                                                ? "0"
                                                                : widget.system ==
                                                                        "Fremis"
                                                                    ? dataStats[
                                                                            "total_bills"]
                                                                        .toString()
                                                                    : dataStats[0]
                                                                            [
                                                                            "totalBillCreated"]
                                                                        .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                          )),
                                                      child: SvgPicture.asset(
                                                        "assets/icons/kyc.svg",
                                                        height: 6.h,
                                                        width: 6.w,
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            Text(
                                              "Create Bill",
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ListPendingBills(widget
                                                          .system ==
                                                      "honeytraceability"
                                                  ? "honeytraceability"
                                                  : widget.system == "seedmis"
                                                      ? "seedmis"
                                                      : widget.system ==
                                                              "HoneyTraceability"
                                                          ? "HoneyTraceability"
                                                          : widget.system ==
                                                                  "E-Auction"
                                                              ? "E-Auction"
                                                              : widget.system ==
                                                                      "PMIS"
                                                                  ? "PMIS"
                                                                  : "Fremis"))).then(
                                          (_) => RealTimeCommunication()
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
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Badge(
                                                      badgeColor: kPrimaryColor,
                                                      animationType:
                                                          BadgeAnimationType
                                                              .scale,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      badgeContent: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        child: Text(
                                                          dataStats == null
                                                              ? "0"
                                                              : widget.system ==
                                                                      "Fremis"
                                                                  ? dataStats[
                                                                          "unpaid_bills"]
                                                                      .toString()
                                                                  : dataStats[0]
                                                                          [
                                                                          "totalPending"]
                                                                      .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ),
                                                      child: SvgPicture.asset(
                                                        "assets/icons/pending.svg",
                                                        height: 6.h,
                                                        width: 6.w,
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            Text(
                                              "Pending Bill",
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PaymentList(widget
                                                          .system ==
                                                      "honeytraceability"
                                                  ? "honeytraceability"
                                                  : widget.system == "seedmis"
                                                      ? "seedmis"
                                                      : widget.system ==
                                                              "HoneyTraceability"
                                                          ? "HoneyTraceability"
                                                          : widget.system ==
                                                                  "E-Auction"
                                                              ? "E-Auction"
                                                              : widget.system ==
                                                                      "PMIS"
                                                                  ? "PMIS"
                                                                  : "Fremis"))).then(
                                          (_) => RealTimeCommunication()
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
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Badge(
                                                      badgeColor: kPrimaryColor,
                                                      animationType:
                                                          BadgeAnimationType
                                                              .scale,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      badgeContent: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        child: Text(
                                                          dataStats == null
                                                              ? "0"
                                                              : widget.system ==
                                                                      "Fremis"
                                                                  ? dataStats[
                                                                          "paid_bills"]
                                                                      .toString()
                                                                  : dataStats[0]
                                                                          [
                                                                          "totalPaid"]
                                                                      .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ),
                                                      child: SvgPicture.asset(
                                                        "assets/icons/history 1.svg",
                                                        height: 6.h,
                                                        width: 6.w,
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            Text(
                                              "Payment History",
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ExpiredBills(widget
                                                          .system ==
                                                      "honeytraceability"
                                                  ? "honeytraceability"
                                                  : widget.system == "seedmis"
                                                      ? "seedmis"
                                                      : widget.system ==
                                                              "HoneyTraceability"
                                                          ? "HoneyTraceability"
                                                          : widget.system ==
                                                                  "E-Auction"
                                                              ? "E-Auction"
                                                              : widget.system ==
                                                                      "PMIS"
                                                                  ? "PMIS"
                                                                  : "Fremis"))).then(
                                          (_) => RealTimeCommunication()
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
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Badge(
                                                      badgeColor: kPrimaryColor,
                                                      animationType:
                                                          BadgeAnimationType
                                                              .scale,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      badgeContent: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(1.0),
                                                        child: Text(
                                                          dataStats == null
                                                              ? "0"
                                                              : widget.system ==
                                                                      "Fremis"
                                                                  ? dataStats[
                                                                          "expired_bills"]
                                                                      .toString()
                                                                  : dataStats[0]
                                                                          [
                                                                          "totalExpired"]
                                                                      .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ),
                                                      child: SvgPicture.asset(
                                                        "assets/icons/expire.svg",
                                                        height: 6.h,
                                                        width: 6.w,
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            Text(
                                              "Expired Bills",
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
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
        ));
  }

  Future getDataSeed() async {
    setState(() {
      // isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      ////print(tokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrlSeed/api/v1/bill-statistics/30');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            dataStats = res['data'];
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            isLoading = false;
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        //print(e);
        //messages('Server Or Connectivity Error', 'error');
      });
    }
    // _refreshController.refreshCompleted();
  }

  Future getDataEauction() async {
    setState(() {
      // isLoading = true;
    });
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // //print(tokens);
      var url =
          Uri.parse('https://mis.tfs.go.tz/e-auction-v2/api/bill/GetPaidBills');
      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
      //print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            dataStats = res['data'];
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            isLoading = false;
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        //print(e);
        //messages('Server Or Connectivity Error', 'error');
      });
    }
    // _refreshController.refreshCompleted();
  }

  Future getStats() async {
    setState(() {
      // isLoading = true;
    });
    String stationId = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt('station_id').toString());

    //print(stationId);
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      //print(tokens);
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/bill-stats/$stationId');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //print(response.);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            dataStats = res['data'];
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            isLoading = false;
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        //print(e);
        //messages('Server Or Connectivity Error', 'error');
      });
    }
    // _refreshController.refreshCompleted();
  }

  Future<String> getUserDetails() async {
    try {
      setState(() {
        isLoading = true;
      });
      var url = Uri.parse(widget.system == "HoneyTraceability"
          ? "https://mis.tfs.go.tz/honey-traceability/api/v1/login"
          : '$baseUrlSeed/api/v1/login');
      String email = widget.system == "HoneyTraceability"
          ? 'onestpaul8@gmail.com'
          : 'admin@localhost';
      String password =
          widget.system == "HoneyTraceability" ? '12345678' : 'muyenjwa';
      //print(email);
      //print(password);
      final response = await http.post(
        url,
        body: {'email': email, 'password': password},
      );
      var res;
      //final sharedP prefs=await
      //print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            seedToken = res["token"];
          });
          await getDataSeed();
          return 'success';
          // ignore: dead_code
          break;
        case 403:
          setState(() {
            res = json.decode(response.body);
            //print(res);
          });
          return 'fail';
          // ignore: dead_code
          break;

        case 1200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            // addError(
            //     error:
            //         'Your Device Is Locked Please Contact User Support Team');
          });
          return 'fail';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            // addError(error: 'Something Went Wrong');
            // isLoading = false;
          });
          return 'fail';
          // ignore: dead_code
          break;
      }
    } catch (e) {
      setState(() {
        //print(e);

        // addError(error: 'Server Or Network Connectivity Error');
        // isLoading = false;
      });
      return 'fail';
    }
  }
}
