// ignore_for_file: unused_import, prefer_typing_uninitialized_variables, avoid_////print(, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';

//import 'package:tfsappv1/screens/dashboard/dashboardScreen.dart';

import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/dashboard/dashboardScreen.dart';

import 'package:tfsappv1/screens/login/Widget/bezierContainer.dart';
import 'package:tfsappv1/screens/otp/otp.dart';

import 'package:tfsappv1/services/size_config.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:tfsappv1/services/form_error.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/login";
  final String? email;
  const LoginScreen({Key? key, this.email}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isaUser = false;
  bool isLoading = false;
  String? username;
  String? useremail;
  String? password;
  String auth = '';
  var userId;
  var devId;
  final List<String> errors = [];
  var roles = [];
  String role1 = "";
  String role2 = "";
  String role3 = "";

  Future<void> createUser(
      String token,
      int userId,
      int stationId,
      String checkpointId,
      String fname,
      String lname,
      String email,
      String phoneNumber,
      String stationName,
      String checkpointName,
      String role1,
      String role2,
      String role3,
      {String? userID,
      String? checkpoindCode,
      String? zoneId}) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('user_id', userId);
      prefs.setString('token', token);
      prefs.setInt('station_id', stationId);
      prefs.setString('StationName', stationName);
      prefs.setString('fname', fname);
      prefs.setString('lname', lname == "null" ? "" : lname);
      prefs.setString('email', email);
      prefs.setString('phoneNumber', phoneNumber);
      prefs.setString('checkpointId', checkpointId);
      prefs.setString('checkpointName', checkpointName);
      prefs.setString("role1", role1);
      prefs.setString("role2", role2);
      prefs.setString("role3", role3);
      prefs.setString("userID", userID.toString());
      prefs.setString("checkpointcode", checkpoindCode.toString());
      prefs.setString("zoneId", zoneId.toString());
    });
  }

  Future<String> getUserDetails() async {
    try {
      String? sys = await SharedPreferences.getInstance()
          .then((value) => value.getString("system"));

      var url;
      sys == "Fremis"
          ? url = Uri.parse('$baseUrlTest/api/v1/login')
          : sys == "seedmis"
              ? url = Uri.parse('$baseUrlSeed/api/v1/login')
              : sys == "honeytraceability"
                  ? url =
                      Uri.parse('$baseUrlHoneyTraceability/api/v1/pos/login')
                  : url = Uri.parse('$baseUrlPMIS/api/LoginMobile/Login');
      var body;

      if (sys == "Fremis") {
        setState(() {
          body = {
            'email': username,
            'password': password,
            'android_id': devId!
          };
        });
      } else if (sys == "seedmis") {
        body = {
          'email': username,
          'password': password,
        };
      } else if (sys == "honeytraceability") {
        body = {
          'email': username,
          'password': password,
        };
      } else {
        setState(() {
          body = {"UserName": username, "Password": password};
        });
      }
      //////print((body);
      //////print((url);
      final response = await http.post(url, body: json.encode(body), headers: {
        "Accept": "application/json",
        "content-type": "application/json"
      });
      var res;

      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            // //////print((res);
          });
          if (sys == "seedmis") {
            //////print((sys);
            await createUser(
                res['access_token'],
                res['user']['id'],
                res['user']['station_id'],
                "",
                res['user']['first_name'].toString(),
                res['user']['last_name'].toString(),
                res['user']['email'].toString(),
                res['user']['phone'].toString(),
                res['user']["station"]["name"].toString(),
                "",
                "",
                "",
                "");
            return 'success';
          }
          if (sys == "honeytraceability") {
            //////print(("traceability");
            await createUser(
                res['access_token'],
                res['user']['user_id'],
                res['user']['station_id'],
                "",
                res['user']['first_name'].toString(),
                res['user']['last_name'].toString(),
                res['user']['email'].toString(),
                res['user']['phone'].toString(),
                res['user']["station"].toString(),
                "",
                "",
                "",
                "");
            return 'success';
          }
          if (sys == "Fremis") {
            for (var i = 0; i < res["roles"].length; i++) {
              if (i == 0) {
                role1 = res["roles"][i]["name"].toString();
              }
              if (i == 1) {
                role2 = res["roles"][i]["name"].toString();
              }
              if (i == 2) {
                role3 = res["roles"][i]["name"].toString();
              }
            }

            await createUser(
              res['access_token'],
              res['user']['user_id'],
              res['user']['station_id'],
              res['user']['checkpoint_id'].toString(),
              res['user']['first_name'],
              res['user']['last_name'],
              res['user']['email'].toString(),
              res['user']['phone'].toString(),
              res['user']['station'].toString(),
              res['user']['checkpoint_name'].toString(),
              role1.toString(),
              role2.toString(),
              role3.toString(),
              checkpoindCode: res['user']['checkpoint_code'].toString(),
              zoneId: res['user']['zone_id'].toString(),
            );
            return 'success';
          }
          if (sys == "PMIS") {
            if (res["Result"]["access_token"] == null) {
              addError(error: 'Incorrect Password or Email');
            }
            if (res["Result"]["access_token"] != null) {
              // //////print((res["Result"]['user']["access_token"].toString());
              await createUser(
                  res["Result"]["access_token"].toString(),
                  0,
                  int.parse(res["Result"]['user']['station_id']),
                  "",
                  res["Result"]['user']['first_name'].toString(),
                  res["Result"]['user']['last_name'].toString(),
                  res["Result"]['user']['email'].toString(),
                  res["Result"]['user']['phone'].toString(),
                  res["Result"]['user']['station'].toString(),
                  "",
                  "",
                  "",
                  "",
                  userID: res["Result"]['user']['user_id']);
              return 'success';
            }
          }
          return "";
          // ignore: dead_code
          break;
        case 401:
          setState(() {
            res = json.decode(response.body);
            ////////print((res);
            if (res["error"] == "INVALID_LOGIN") {
              addError(error: 'Incorrect Password or Email');
            }
          });
          return 'fail';
          // ignore: dead_code
          break;
        case 403:
          setState(() {
            res = json.decode(response.body);
            // //////print((res);
            if (res['message'] == 'Invalid Credentials') {
              addError(error: 'Incorrect Password or Email');
            } else if (res['message'] ==
                'Your Device Is Locked Please Contact User Support Team') {
              addError(
                  error:
                      'Your Device Is Locked Please Contact User Support Team');
            }

            isLoading = false;
          });
          return 'fail';
          // ignore: dead_code
          break;

        case 1200:
          setState(() {
            res = json.decode(response.body);
            // //////print((res);
            addError(
                error:
                    'Your Device Is Locked Please Contact User Support Team');
          });
          return 'fail';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);

            addError(error: 'Something Went Wrong');
            isLoading = false;
          });
          return 'fail';
          // ignore: dead_code
          break;
      }
    } catch (e) {
      setState(() {
        // //////print((e);

        addError(error: 'Server Or Network Connectivity Error');
        isLoading = false;
      });
      return 'fail';
    }
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

  Widget _entryField(String title, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextFormField(
                initialValue: !isPassword
                    ? widget.email.toString() == "null"
                        ? ""
                        : widget.email.toString()
                    : "",
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    errors.contains('Network Problem')
                        ? removeError(
                            error: 'Server Or Network Connectivity Error')
                        : errors.contains('Incorrect Password or Email')
                            ? removeError(error: 'Incorrect Password or Email')
                            : removeError(
                                error: 'Your Not Authourized To Use This App');
                  }
                  return;
                },
                validator: (value) {
                  if (!isPassword) {
                    bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value ?? '');
                    if (value == null || value.isEmpty || !emailValid) {
                      return 'Please enter Valid email';
                    }
                  }
                  if (isPassword) {
                    if (value == '') {
                      return 'Password  Field Is Required';
                    }
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    isPassword ? password = value! : username = value!;
                  });
                },
                keyboardType: TextInputType.emailAddress,
                cursorColor: kPrimaryColor,
                obscureText: isPassword,
                decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.fromLTRB(30, 20, 20, 10),
                    border: InputBorder.none,
                    fillColor: Color(0xfff3f3f4),
                    filled: true))
          ],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        errors.clear();
        if (_formKey.currentState!.validate()) {
          var pref = await SharedPreferences.getInstance();
          setState(() {
            isLoading = true;
            userId = pref.getInt("user_id");
            devId = pref.getString("deviceId");
          });
          _formKey.currentState!.save();

          ////////print((devId);
          var res = await getUserDetails();
          if (res == "success") {
            setState(() {
              password == null;
            });
            await RealTimeCommunication()
                .createConnection('1', androidId: devId, id: userId);
            Navigator.pushNamed(
              context,
              DashboardScreen.routeName,
            ).then((_) => RealTimeCommunication().createConnection("1"));

            // Navigator.pushNamed(
            //   context,
            //   Otp.routeName,
            // ).then((_) => RealTimeCommunication().createConnection("1"));
            // password == null;
            _formKey.currentState!.reset();
          } else {
            //  //////print(('fail');
          }
          //  String val = await checkUserStatus(username!, password!);

        }
        setState(() {
          isLoading = false;
        });
      },
      child: isLoading
          ? SpinKitFadingCircle(
              color: kPrimaryColor,
              size: 35.0.sp,
            )
          : Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: const Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [kPrimaryColor, Colors.green[50]!])),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 13.0.sp, color: Colors.white),
                ),
              ),
            ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: const <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('tfsappv3.1.0+2'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Tanzania  ',
          style: GoogleFonts.portLligatSlab(
            // textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0XFF105F01),
          ),
          children: const [
            TextSpan(
              text: 'Forest  ',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: 'Services  ',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: 'Agency  ',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: '(TFS).',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
          ]),
    );
  }

  Widget _title2() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: ' TFS',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: const [
            TextSpan(
              text: 'A',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: 'pp',
              style: TextStyle(color: kPrimaryColor, fontSize: 20),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Username"),
        _entryField("Password", isPassword: true),
      ],
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final Uri toLaunch = Uri(
      scheme: 'http',
      host: '41.59.228.37',
      path: '/fremis/download_APK',
    );
    return Scaffold(
        body: SizedBox(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .16,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 13.0.h),
                      _title(),
                      Container(
                        decoration: const BoxDecoration(
                            // border: Border.all(
                            //     color: Colors.cyan,
                            //     style: BorderStyle.solid,
                            //     width: 1),
                            ),
                        height: getProportionateScreenHeight(150),
                        width: getProportionateScreenHeight(150),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      _title2(),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      _emailPasswordWidget(),
                      FormError(errors: errors),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      _submitButton(),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      _divider(),
                      InkWell(
                        onTap: (() => openDownloadLink(toLaunch)),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: <Widget>[
                              const SizedBox(
                                width: 20,
                              ),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 7),
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(
                                    Icons.update_outlined,
                                    color: Colors.blue,
                                  )),
                              SizedBox(
                                width: getProportionateScreenWidth(5),
                              ),
                              const Text(
                                "Click To Update App",
                                style: TextStyle(color: Colors.blue),
                              ),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 7),
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> openDownloadLink(Uri url) async {
    // Uri url = Uri.parse("https://mis.tfs.go.tz/fremis/download_APK");
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalNonBrowserApplication,
    )) {
      //print(url);
      throw 'Could not launch $url';
    }
  }
}
