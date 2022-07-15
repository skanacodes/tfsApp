// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/dashboard/dashboardScreen.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:sizer/sizer.dart';

class Otp extends StatefulWidget {
  static String routeName = "/OTP";

  const Otp({Key? key}) : super(key: key);
  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  String? code1;
  String? code2;
  String? code3;
  String? code4;
  bool isLoading = false;

  String? codeVerify;

  Future getOTP() async {
    setState(() {
      isLoading = true;
    });
    try {
      var phone = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('phoneNumber'));
      final codes = OTP.generateTOTPCodeString(
          'JBSWY3DPEHPK3PXP', DateTime.now().millisecondsSinceEpoch,
          length: 4);

      var url = Uri.parse(
          'https://mis.tfs.go.tz/messaging/api/SMSMessaging/SendSMSCustom');

      final response = await http.post(url,
          body: jsonEncode(
            {
              "Message": "#TFS code: $codes",
              "Phones": [
                {"name": "$phone"}
              ],
            },
          ),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
          });
      //final sharedP prefs=await
      // print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          //  print("Sms sent");
          setState(() {
            codeVerify = codes;
          });
          break;

        case 401:
          setState(() {
            message("error", "Something Went Wrong");
          });
          break;
        default:
          setState(() {
            message("error", "Something Went Wrong");
          });
          break;
      }
    } on SocketException {
      setState(() {
        message("error", "Something Went Wrong");
        // print(res);
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  message(String hint, String message) {
    return Alert(
      context: context,
      type: hint == "error" ? AlertType.error : AlertType.success,
      title: "Information",
      desc: message,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  @override
  void initState() {
    RealTimeCommunication().createConnection('13');
    getOTP();
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset: false,
      body: isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: kPrimaryColor,
                size: 35.0.sp,
              ),
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 25,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(10),
                      ),
                      Container(
                        width: getProportionateScreenHeight(150),
                        height: getProportionateScreenHeight(150),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/otp.png',
                        ),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(10),
                      ),
                      Text(
                        'Verification',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(10),
                      ),
                      const Text(
                        "Enter your OTP code number",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(10),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _textFieldOTP(
                                    first: true, last: false, code: "1"),
                                const Spacer(),
                                _textFieldOTP(
                                    first: false, last: false, code: "2"),
                                const Spacer(),
                                _textFieldOTP(
                                    first: false, last: false, code: "3"),
                                const Spacer(),
                                _textFieldOTP(
                                    first: false, last: true, code: "4"),
                              ],
                            ),
                            SizedBox(
                              height: getProportionateScreenHeight(10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      const Text(
                        "Didn't you receive any code?",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      InkWell(
                        onTap: () async {
                          await getOTP();
                        },
                        child: Text(
                          "Resend New Code",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  setValues(code, value) {
    setState(() {
      if (code == '1') {
        code1 = value;
      } else if (code == '2') {
        code2 = value;
      } else if (code == '3') {
        code3 = value;
      } else if (code == '4') {
        code4 = value;
      }
    });
  }

  Widget _textFieldOTP({bool? first, last, String? code}) {
    return Expanded(
      child: SizedBox(
        height: getProportionateScreenHeight(60),
        child: TextField(
          autofocus: true,
          onChanged: (value) {
            setState(() {
              setValues(code, value);
            });
            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.isEmpty && first == false) {
              // print(value);
              FocusScope.of(context).previousFocus();
            }
            if (value.length == 1 && last == true) {
              var ver = code1.toString() +
                  code2.toString() +
                  code3.toString() +
                  code4.toString();
              //  print(ver);
              if (codeVerify == ver) {
                FocusScope.of(context).unfocus();
                Future.delayed(const Duration(seconds: 1), () {});
                Navigator.pushNamed(
                  context,
                  DashboardScreen.routeName,
                );
              } else {
                message("error", "Please Enter Correct Code");
              }
            }
          },
          showCursor: true,
          readOnly: false,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
            counter: const Offstage(),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 2, color: Colors.black12),
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: 2, color: kPrimaryColor),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
