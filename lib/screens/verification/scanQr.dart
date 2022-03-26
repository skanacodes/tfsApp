// ignore_for_file: unused_import, unused_element

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/verification/expectedTpHistory.dart';
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
  bool isAlreadyVerified = false;
  bool iSscanned = false;
  String? tpNumberPrompt;
  bool? status;
  String? tpNumber;
  String? billAmount;
  List? controlNumber = [];
  List? controlNumberList = [];
  List? amountList = [];
  List? finesList = [];
  List? clientNames = [];
  double? totalfines;
  String? vercode;
  String? brand;
  var tpData;
  var prevCheck;
  var tpProduct;
  bool isPosting = false;
  String? _qrInfo = '';
  bool _camState = false;
  static const platform = MethodChannel(
    'samples.flutter.dev/printing',
  );
  // Get battery level.
  String printing = '';

  getBrand() async {
    brand = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('brand'));
  }

  Future<void> _printBill() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Starting Printer"),
        ),
      );
      print(totalfines);
      final String result = await platform.invokeMethod('getBatteryLevel', {
        "controlNumberList": controlNumberList,
        "fineList": finesList,
        "totalFines": totalfines.toString(),
        "amountList": amountList,
        "dealername": clientNames,
        "brand": brand,
        "activity": "printBill"
      });

      print(result);
      if (result == "Successfully Printed") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$result"),
          ),
        );
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$result"),
          ),
        );
      }
    } on PlatformException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
        ),
      );
    }
  }

  _qrCallback(String? code) async {
    try {
      setState(() {
        _camState = false;
        _qrInfo = code;
      });
      print(_qrInfo!);
      String tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token').toString());
      verifyTp(_qrInfo!.substring(11, 19), tokens);
    } catch (e) {
      message(e.toString(), "error");
    }
  }

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future verifyTp(String tpNumbere, String token) async {
    String userId = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt('user_id').toString());
    String checkpointId = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('checkpointId').toString());
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
            'tp_number': tpNumbere,
            'user_id': userId.toString(),
            'checkpoint_id': checkpointId.toString()
          },
          headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);

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
        case 400:
          setState(() {
            res = json.decode(response.body);
            print(res);

            tpData = res['tp_data'];
            prevCheck = res['prev_check'];
            tpProduct = res['products'];
            iSscanned = true;
            isPosting = false;
            isAlreadyVerified = true;
            vercode = res["verification_code"];
          });
          break;
        case 403:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isPosting = false;
            if (res['message'] == 'Error! Checkpoint Skipped') {
              message('Error! Checkpoint Skipped', 'error');
              setState(() {
                controlNumber = res["bills"];
                double total = 0;
                for (var i = 0; i < controlNumber!.length; i++) {
                  clientNames!.add(controlNumber![i]["payer_name"]);
                  finesList!.add(controlNumber![i]["bill_desc"]);
                  controlNumberList!.add(controlNumber![i]["control_number"]);
                  amountList!.add(controlNumber![i]["bill_amount"]);
                  total =
                      total + double.parse(controlNumber![i]["bill_amount"]);
                }
                totalfines = total;
              });
            }
            if (res['message'] ==
                'This TP contains unpaid fine, please pay before proceed') {
              message('This TP contains unpaid fine, please pay before proceed',
                  'error');
              setState(() {
                controlNumber = res["bills"];
                double total = 0;
                for (var i = 0; i < controlNumber!.length; i++) {
                  clientNames!.add(controlNumber![i]["payer_name"]);
                  finesList!.add(controlNumber![i]["bill_desc"]);
                  controlNumberList!.add(controlNumber![i]["control_number"]);
                  amountList!.add(controlNumber![i]["bill_amount"]);
                  total =
                      total + double.parse(controlNumber![i]["bill_amount"]);
                }
                totalfines = total;
              });
            }
            if (res['message'] ==
                'Vessel Was Not Assigned to this checkpoint') {
              message('Vessel Was Not Assigned to this checkpoint', 'error');
            }
          });
          break;
        case 404:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isPosting = false;
            if (res['message'] == 'Transitpass Does not Exist') {
              message('Transitpass Does not Exist', 'error');
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
                      // print(tpNumberPrompt);
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
              setState(() {
                _camState = false;
              });
              await verifyTp(tpNumberPrompt!, tokens);
            },
            child: Text(
              "VERIFY",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            color: Colors.red,
            onPressed: () {
              setState(() {
                _camState = false;
              });
              Navigator.pop(context);
            },
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
      String? barcodeScanRes = await scanner.scan();
      // var x = barcodeScanRes == null ? null : barcodeScanRes.substring(11, 19);

      // barcodeScanRes
      if (barcodeScanRes != null) {
        setState(() {
          result = barcodeScanRes.toString();
        });
      }
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

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    String tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token').toString());
    enterTpNoPrompt(tokens);
    return Future.value(true);
  }

  @override
  void initState() {
    getBrand();
    RealTimeCommunication().createConnection(
      "7",
    );
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _camState
        ? WillPopScope(
            onWillPop: _willPopCallback,
            child: Center(
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
            ))
        : iSscanned == false
            ? Column(
                children: [
                  Container(
                    height: getProportionateScreenHeight(400),
                    child: Stack(
                      children: [
                        Container(
                          height: getProportionateScreenHeight(450),
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
                                alignment: Alignment.center,
                                child: Container(
                                  height: getProportionateScreenHeight(400),
                                  width: getProportionateScreenWidth(200),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: getProportionateScreenHeight(5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                      ),
                                      Container(
                                        height:
                                            getProportionateScreenHeight(190),
                                        width: getProportionateScreenWidth(200),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(0)),
                                        child: Card(
                                            elevation: 20,
                                            shadowColor: kPrimaryColor,
                                            color: Colors.white,
                                            child: Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: SvgPicture.asset(
                                                  'assets/icons/qr-code-scan.svg',
                                                  alignment: Alignment.center,
                                                ),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                  isPosting
                      ? CupertinoActivityIndicator(
                          radius: 20,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Card(
                            elevation: 10,
                            child: ListTile(
                              tileColor: Colors.grey[200],
                              onTap: () async {
                                _scanCode();
                              },
                              trailing: const Icon(
                                Icons.arrow_right,
                                color: Colors.black,
                              ),
                              leading: IntrinsicHeight(
                                  child: SizedBox(
                                      height: double.maxFinite,
                                      width: getProportionateScreenHeight(50),
                                      child: Row(
                                        children: [
                                          VerticalDivider(
                                            color: kPrimaryColor,
                                            thickness: 5,
                                          )
                                        ],
                                      ))),
                              title: Text("Click To Scan Qr Code "),
                              subtitle: Text("Check For The Validity Of TP"),
                            ),
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      elevation: 10,
                      child: ListTile(
                        tileColor: Colors.grey[200],
                        onTap: () async {
                          Navigator.pushNamed(
                            context,
                            ExpectedTP.routeName,
                          ).then((_) =>
                              RealTimeCommunication().createConnection("3"));
                        },
                        trailing: const Icon(
                          Icons.arrow_right,
                          color: Colors.black,
                        ),
                        leading: IntrinsicHeight(
                            child: SizedBox(
                                height: double.maxFinite,
                                width: getProportionateScreenHeight(50),
                                child: Row(
                                  children: [
                                    VerticalDivider(
                                      color: kPrimaryColor,
                                      thickness: 5,
                                    )
                                  ],
                                ))),
                        title: Text("List Of Expected TP"),
                        subtitle: Text(""),
                      ),
                    ),
                  ),
                  controlNumber!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Card(
                            elevation: 10,
                            child: ListTile(
                              onTap: (() => _printBill()),
                              tileColor: Colors.grey[200],
                              trailing: const Icon(
                                Icons.error_outline_outlined,
                                color: Colors.black,
                              ),
                              leading: IntrinsicHeight(
                                  child: SizedBox(
                                      height: double.maxFinite,
                                      width: getProportionateScreenHeight(50),
                                      child: Row(
                                        children: [
                                          VerticalDivider(
                                            color: Colors.red,
                                            thickness: 5,
                                          )
                                        ],
                                      ))),
                              title: Center(
                                child: Text(
                                  "Fine(s)",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  for (var i = 0;
                                      i < controlNumber!.length;
                                      i++)
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(controlNumber![i]["bill_desc"]
                                            .toString()),
                                        Text("Control-No: " +
                                            controlNumber![i]["control_number"]
                                                .toString()),
                                        Text("Amount: " +
                                            controlNumber![i]["bill_amount"]
                                                .toString()),
                                        Divider(
                                          color: Colors.black54,
                                        )
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              )
            : AfterVerification(
                tpData: tpData,
                previousCheckpoint: prevCheck,
                tpProduct: tpProduct,
                isAlreadyVerified: isAlreadyVerified,
                verificationCode: vercode,
              );
  }
}
