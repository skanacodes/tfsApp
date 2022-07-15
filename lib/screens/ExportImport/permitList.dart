// ignore_for_file: file_names, prefer_const_constructors_in_immutables, prefer_typing_uninitialized_variables, avoid_print, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tfsappv1/screens/ExportImport/InspectionForm.dart';
import 'package:tfsappv1/screens/ExportImport/grading.dart';

import 'package:tfsappv1/screens/ExportImport/sealScreen.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/gradingModal.dart';
import 'package:tfsappv1/services/modal/inspectionModal.dart';

import 'package:tfsappv1/services/size_config.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PermittList extends StatefulWidget {
  static String routeName = "/permitList";
  PermittList({Key? key}) : super(key: key);

  @override
  _PermittListState createState() => _PermittListState();
}

class _PermittListState extends State<PermittList> {
  String? type;
  String result = "";
  List data = [];
  bool isVerify = false;
  var exportData;
  bool isLoading = false;
  String? permitNumber;
  goToTheSealScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (__) => SealScreen(exportData)));
  }

  Future verify(String id, String token) async {
    // String userId = await SharedPreferences.getInstance()
    //     .then((prefs) => prefs.getInt('user_id').toString());
    // String stationId = await SharedPreferences.getInstance()
    //     .then((prefs) => prefs.getInt('station_id').toString());

    // //print(userId);
    // //print(stationId);
    // //print(userId.toString());
    // //print(checkpointId.toString());
    try {
      //print(id);
      int.parse(id);
      //print(id);
      //print("gfgjhjkm");
      var headers = {"Authorization": "Bearer $token"};
      var url = Uri.parse('$baseUrl/api/v1/export/find/$id');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //print(response.statusCode);
      // //print('dfsjjdsfsd');
      //final sharedP prefs=await
      res = json.decode(response.body);
      //print(res);
      // //print('dfsjjdsfsd');
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            exportData = res['export'];
            goToTheSealScreen();
            //print(res);
          });
          break;

        case 500:
          setState(() {
            message("Error Occured While Processing Request", "error");
            res = response.body;
            //print(res);
          });
          break;
        default:
          setState(() {
            message("Error Occured While Processing Request", "error");
            res = json.decode(response.body);
            //print(res);
          });
          break;
      }
    } on SocketException {
      setState(() {
        message("Error Occured While Processing Request", "error");
        //print(res);
      });
    }
  }

  Future _scanQR() async {
    try {
      // String? barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      //     "GREEN", "Cancel", true, ScanMode.QR);
      // //print(barcodeScanRes.toString() + "huushfuiewiu");
      // // ignore: unnecessary_null_comparison
      // var x = barcodeScanRes.toString() == "-1"
      //     ? null
      //     : barcodeScanRes.substring(7, 11);
      // //print(barcodeScanRes);
      // String tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token').toString());
      // //print(x.toString() + "hfdhg");
      // if (x != null) {
      //   setState(() {
      //     isVerify = true;
      //   });

      //   await verify(x, tokens);
      //   setState(() {
      //     isVerify = false;
      //   });
      // } else {
      //   enterTpNoPrompt(tokens);
      // }

      // setState(() {
      //   result = barcodeScanRes.toString();
      // });
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

  enterTpNoPrompt(String tokens) {
    return Alert(
        context: context,
        title: "Failed Scanning Enter Permit Number",
        content: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) {
                permitNumber = value;
                //print(permitNumber);
              },
              cursorColor: kPrimaryColor,
              decoration: const InputDecoration(
                icon: Icon(Icons.folder_open),
                labelText: 'Permit Number',
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                isVerify = true;
              });
              await verify(permitNumber!, tokens);
              setState(() {
                isVerify = false;
              });
            },
            child: const Text(
              "VERIFY",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            color: Colors.red,
            onPressed: () => Navigator.pop(context),
            child: const Text(
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

  final List<DropdownMenuItem<String>> _permitType = [
    const DropdownMenuItem(
      value: "Export Inspection",
      child: Text("Inspection"),
    ),
    const DropdownMenuItem(
      value: "Grading",
      child: Text("Grading"),
    ),
    const DropdownMenuItem(
      value: "Verification And Seal",
      child: Text("Verification And Seal"),
    ),
  ];

  Future getData() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      //print(tokens);
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrl/api/v1/export/grade-view');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            data = res['grading'];
          });
          RealTimeCommunication().createConnection(
            "12",
          );
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        //print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  Future getDataImport() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      //print(tokens);
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrl/api/v1/import/insp-view');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            data = res['inspection'];
          });
          RealTimeCommunication().createConnection(
            "11",
          );
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        //print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  Future getDataInspection() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      //print(tokens);

      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrl/api/v1/inspection');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            data = res['inspection'];
            //  //print(data[0]["dealer"].toString() + "hjsdkjdskjdsjk");
          });
          RealTimeCommunication().createConnection(
            "10",
          );
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        //print(e);
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
          onPressed: () {
            if (type == 'success') {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
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
    RealTimeCommunication().createConnection(
      "9",
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //String args = ModalRoute.of(context)!.settings.arguments.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'Export & Import Management',
          style: TextStyle(
              fontFamily: 'Ubuntu', color: Colors.black, fontSize: 15),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: getProportionateScreenHeight(700),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: getProportionateScreenHeight(140),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: getProportionateScreenHeight(90),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(100),
                                bottomRight: Radius.circular(100)),
                            color: kPrimaryColor,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Card(
                              elevation: 20,
                              child: SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButtonFormField(
                                      decoration: const InputDecoration(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(0, 5.5, 0, 0),
                                          labelStyle: TextStyle(),
                                          labelText: 'Select Operation'),
                                      items: _permitType,
                                      value: type,
                                      validator: (value) => value == null
                                          ? "This Field is Required"
                                          : null,
                                      onChanged: (value) async {
                                        setState(() {
                                          type = value.toString();
                                          isLoading = true;
                                        });
                                        type == 'Grading'
                                            ? await getData()
                                            : type == 'Export Inspection'
                                                ? await getDataInspection()
                                                : type ==
                                                        'Verification And Seal'
                                                    ? print('Seal')
                                                    : await getDataImport();

                                        setState(() {
                                          isLoading = false;
                                        });
                                      }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Adding the List here
                  type == 'Verification And Seal'
                      ? Container()
                      : isLoading
                          ? const SpinKitCircle(
                              color: kPrimaryColor,
                            )
                          : data.isEmpty
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Card(
                                    elevation: 10,
                                    child: ListTile(
                                      title: Text('Data Not Found'),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.pink,
                                        child: Icon(Icons.hourglass_empty),
                                      ),
                                    ),
                                  ),
                                ))
                              : Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    height: getProportionateScreenHeight(500),
                                    color: Colors.white,
                                    child: AnimationLimiter(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: data.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return AnimationConfiguration
                                              .staggeredList(
                                            position: index,
                                            duration: const Duration(
                                                milliseconds: 1375),
                                            child: SlideAnimation(
                                              verticalOffset: 50.0,
                                              child: FadeInAnimation(
                                                child: Card(
                                                  elevation: 10,
                                                  shadowColor: Colors.grey,
                                                  child: SizedBox(
                                                    child: ListTile(
                                                      onTap: () {
                                                        type == 'Grading'
                                                            ? Navigator.pushNamed(
                                                                    context,
                                                                    Grading
                                                                        .routeName,
                                                                    arguments: GradingArguments(
                                                                        data[index]['id']
                                                                            .toString(),
                                                                        data[index]['export_id']
                                                                            .toString()))
                                                                .then(
                                                                    (value) async {
                                                                setState(() {
                                                                  isLoading =
                                                                      true;
                                                                });
                                                                await getData();
                                                                setState(() {
                                                                  isLoading =
                                                                      false;
                                                                });
                                                              })
                                                            : Navigator
                                                                .pushNamed(
                                                                context,
                                                                InspectionForm
                                                                    .routeName,
                                                                arguments: InspectionArguments(
                                                                    data[index][
                                                                            "id"]
                                                                        .toString(),
                                                                    data[index]["purpose"].toString() ==
                                                                            "Export"
                                                                        ? "Export Inspection"
                                                                        : "Import Inspection",
                                                                    data[index][
                                                                        'insp_prod']),
                                                              ).then(
                                                                (value) async {
                                                                setState(() {
                                                                  isLoading =
                                                                      true;
                                                                });
                                                                type == 'Export Inspection'
                                                                    ? await getDataInspection()
                                                                    : await getDataImport();

                                                                setState(() {
                                                                  isLoading =
                                                                      false;
                                                                });
                                                              });
                                                      },
                                                      trailing: const Icon(
                                                        Icons.arrow_right,
                                                        color: Colors.cyan,
                                                      ),
                                                      leading: IntrinsicHeight(
                                                          child: SizedBox(
                                                              height: double
                                                                  .maxFinite,
                                                              width:
                                                                  getProportionateScreenHeight(
                                                                      50),
                                                              child: Row(
                                                                children: [
                                                                  VerticalDivider(
                                                                    color: index
                                                                            .isEven
                                                                        ? kPrimaryColor
                                                                        : Colors
                                                                            .green[200],
                                                                    thickness:
                                                                        5,
                                                                  )
                                                                ],
                                                              ))),
                                                      title: Text(type! ==
                                                              'Grading'
                                                          ? "Name: ${data[index]["dealer_name"]}"
                                                          : type ==
                                                                  'Export Inspection'
                                                              ? "Name: ${data[index]["dealer_name"]}"
                                                              : "Name: ${data[index]["dealer_name"]}"),
                                                      subtitle: Text(type! ==
                                                              'Grading'
                                                          ? "ID Code: ${data[index]["code"]}"
                                                          : type! ==
                                                                  'Export Inspection'
                                                              ? 'ID Code: ${data[index]["code"]}'
                                                              : 'ID Code: ${data[index]["import"]["code"]}'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                  type == 'Verification And Seal'
                      ? isVerify
                          ? const SpinKitCircle(
                              color: kPrimaryColor,
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: getProportionateScreenHeight(200),
                                child: Center(
                                  child: Card(
                                    elevation: 10,
                                    child: ListTile(
                                      onTap: () async {
                                        await _scanQR();
                                      },
                                      leading: const CircleAvatar(
                                        backgroundColor: Colors.pink,
                                        child: Icon(Icons.qr_code),
                                      ),
                                      title: const Text(
                                          'Click To Verify And Seal'),
                                    ),
                                  ),
                                ),
                              ),
                            )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
