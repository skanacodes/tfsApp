// ignore_for_file: file_names, avoid_print, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:tfsappv1/screens/payments/fremisBills.dart';
import 'package:tfsappv1/screens/payments/honeyTraceability.dart';
import 'package:tfsappv1/screens/payments/seed.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class BillManagement extends StatefulWidget {
  static String routeName = "/billManagement";
  final String? token;
  final String system;
  const BillManagement(this.system, {Key? key, this.token}) : super(key: key);

  @override
  _BillManagementState createState() => _BillManagementState();
}

class _BillManagementState extends State<BillManagement> {
  String? seedToken;

  Future<String> getUserDetails() async {
    try {
      var url = Uri.parse(widget.system == "HoneyTraceability"
          ? "https://mis.tfs.go.tz/honey-traceability/api/v1/login"
          : '$baseUrlSeed/api/v1/login');
      String email = widget.system == "HoneyTraceability"
          ? 'onestpaul8@gmail.com'
          : 'admin@localhost';
      String password =
          widget.system == "HoneyTraceability" ? '12345678' : 'muyenjwa';
      print(email);
      print(password);
      final response = await http.post(
        url,
        body: {'email': email, 'password': password},
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            seedToken = res["token"];
          });

          return 'success';
          // ignore: dead_code
          break;
        case 403:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          return 'fail';
          // ignore: dead_code
          break;

        case 1200:
          setState(() {
            res = json.decode(response.body);
            print(res);
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
            print(res);
            // addError(error: 'Something Went Wrong');
            // isLoading = false;
          });
          return 'fail';
          // ignore: dead_code
          break;
      }
    } catch (e) {
      setState(() {
        print(e);

        // addError(error: 'Server Or Network Connectivity Error');
        // isLoading = false;
      });
      return 'fail';
    }
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    // _handleRadioValueChange(0);
    getUserDetails();
    super.initState();
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
          text: widget.system == "seedMIS"
              ? ' SeedMIS'
              : widget.system == "HoneyTraceability"
                  ? "Honey-Traceability"
                  : " FreMIS",
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
              text: " Form",
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
  Widget build(BuildContext context) {
    // String username = arguments.username.toString();
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            '',
            style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
          ),
        ),
        body: SizedBox(
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
                            child: Icon(Icons.format_align_center),
                          ),
                          title: _title(),
                          trailing: const Icon(
                            Icons.api,
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
                          seedToken == null
                              ? SpinKitFadingCircle(
                                  color: kPrimaryColor,
                                  size: 35.0.sp,
                                )
                              : Container(
                                  height: getProportionateScreenHeight(550),
                                  color: Colors.transparent,
                                  child: widget.system == "HoneyTraceability"
                                      ? HoneyTraceAbility(seedToken!)
                                      : widget.system == "Fremis"
                                          ? FremisBills()
                                          : Seeds(
                                              seedToken!,
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
}
