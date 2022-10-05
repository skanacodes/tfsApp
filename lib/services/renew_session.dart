import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:flutter/material.dart';

class RenewSession {
  String? password;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  Future renewSession(String password, context) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('email');
      var body = {'email': username, 'password': password, 'android_id': ""};

      var url = Uri.parse('$baseUrl/api/v1/token');

      final response = await http.post(url, body: json.encode(body), headers: {
        "Accept": "application/json",
        "content-type": "application/json"
      });
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          res = jsonDecode(response.body);
          if (res["success"].toString() == "true") {
            prefs.setString('token', res['data']);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Token Updated..Please Repeat Your Action"),
              duration: Duration(seconds: 5),
            ));
          } else {
            return "null";
          }

          break;

        case 403:
          res = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res["message"]),
            duration: const Duration(seconds: 3),
          ));
          break;
        default:
          res = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res["message"]),
            duration: const Duration(seconds: 2),
          ));
          break;
      }
      return "";
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Socket Exception"),
        duration: Duration(seconds: 2),
      ));
      return "";
    }
  }

  renewSessionForm(
    context,
  ) {
    return Alert(
        context: context,
        title: "Token Expired",
        desc: "Please re-enter Password to renew Session",

        ///onWillPopActive: true,

        style: AlertStyle(
            descStyle: TextStyle(
                fontFamily: "Ubuntu",
                fontSize: 11.sp,
                fontWeight: FontWeight.normal),
            titleStyle: TextStyle(
                fontFamily: "Ubuntu",
                fontSize: 12.sp,
                fontWeight: FontWeight.bold)),
        image: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Image.asset("${filepathImages}user.png")),
        content: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                obscureText: true,
                validator: (value) {
                  return value == null ? "Password Filled is Required" : null;
                },
                decoration: InputDecoration(
                    icon: const Icon(Icons.lock),
                    labelText: 're-enter Password',
                    labelStyle: TextStyle(fontSize: 9.sp)),
                onChanged: (val) {
                  password = val.toString();
                },
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            color: kPrimaryColor,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                isLoading = true;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Refreshing......"),
                    duration: Duration(seconds: 2),
                  ),
                );

                await renewSession(password.toString(), context);
                //isLoading = false;
              }
            },
            child: Text(
              "Renew Token",
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          )
        ]).show();
  }
}
