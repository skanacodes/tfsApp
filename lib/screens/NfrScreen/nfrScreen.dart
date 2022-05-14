// ignore_for_file: file_names, prefer_typing_uninitialized_variables, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:tfsappv1/screens/NfrScreen/createTourism.dart';

import 'package:tfsappv1/screens/NfrScreen/toursList.dart';
import 'package:tfsappv1/screens/NfrScreen/visitorServices.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class NFRScreen extends StatefulWidget {
  static String routeName = "/NFRscreen";
  const NFRScreen({Key? key}) : super(key: key);

  @override
  State<NFRScreen> createState() => _NFRScreenState();
}

class _NFRScreenState extends State<NFRScreen> {
  String? _qrInfo = ' code';
  bool _camState = false;
  bool isLoading = false;
  String? operation;
  _qrCallback(String? code) async {
    setState(() {
      _camState = false;

      _qrInfo = code;
    });
    //print(_qrInfo);
    await getData(operation!);
  }

  _scanCode(int index) {
    setState(() {
      index == 2
          ? operation = "in"
          : index == 3
              ? operation = "out"
              : operation = "service";
      _camState = true;
    });
  }

  Future getData(String operation) async {
    setState(() {
      isLoading = true;
    });
    // print("hellow");
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // print(tokens);
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url = operation == "in"
          ? Uri.parse('$baseUrlTest/api/v1/members/check_in/$_qrInfo')
          : operation == "out"
              ? Uri.parse('$baseUrlTest/api/v1/members/check_out/$_qrInfo')
              : Uri.parse('$baseUrlTest/api/v1/members/activities/$_qrInfo');
      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            print(operation);
            isLoading = false;
            operation == "in"
                ? messages(
                    res["success"].toString() == "true" ? "success" : "error",
                    res["msg"].toString())
                : null;
            operation == "out"
                ? messages(
                    res["msg"].toString() == "Member Successfully Checked Out"
                        ? "success"
                        : "error",
                    res["msg"].toString())
                : null;
            operation == "service"
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VisitorServices(
                              memberId: res["data"]["member_id"].toString(),
                              data: res["data"]["activities"],
                              name: res["data"]["member"].toString(),
                            )))
                : null;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  messages(
    String type,
    String desc,
  ) {
    return Alert(
      context: context,
      type: type == 'success' ? AlertType.success : AlertType.error,
      title: 'Information',
      desc: desc,
      buttons: [
        DialogButton(
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            if (type == 'success') {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
          width: 120,
        )
      ],
    ).show();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _scanCode();
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            '',
            style: TextStyle(
                fontFamily: 'Ubuntu', color: Colors.black, fontSize: 15),
          ),
        ),
        body: SizedBox(
            height: height,
            child: Column(children: <Widget>[
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 5, 0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Card(
                        elevation: 10,
                        child: ListTile(
                          leading: CircleAvatar(
                            foregroundColor: kPrimaryColor,
                            backgroundColor: Colors.black12,
                            child: Icon(Icons.animation_outlined),
                          ),
                          title: Text("Tourism Management"),
                          // subtitle: Text(
                          //   _qrInfo!,
                          //   style: TextStyle(fontWeight: FontWeight.w400),
                          // ),
                          trailing: Icon(
                            Icons.library_books_outlined,
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
              isLoading
                  ? const SpinKitCircle(
                      color: kPrimaryColor,
                    )
                  : _camState
                      ? Center(
                          child: SizedBox(
                            height: getProportionateScreenHeight(400),
                            width: getProportionateScreenWidth(350),
                            child: QRBarScannerCamera(
                              fit: BoxFit.cover,
                              onError: (context, error) => Text(
                                error.toString(),
                                style: const TextStyle(color: Colors.red),
                              ),
                              qrCodeCallback: (code) {
                                _qrCallback(code);
                              },
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                            height: getProportionateScreenHeight(500),
                            color: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: ListView.builder(
                              itemCount: 5,
                              itemBuilder: ((context, i) {
                                return Card(
                                  elevation: 10,
                                  shadowColor: Colors.grey,
                                  child: SizedBox(
                                    child: ListTile(
                                      onTap: () async {
                                        var barcodeScanRes;
                                        //                               var options = ScanOptions(
                                        //   // set the options
                                        // );

                                        i == 0
                                            ? Navigator.pushNamed(
                                                context,
                                                CreateTourism.routeName,
                                              )
                                            : i == 1
                                                ? Navigator.pushNamed(
                                                    context,
                                                    VisitorsList.routeName,
                                                  )
                                                : _scanCode(i);
                                        print(barcodeScanRes);
                                      },
                                      trailing: const Icon(
                                        Icons.arrow_right,
                                        color: Colors.black,
                                      ),
                                      leading: IntrinsicHeight(
                                          child: SizedBox(
                                              height: double.maxFinite,
                                              width:
                                                  getProportionateScreenHeight(
                                                      50),
                                              child: Row(
                                                children: [
                                                  VerticalDivider(
                                                    color: i.isEven
                                                        ? kPrimaryColor
                                                        : Colors.green[200],
                                                    thickness: 5,
                                                  )
                                                ],
                                              ))),
                                      title: i == 0
                                          ? const Text("Create Tourism")
                                          : i == 1
                                              ? const Text("List Of Visitors")
                                              : i == 2
                                                  ? const Text("Scan To Check In")
                                                  : i == 3
                                                      ? const Text(
                                                          "Scan To Check Out")
                                                      : const Text(
                                                          "Scan For Service"),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ))
            ])));
  }
}
