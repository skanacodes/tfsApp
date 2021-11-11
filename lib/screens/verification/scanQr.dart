import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/screens/verification/afterverification.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:sizer/sizer.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ScanQr extends StatefulWidget {
  final String role;
  ScanQr({required this.role});
  @override
  _ScanQrState createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  String result = "Hey there !";

  bool iSscanned = false;
  String? tpNumberPrompt;
  bool? status;
  String? tpNumber;

  var tpData;
  var prevCheck;
  var tpProduct;
  bool isPosting = false;
  // String token;

  Future verifyTp(String tpNumbere, String token) async {
    print('////,,,,,,,,,,');
    String userId = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt('user_id').toString());
    String checkpointId = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt('checkpointId').toString());
    setState(() {
      isPosting = true;
    });
    print(tpNumbere);
    print(userId.toString());
    print(checkpointId.toString());
    try {
      var headers = {"Authorization": "Bearer " + token};
      var url =
          Uri.parse('https://mis.tfs.go.tz/fremis-test/api/v1/tp-validate');
      final response = await http.post(url,
          body: {
            'tp_number': tpNumbere.toString(),
            'user_id': userId.toString(),
            'checkpoint_id': checkpointId.toString()
          },
          headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print('dfsjjdsfsd');
      //final sharedP prefs=await
      // res = json.decode(response.body);
      // print(res);
      // print('dfsjjdsfsd');
      switch (response.statusCode) {
        case 201:
          setState(() {
            res = json.decode(response.body);
            print(res);
            if (res['message'] == 'Invalid Checkpoint') {
              message('Invalid Checkpoint', 'error');
            } else if (res['message'] ==
                'Previous checkpoint [Mkumbara] not yet verified this TP') {
              message('Some Previous Checkpoints Have Not Verified This TP',
                  'error');
            } else {
              print(res);
              print(res['data']['id']);
              isPosting = false;
              iSscanned = true;
            }
          });
          break;
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            tpData = res['tp_data'];
            prevCheck = res['prev_check'];
            tpProduct = res['products'];
            iSscanned = true;
            isPosting = false;
          });
          break;
        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isPosting = false;
          });
          break;
        case 403:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isPosting = false;
            if (res['message'] == 'Error! Checkpoint Skipped') {
              message('Some Previous Checkpoints Have Not Verified This TP',
                  'error');
            }
            if (res['message'] ==
                'Vessel Was Not Assigned to this checkpoint') {
              message('Vessel Was Not Assigned to this checkpoint', 'error');
            } else {
              message('You Do Not Have Permission To Scan TP', 'error');
            }
          });
          break;
        case 500:
          setState(() {
            print('thhy');
            res = response.body;
            print(res);
            isPosting = false;
            message('Transit Pass Not Found', 'error');
          });
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isPosting = false;
            message('Ooohps! Something Went Wrong', 'error');
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        message('Bad Connection Or  Server Error', 'error');
        isPosting = false;
        print(res);
      });
    }
  }

  enterTpNoPrompt(String tokens) {
    return Alert(
        context: context,
        title: "Failed Scanning Enter TP Number",
        content: Column(
          children: <Widget>[
            isPosting
                ? CupertinoActivityIndicator(
                    radius: 20,
                    animating: true,
                  )
                : TextField(
                    onChanged: (value) {
                      tpNumberPrompt = value;
                      print(tpNumberPrompt);
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      icon: Icon(Icons.folder_open),
                      labelText: 'Enter TP Number',
                    ),
                  ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              Navigator.pop(context);
              await verifyTp(tpNumberPrompt!, tokens);
            },
            child: Text(
              "VERIFY",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            color: Colors.red,
            onPressed: () => Navigator.pop(context),
            child: Text(
              "CANCEL",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  message(String desc, String type) {
    return Alert(
      context: context,
      type: type == 'error' ? AlertType.warning : AlertType.info,
      title: "Information",
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  Future _scanQR() async {
    try {
      String? barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "GREEN", "Cancel", true, ScanMode.QR);
      // ignore: unnecessary_null_comparison
      var x = barcodeScanRes == null ? null : barcodeScanRes.substring(11, 19);
      String tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token').toString());
      print(x);
      if (x != null) {
        await verifyTp(x, tokens);
      } else {
        enterTpNoPrompt(tokens);
      }

      setState(() {
        result = barcodeScanRes.toString();
      });
    } on PlatformException catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
      message(result, 'error');
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
      message(result, 'error');
    }
  }

  Widget _submitButton() {
    return isPosting
        ? CupertinoActivityIndicator(
            radius: 20,
          )
        : InkWell(
            onTap: () {
              _scanQR();
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 10),
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
                      colors: [kPrimaryColor, Colors.green[200]!])),
              child: Text(
                'Press To Scan QR Code',
                style: TextStyle(fontSize: 15.sp, color: Colors.white),
              ),
            ),
          );
  }

  @override
  void initState() {
    RealTimeCommunication().createConnection(
      "7",
    );
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return iSscanned == false
        ? Column(
            children: [
              Container(
                height: getProportionateScreenHeight(500),
                child: Stack(
                  children: [
                    Container(
                      height: getProportionateScreenHeight(500),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(400))),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: getProportionateScreenWidth(150),
                          height: getProportionateScreenHeight(150),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(300))),
                        ),
                      ),
                    ),
                    iSscanned
                        ? Container(
                            child: Text(result),
                          )
                        : Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: getProportionateScreenHeight(400),
                              width: getProportionateScreenWidth(200),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: getProportionateScreenHeight(200),
                                    width: getProportionateScreenWidth(200),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(0)),
                                    child: Card(
                                      elevation: 30,
                                      shadowColor: kPrimaryColor,
                                      color: kPrimaryColor,
                                      child: Column(
                                        children: [
                                          Container(
                                            height:
                                                getProportionateScreenHeight(
                                                    80),
                                            child: Text(
                                              'TP Verifications',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          Container(
                                            height:
                                                getProportionateScreenHeight(
                                                    105),
                                            color: Colors.white,
                                            child: Text(
                                              'Please Scan The QR Code On The Transit Pass Form To Verify The Validity Of The TP',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: getProportionateScreenHeight(5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                  ),
                                  Container(
                                    height: getProportionateScreenHeight(190),
                                    width: getProportionateScreenWidth(200),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(0)),
                                    child: Card(
                                        elevation: 20,
                                        shadowColor: kPrimaryColor,
                                        color: Colors.white,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: SvgPicture.asset(
                                              'assets/icons/qr-code-scan.svg',
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          )
                  ],
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(20),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                    height: getProportionateScreenHeight(50),
                    child: _submitButton()),
              )
            ],
          )
        : AfterVerification(
            tpData: tpData,
            previousCheckpoint: prevCheck,
            tpProduct: tpProduct,
          );
  }
}
