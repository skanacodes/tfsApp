// ignore_for_file: unused_import, unused_element, file_names, use_key_in_widget_constructors, prefer_typing_uninitialized_variables, avoid_print, non_constant_identifier_names, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/verification/expectedTpHistory.dart';
import 'package:tfsappv1/screens/verification/extension_approvalscreen.dart';
import 'package:tfsappv1/screens/verification/license_screen.dart';
import 'package:tfsappv1/screens/verification/tp_editing.dart';
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
  const ScanQr({required this.role});
  @override
  _ScanQrState createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  String result = "Hey there !";
  bool isAlreadyVerified = false;
  bool iSscanned = false;
  bool isReceiptLoading = false;
  bool isTptypeForest = false;
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
  bool istp = false;
  bool isreceipt = false;
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
        const SnackBar(
          content: Text("Starting Printer"),
        ),
      );
      //print(totalfines);
      final String result = await platform.invokeMethod('getBatteryLevel', {
        "controlNumberList": controlNumberList,
        "fineList": finesList,
        "totalFines": totalfines.toString(),
        "amountList": amountList,
        "dealername": clientNames,
        "brand": brand,
        "activity": "printBill"
      });

      //print(result);
      if (result == "Successfully Printed") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
          ),
        );
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
          ),
        );
      }
    } on PlatformException catch (e) {
      //print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
        ),
      );
    }
  }

  messageToUser(String hint, String message,
      {String? tpNumber, String? token}) {
    return Alert(
      context: context,
      type: hint == "info" ? AlertType.info : AlertType.success,
      //title: "Information",
      desc: message,
      buttons: [
        DialogButton(
          onPressed: () async {
            Navigator.pop(context);
            print(tpNumber);
            await verifyTp(tpNumber!, token!);
          },
          width: 120,
          child: const Text(
            "Yes, Verify",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        DialogButton(
          color: Colors.red,
          onPressed: () {
            Navigator.pop(context);
          },
          width: 120,
          child: const Text(
            "Don't Verify",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        )
      ],
    ).show();
  }

  _qrCallback(String? code) async {
    try {
      if (istp) {
        setState(() {
          _camState = false;
          _qrInfo = code;
          istp = false;
        });
        //  //print(_qrInfo!);
        String tokens = await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('token').toString());
        String? fname = await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('fname'));
        String? lname = await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('lname'));
        String? checkpoint = await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('checkpointName'));
        messageToUser("info",
            "You are about to start verification for TP Number ${_qrInfo!.substring(11, 19)}, at $checkpoint checkpoint, Are you sure vehicle has arrived at $checkpoint Checkpoint? ",
            tpNumber: _qrInfo!.substring(11, 19), token: tokens);
      }
      if (isreceipt) {
        setState(() {
          _camState = false;
          _qrInfo = code;
          isreceipt = false;
        });
        // //print(_qrInfo! + "dwf");
        String tokens = await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('token').toString());
        await verifyReceipt(_qrInfo!, tokens);
      }
    } catch (e) {
      message(e.toString(), "error");
    }
  }

  _scanCode(String val) {
    setState(() {
      _camState = true;
      val == "tp" ? istp = true : isreceipt = true;
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
    String? fname = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('fname'));
    String? lname = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('lname'));

    String? checkpointcode = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('checkpointcode'));
    setState(() {
      isPosting = true;
    });
    String username = "$fname $lname";
    try {
      var headers = {"Authorization": "Bearer $token"};
      var url = isTptypeForest
          ? Uri.parse('$baseUrlTest/api/v1/tp-validate')
          : Uri.parse('$baseUrlHoneyTraceability/api/v1/tp-validate');
      //print(checkpointcode);
      // print(username);
      final response = await http.post(url,
          body: {
            'user_id': userId.toString(),
            'tp_number': tpNumbere,
            'name': username.toString(),
            'checkpoint_id': checkpointId.toString(),
            'checkpoint_code': checkpointcode
          },
          headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print(response.body);

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
              message(res['message'], 'error');
              isPosting = false;
              iSscanned = true;
            }
          });
          break;
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            if (res["success"]) {
              tpData = res['tp_data'];
              prevCheck = res['prev_check'];
              tpProduct = res['products'];
              iSscanned = true;
              isPosting = false;
            } else {
              message(res["message"].toString(), "error");
            }
          });
          break;
        case 400:
          setState(() {
            res = json.decode(response.body);
            //print(res);

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
            //print(res);
            isPosting = false;
            if (res['message'] == 'This TP Already Expired') {
              message("This TP Has Already Expired", "error");
            }
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
              message(
                  'This TP contains unpaid fine, please pay before you proceed',
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
            if (res['message'] == "You Dont Have Permission to Scan Tp") {
              message("You Dont Have Permission to Scan Tp", "error");
            }
          });
          break;
        case 404:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            isPosting = false;
            if (res['message'] == 'Transitpass Does not Exist') {
              message('Transitpass Does not Exist', 'error');
            }
          });
          break;
        case 500:
          setState(() {
            // print('thhy');
            res = response.body;
            print(res);
            isPosting = false;
            message('Connectivity Error', 'error');
          });
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);
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
        //print(res);
      });
    }
  }

  Future verifyReceipt(String Numbere, String token) async {
    setState(() {
      isReceiptLoading = true;
    });

    try {
      var headers = {"Authorization": "Bearer $token"};
      var url = Uri.parse('$baseUrlTest/api/v1/receipt-validate');
      final response =
          await http.post(url, body: {"receipt_no": Numbere}, headers: headers);
      var res;
      //final sharedP prefs=await
      //print(response.statusCode);

      switch (response.statusCode) {
        case 201:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            //message("The Receipt is Valid", "success");
          });
          break;
        case 200:
          res = json.decode(response.body);
          //print(res);
          setState(() {
            res = json.decode(response.body);
            if (res["status"].toString() == "Token is Expired") {
              message("Token Has Expired...Please Login Again", "error");
            } else if (res["msg"].toString() == "Valid Receipt") {
              message("The Receipt is Valid", "success");
            } else if (res["msg"].toString() == "Invalid Receipt") {
              message("The Receipt is Invalid", "success");
            }
          });
          break;

        case 404:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            message("Receipt Not Found", "error");
          });
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            isPosting = false;
            message("Something Went Wrong", "success");
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        message('Bad Connection Or  Server Error', 'error');
        isPosting = false;
        //print(res);
      });
    }
    setState(() {
      isReceiptLoading = false;
    });
  }

  enterTpNoPrompt(String tokens) {
    return Alert(
        context: context,
        title: istp
            ? "Failed Scanning Enter TP Number"
            : "Failed Scanning Enter Receipt Number",
        content: Column(
          children: <Widget>[
            isPosting
                ? const CupertinoActivityIndicator(
                    radius: 20,
                    animating: true,
                  )
                : TextField(
                    onChanged: (value) {
                      tpNumberPrompt = value;
                      // //print(tpNumberPrompt);
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.folder_open),
                      labelText:
                          istp ? 'Enter TP Number' : 'Enter Receipt Number',
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
              String? checkpoint = await SharedPreferences.getInstance()
                  .then((prefs) => prefs.getString('checkpointName'));
              istp
                  ? messageToUser("info",
                      "You are about to start verification for TP Number $tpNumberPrompt , at $checkpoint checkpoint, Are you sure vehicle has arrived at $checkpoint Checkpoint? ",
                      token: tokens, tpNumber: tpNumberPrompt)
                  : await verifyReceipt(tpNumberPrompt!, tokens);
              setState(() {
                isreceipt = false;
                istp = false;
              });
            },
            child: Text(
              "VERIFY",
              style: TextStyle(color: Colors.white, fontSize: 11.sp),
            ),
          ),
          DialogButton(
            color: Colors.red,
            onPressed: () {
              setState(() {
                _camState = false;
                istp = false;
                isreceipt = false;
              });
              Navigator.pop(context);
            },
            child: Text(
              "CANCEL",
              style: TextStyle(color: Colors.white, fontSize: 11.sp),
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

  Future _scanQR() async {
    try {
      // String? barcodeScanRes = await scanner.scan();
      // // var x = barcodeScanRes == null ? null : barcodeScanRes.substring(11, 19);

      // // barcodeScanRes
      // if (barcodeScanRes != null) {
      //   setState(() {
      //     result = barcodeScanRes.toString();
      //   });
      // }
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
            ),
          )
        : iSscanned == false
            ? AnimationLimiter(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 1375),
                      childAnimationBuilder: (widget) => FadeInAnimation(
                        child: SlideAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        SizedBox(
                          height: getProportionateScreenHeight(300),
                          child: Stack(
                            children: [
                              Container(
                                height: getProportionateScreenHeight(350),
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(400))),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    width: getProportionateScreenWidth(150),
                                    height: getProportionateScreenHeight(150),
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(300))),
                                  ),
                                ),
                              ),
                              iSscanned
                                  ? Text(result)
                                  : Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        height:
                                            getProportionateScreenHeight(400),
                                        width: getProportionateScreenWidth(200),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height:
                                                  getProportionateScreenHeight(
                                                      5),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                            ),
                                            Container(
                                              height:
                                                  getProportionateScreenHeight(
                                                      180),
                                              width:
                                                  getProportionateScreenWidth(
                                                      200),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(0)),
                                              child: Card(
                                                  elevation: 20,
                                                  shadowColor: kPrimaryColor,
                                                  color: Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: SvgPicture.asset(
                                                      'assets/icons/qr-code-scan.svg',
                                                      alignment:
                                                          Alignment.center,
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
                            ? const CupertinoActivityIndicator(
                                radius: 20,
                              )
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Card(
                                  elevation: 10,
                                  child: ListTile(
                                    // tileColor: Colors.grey[200],
                                    onTap: () async {
                                      showModalForTp();
                                    },
                                    trailing: const Icon(
                                      Icons.arrow_right,
                                      color: Colors.black,
                                    ),
                                    leading: IntrinsicHeight(
                                        child: SizedBox(
                                            height: double.maxFinite,
                                            width: getProportionateScreenHeight(
                                                35),
                                            child: CircleAvatar(
                                              backgroundColor: Colors.grey[200],
                                              child: Image.asset(
                                                  "${filepathImages}verify.png"),
                                            ))),
                                    title: const Text("Click To Verify TP "),
                                    subtitle: const Text(
                                        "Check For The Validity Of TP"),
                                  ),
                                ),
                              ),
                        isReceiptLoading
                            ? const CupertinoActivityIndicator(
                                radius: 20,
                              )
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Card(
                                  elevation: 10,
                                  child: ListTile(
                                    //tileColor: Colors.grey[200],
                                    onTap: () async {
                                      _scanCode("receipt");
                                    },
                                    trailing: const Icon(
                                      Icons.arrow_right,
                                      color: Colors.black,
                                    ),
                                    leading: IntrinsicHeight(
                                        child: SizedBox(
                                            height: double.maxFinite,
                                            width: getProportionateScreenHeight(
                                                35),
                                            child: CircleAvatar(
                                              backgroundColor: Colors.grey[200],
                                              child: Image.asset(
                                                  "${filepathImages}receipt.png"),
                                            ))),
                                    title: const Text("Verify Receipt"),
                                    subtitle: const Text(
                                        "Check For The Validity Of Receipt"),
                                  ),
                                ),
                              ),
                        controlNumber!.isNotEmpty
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Card(
                                  elevation: 10,
                                  child: ListTile(
                                    //  tileColor: Colors.grey[200],
                                    onTap: () async {
                                      Navigator.pushNamed(
                                        context,
                                        ExpectedTP.routeName,
                                      ).then((_) => RealTimeCommunication()
                                          .createConnection("3"));
                                    },
                                    trailing: const Icon(
                                      Icons.arrow_right,
                                      color: Colors.black,
                                    ),
                                    leading: IntrinsicHeight(
                                        child: SizedBox(
                                            height: double.maxFinite,
                                            width: getProportionateScreenHeight(
                                                35),
                                            child: CircleAvatar(
                                              backgroundColor: Colors.grey[200],
                                              child: Image.asset(
                                                  "${filepathImages}expected.png"),
                                            ))),
                                    title: const Text("List Of Expected TP"),
                                    subtitle: const Text(""),
                                  ),
                                ),
                              ),
                        controlNumber!.isNotEmpty
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Card(
                                  elevation: 10,
                                  child: ListTile(
                                    //tileColor: Colors.grey[200],
                                    onTap: () async {
                                      showModal();
                                    },
                                    trailing: const Icon(
                                      Icons.arrow_right,
                                      color: Colors.black,
                                    ),
                                    leading: IntrinsicHeight(
                                        child: SizedBox(
                                            height: double.maxFinite,
                                            width: getProportionateScreenHeight(
                                                35),
                                            child: CircleAvatar(
                                              backgroundColor: Colors.grey[200],
                                              child: Image.asset(
                                                  "${filepathImages}change.png"),
                                            ))),
                                    title: const Text("Change Request(s)"),
                                    subtitle:
                                        const Text("TP Editing and Extension"),
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
                                    // tileColor: Colors.grey[200],
                                    trailing: const Icon(
                                      Icons.error_outline_outlined,
                                      color: Colors.black,
                                    ),
                                    leading: IntrinsicHeight(
                                        child: SizedBox(
                                            height: double.maxFinite,
                                            width: getProportionateScreenHeight(
                                                50),
                                            child: Row(
                                              children: const [
                                                VerticalDivider(
                                                  color: Colors.red,
                                                  thickness: 5,
                                                )
                                              ],
                                            ))),
                                    title: const Center(
                                      child: Text(
                                        "Fine(s)",
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                              Text(controlNumber![i]
                                                      ["bill_desc"]
                                                  .toString()),
                                              Text(
                                                  "Control-No: ${controlNumber![i]["control_number"]}"),
                                              Text(
                                                  "Amount: ${controlNumber![i]["bill_amount"]}"),
                                              const Divider(
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
                    )))
            : AfterVerification(
                tpData: tpData,
                previousCheckpoint: prevCheck,
                tpProduct: tpProduct,
                isAlreadyVerified: isAlreadyVerified,
                verificationCode: vercode,
                isForestProduce: isTptypeForest,
              );
  }

  showModal() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200]!,
                  child: const Icon(
                    Icons.select_all_outlined,
                    color: Colors.green,
                  ),
                ),
                title: const Text(
                  "Select Operation",
                ),
              ),
              Divider(
                color: Colors.grey[400]!,
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                title: const Text('TP Extensions Request(s)'),
                subtitle: Divider(
                  color: Colors.grey[400]!,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    ExtensionApproval.routeName,
                  ).then((_) => RealTimeCommunication().createConnection("1"));
                  //Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                title: const Text('TP Editing Request(s)'),
                subtitle: Divider(
                  color: Colors.grey[400]!,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    TPEditing.routeName,
                  ).then((_) => RealTimeCommunication().createConnection("1"));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                subtitle: Divider(
                  color: Colors.grey[400]!,
                ),
                title: const Text('License Editing Request(s)'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    LicenseEditiScreen.routeName,
                  ).then((_) => RealTimeCommunication().createConnection("1"));
                },
              ),
            ],
          );
        });
  }

  showModalForTp() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200]!,
                  child: const Icon(
                    Icons.select_all_outlined,
                    color: Colors.green,
                  ),
                ),
                title: const Text(
                  "Select Operation",
                ),
              ),
              Divider(
                color: Colors.grey[400]!,
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                title: const Text('Forest Produce TP'),
                subtitle: Divider(
                  color: Colors.grey[400]!,
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    isTptypeForest = true;
                  });
                  _scanCode("tp");
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                title: const Text('Bee Product TP'),
                subtitle: Divider(
                  color: Colors.grey[400]!,
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    isTptypeForest = false;
                  });
                  _scanCode("tp");
                },
              ),
            ],
          );
        });
  }
}
