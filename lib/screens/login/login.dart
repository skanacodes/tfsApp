import 'dart:convert';

//import 'package:tfsappv1/screens/dashboard/dashboardScreen.dart';

import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/dashboard/dashboardScreen.dart';

import 'package:tfsappv1/screens/login/Widget/bezierContainer.dart';

import 'package:tfsappv1/services/size_config.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:tfsappv1/services/form_error.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/login";
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

  Future<void> createUser(
      String token,
      int userId,
      int stationId,
      String checkpointId,
      String fname,
      String lname,
      String email,
      String phoneNumber,
      String stationName) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('user_id', userId);
      prefs.setString('token', token);
      prefs.setInt('station_id', stationId);
      prefs.setString('StationName', stationName);
      prefs.setString('fname', fname);
      prefs.setString('lname', lname);
      prefs.setString('email', email);
      prefs.setString('phoneNumber', phoneNumber);
      prefs.setString('checkpointId', checkpointId);
    });
  }

  Future<String> getUserDetails() async {
    try {
      // print(username);
      // print(password);

      var url = Uri.parse('$baseUrl/api/v1/login');
      var username = "barakasikana@gmail.com";
      var password = "baraka540";
      final response = await http.post(
        url,
        body: {'email': username, 'password': password, 'android_id': devId!},
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });

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
          );
          return 'success';
          // ignore: dead_code
          break;
        case 403:
          setState(() {
            res = json.decode(response.body);
            print(res);
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
            print(res);
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
            print(res);
            addError(error: 'Something Went Wrong');
            isLoading = false;
          });
          return 'fail';
          // ignore: dead_code
          break;
      }
    } catch (e) {
      setState(() {
        print(e);

        addError(error: 'Server Or Network Connectivity Error');
        isLoading = false;
      });
      return 'fail';
    }
  }

  void addError({required String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({required String error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  Widget _entryField(String title, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: TextFormField(
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      errors.contains('Network Problem')
                          ? removeError(
                              error: 'Server Or Network Connectivity Error')
                          : errors.contains('Incorrect Password or Email')
                              ? removeError(
                                  error: 'Incorrect Password or Email')
                              : removeError(
                                  error:
                                      'Your Not Authourized To Use This App');
                    }
                    return null;
                  },
                  // validator: (value) =>
                  //     value == '' ? 'This  Field Is Required' : null,
                  onSaved: (value) {
                    setState(() {
                      isPassword ? password = value! : username = value!;
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: kPrimaryColor,
                  obscureText: isPassword,
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(30, 20, 20, 10),
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true)),
            )
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

          print(devId);
          var res = await getUserDetails();
          if (res == "success") {
            await RealTimeCommunication()
                .createConnection('1', androidId: devId, id: userId);
            Navigator.pushNamed(
              context,
              DashboardScreen.routeName,
            ).then((_) => RealTimeCommunication().createConnection("1"));

            _formKey.currentState!.reset();
          } else {
            print('fail');
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
              padding: EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(2, 4),
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
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
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
          Text('tfsappv1.0.0'),
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
            color: Color(0XFF105F01),
          ),
          children: [
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
          children: [
            TextSpan(
              text: 'A',
              style: TextStyle(color: Color(0XFF105F01), fontSize: 20),
            ),
            TextSpan(
              text: 'pp',
              style: TextStyle(color: Colors.black, fontSize: 20),
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

  // @override
  // void initState() {
  //   // ignore: todo
  // ignore: todo
  //   // TODO: implement initState

  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .16,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
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
                        decoration: BoxDecoration(
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
                      Container(child: FormError(errors: errors)),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      _submitButton(),
                      SizedBox(height: getProportionateScreenHeight(15)),
                      _divider(),
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
}
