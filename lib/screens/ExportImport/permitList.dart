import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tfsappv1/screens/ExportImport/InspectionForm.dart';
import 'package:tfsappv1/screens/ExportImport/grading.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:tfsappv1/screens/ExportImport/sealScreen.dart';
import 'package:tfsappv1/services/constants.dart';
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

  goToTheSealScreen() {
    Navigator.push(context,
        new MaterialPageRoute(builder: (__) => new SealScreen(exportData)));
  }

  Future verify(String tpNumbere, String token) async {
    // String userId = await SharedPreferences.getInstance()
    //     .then((prefs) => prefs.getInt('user_id').toString());
    // String checkpointId = await SharedPreferences.getInstance()
    //     .then((prefs) => prefs.getInt('checkpointId').toString());

    print(tpNumbere);
    print("gfgjhjkm");
    // print(userId.toString());
    // print(checkpointId.toString());
    try {
      print(tpNumbere);
      print("gfgjhjkm");
      var headers = {"Authorization": "Bearer " + token};
      var url = Uri.parse('$baseUrl/v1/export/find/$tpNumbere');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print('dfsjjdsfsd');
      //final sharedP prefs=await
      res = json.decode(response.body);
      print(res);
      // print('dfsjjdsfsd');
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            exportData = res['export'];
            goToTheSealScreen();
            print(res);
          });
          break;

        case 500:
          setState(() {
            message("Error Occured While Processing Request", "error");
            res = response.body;
            print(res);
          });
          break;
        default:
          setState(() {
            message("Error Occured While Processing Request", "error");
            res = json.decode(response.body);
            print(res);
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        message("Error Occured While Processing Request", "error");
        print(res);
      });
    }
  }

  Future _scanQR() async {
    try {
      String? barcodeScanRes = await scanner.scan();
      var x = barcodeScanRes == null ? null : barcodeScanRes.substring(19, 28);
      String tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token').toString());

      if (x != null) {
        setState(() {
          isVerify = true;
        });

        await verify(x, tokens);
        setState(() {
          isVerify = false;
        });
      } else {
        // enterTpNoPrompt(tokens);
      }

      setState(() {
        result = barcodeScanRes.toString();
      });
    } on PlatformException catch (ex) {
      if (ex.code == scanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
        message(result, 'error');
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
        message(result, 'error');
      }
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

  final List<DropdownMenuItem<String>> _permitType = [
    DropdownMenuItem(
      child: new Text("Export Inspection"),
      value: "Export Inspection",
    ),
    DropdownMenuItem(
      child: new Text("Import Inspection"),
      value: "Import Inspection",
    ),
    DropdownMenuItem(
      child: new Text("Grading"),
      value: "Grading",
    ),
    DropdownMenuItem(
      child: new Text("Verification And Seal"),
      value: "Verification And Seal",
    ),
  ];

  Future getData() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrl/api/v1/export/grade-view');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            data = res['exports'];
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  Future getDataImport() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrl/api/v1/import/insp-view');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            data = res['imports'];
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  Future getDataInspection() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);

      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrl/api/v1/export/insp-view');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            data = res['exports'];
            //  print(data[0]["dealer"].toString() + "hjsdkjdskjdsjk");
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
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
          child: Text(
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

  @override
  Widget build(BuildContext context) {
    String args = ModalRoute.of(context)!.settings.arguments.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Export & Import Management',
          style: TextStyle(
              fontFamily: 'Ubuntu', color: Colors.black, fontSize: 15),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: getProportionateScreenHeight(700),
              child: Column(
                children: <Widget>[
                  Container(
                    height: getProportionateScreenHeight(140),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: getProportionateScreenHeight(90),
                          decoration: BoxDecoration(
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
                                  child: Container(
                                    child: DropdownButtonFormField(
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                0, 5.5, 0, 0),
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
                        ),
                      ],
                    ),
                  ),
                  // Adding the List here
                  type == 'Verification And Seal'
                      ? Container()
                      : isLoading
                          ? SpinKitCircle(
                              color: kPrimaryColor,
                            )
                          : data.isEmpty
                              ? Center(
                                  child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Card(
                                    elevation: 10,
                                    child: Container(
                                        // height: getProportionateScreenHeight(40),
                                        // width: getProportionateScreenWidth(200),
                                        child: ListTile(
                                      title: Text('Data Not Found'),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.pink,
                                        child: Icon(Icons.hourglass_empty),
                                      ),
                                    )),
                                  ),
                                ))
                              : Padding(
                                  padding: EdgeInsets.all(10),
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
                                                  child: Container(
                                                    child: ListTile(
                                                      onTap: () {
                                                        type == 'Grading'
                                                            ? Navigator.pushNamed(
                                                                context,
                                                                Grading
                                                                    .routeName,
                                                                arguments: data[
                                                                            index]
                                                                        ["id"]
                                                                    .toString())
                                                            : Navigator
                                                                .pushNamed(
                                                                context,
                                                                InspectionForm
                                                                    .routeName,
                                                                arguments: InspectionArguments(
                                                                    data[index][
                                                                            "id"]
                                                                        .toString(),
                                                                    type!),
                                                              );
                                                      },
                                                      trailing: Icon(
                                                        Icons.arrow_right,
                                                        color: Colors.cyan,
                                                      ),
                                                      leading: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.purple,
                                                          child: Text(
                                                              '${index + 1}')),
                                                      title: Text(type! ==
                                                              'Grading'
                                                          ? "Name: " +
                                                              data[index][
                                                                      "exporter_name"]
                                                                  .toString()
                                                          : type ==
                                                                  'Export Inspection'
                                                              ? "Name: " +
                                                                  data[index][
                                                                          "exporter_name"]
                                                                      .toString()
                                                              : "Name: " +
                                                                  data[index][
                                                                          "importer_name"]
                                                                      .toString()),
                                                      subtitle: Text(
                                                          'ID Code: ' +
                                                              data[index]
                                                                      ["code"]
                                                                  .toString()),
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
                          ? SpinKitCircle(
                              color: kPrimaryColor,
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: getProportionateScreenHeight(200),
                                child: Center(
                                  child: Card(
                                    elevation: 10,
                                    child: ListTile(
                                      onTap: () async {
                                        await _scanQR();
                                      },
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.pink,
                                        child: Icon(Icons.qr_code),
                                      ),
                                      title: Text('Click To Verify And Seal'),
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
