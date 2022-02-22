import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/services/constants.dart';

import 'package:tfsappv1/services/size_config.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:tfsappv1/services/textFieldConstant.dart';

class PosReg extends StatefulWidget {
  static String routeName = "/POSmanager";
  PosReg({Key? key}) : super(key: key);

  @override
  _PosRegState createState() => _PosRegState();
}

class _PosRegState extends State<PosReg> {
  bool isLoading = false;

  String? issuedDate;
  String? androidId;
  String? brand;
  static const platform1 = MethodChannel(
    'samples.flutter.dev/deviceInfo',
  );
  late TextEditingController _posnameController;
  TextEditingController? _serialNoController;
  TextEditingController? _imei1Controller;
  TextEditingController? _imei2Controller;
  TextEditingController? _issueByController;
  TextEditingController? _brandController;
  TextEditingController? _androidIdController;

  final _formKey = GlobalKey<FormState>();
  bool isDevice = false;
  var deviceInfo;
  String? ask1;
  List<String> ask = [
    'Operational',
    'Maintenance',
    'Out Of Service',
    'New',
  ];

  Future<void> _getDeviceInfo() async {
    try {
      var result =
          await platform1.invokeMethod('getDeviceInfo', {"operation": "1"});

      print(result);
      if (result == "Not Supported") {
        setState(() {
          isDevice = true;
        });
      } else {
        setState(() {
          deviceInfo = result;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  //DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    print(picked);
    setState(() {
      formattedDate = DateFormat('yyyy-MM-dd').format(picked!);
    });
    return picked;
  }

  Future getUpload() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var stationId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getInt('station_id'));
      var checkpoint = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('checkpointId'));
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrl/api/v1/pos-reg');

      final response = await http.post(url,
          body: {
            "android_id": deviceInfo['android_id'].toString(),
            "station_id": stationId.toString(),
            "pos_name": _posnameController.text,
            "imei_1": deviceInfo["imeiSim1"].toString(),
            "imei_2": deviceInfo["imeiSim2"].toString(),
            "checkpoint_id": checkpoint,
            "brand": deviceInfo["brand"].toString(),
            "serial_no": _serialNoController!.text,
            "status": ask1,
            "issue_date": formattedDate,
            "issued_by": _issueByController!.text
          },
          headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          setState(() {
            res = json.decode(response.body);
            //data = res['categories'];
            message("success", "Successfull Registering POS");
            print(res);
          });
          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            message("error", "Something Went Wrong");
            print(res);
          });
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            message("error", "Something Went Wrong");
            print(res);
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        message("error", "Something Went Wrong");
        print(res);
      });
    }
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
          text: ' Regi',
          style: GoogleFonts.portLligatSans(
            //  textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: 'ster',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0.sp,
              ),
            ),
            TextSpan(
              text: ' POS',
              style: TextStyle(
                color: Colors.green[200],
                fontSize: 15.0.sp,
              ),
            ),
          ]),
    );
  }

  message(String hint, String message) {
    return Alert(
      context: context,
      type: hint == "error" ? AlertType.error : AlertType.success,
      title: "Information",
      desc: message,
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

  clearTextInput() {
    setState(() {
      ask1 = null;
      _imei1Controller!.clear();
      _imei2Controller!.clear();

      _serialNoController!.clear();
      _issueByController!.clear();
    });
    _posnameController = TextEditingController();
    _imei1Controller = TextEditingController();
    _imei2Controller = TextEditingController();
    _serialNoController = TextEditingController();
    _issueByController = TextEditingController();
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          print(_imei1Controller!.text);
          setState(() {
            isLoading = true;
          });
          await getUpload();
          setState(() {
            clearTextInput();
            isLoading = false;
          });
          _formKey.currentState!.reset();
        }
      },
      child: isLoading
          ? SpinKitCircle(
              color: kPrimaryColor,
            )
          : Container(
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
                      colors: [kPrimaryColor, Colors.green[100]!])),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
    );
  }

  getDetails() async {
    var androiIds = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('deviceId'));
    var brands = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('brand'));
    print(androiIds);
    print(brands);
    setState(() {
      androidId = androiIds;
      brand = brands;
    });
  }

  @override
  void initState() {
    _getDeviceInfo();
    _posnameController = TextEditingController();
    _imei1Controller = TextEditingController();
    _imei2Controller = TextEditingController();
    _serialNoController = TextEditingController();
    _issueByController = TextEditingController();
    RealTimeCommunication().createConnection('4');
    this.getDetails();

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _posnameController.dispose();
    _imei1Controller!.dispose();
    _imei2Controller!.dispose();
    _serialNoController!.dispose();
    _issueByController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)!.settings.arguments as GradingArguments;

    // print(args.personId);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          ' ',
          style: TextStyle(
              fontFamily: 'Ubuntu', color: Colors.black, fontSize: 17),
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
                    height: getProportionateScreenHeight(110),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: getProportionateScreenHeight(60),
                          decoration: BoxDecoration(
                            // borderRadius: BorderRadius.only(
                            //     bottomLeft: Radius.circular(100),
                            //     bottomRight: Radius.circular(100)),
                            color: kPrimaryColor,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Card(
                              elevation: 20,
                              child: ListTile(
                                  tileColor: Colors.white,
                                  title: _title(),
                                  trailing:
                                      Icon(Icons.document_scanner_rounded),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.pink,
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.black,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Adding the form here
                  deviceInfo == null
                      ? Center(
                          child: Text(
                              "Your Device Is Not Supported For Registration"),
                        )
                      : forms()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  forms() {
    //print(deviceInfo["imeiSim2"].toString());
    return
        // Adding the form here
        Form(
      key: _formKey,
      child: Expanded(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                elevation: 10,
                shadowColor: kPrimaryColor,
                child: Column(
                  children: <Widget>[
                    TextFieldConstant(
                      textName: _androidIdController,
                      enabled: false,
                      textValue: deviceInfo["android_id"].toString(),
                      hintText: "Android_ID: ",
                    ),
                    TextFieldConstant(
                      textName: _brandController,
                      enabled: false,
                      textValue: deviceInfo["brand"].toString(),
                      hintText: "Brand",
                    ),
                    TextFieldConstant(
                      textName: _imei1Controller,
                      enabled: false,
                      textValue: deviceInfo["imeiSim1"].toString(),
                      hintText: "IMEI Sim1",
                    ),
                    TextFieldConstant(
                      textName: _imei2Controller,
                      enabled: false,
                      textValue: deviceInfo["imeiSim2"].toString(),
                      hintText: "IMEI Sim2",
                    ),
                    TextFieldConstant(
                      textName: _serialNoController,
                      enabled: true,
                      hintText: "Serial Number ",
                    ),
                    TextFieldConstant(
                      textName: _posnameController,
                      hintText: "POS Name",
                      enabled: true,
                    ),
                    TextFieldConstant(
                      textName: _issueByController,
                      hintText: "Issued By",
                      enabled: true,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                          child: Card(
                        elevation: 1,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            child: Icon(Icons.calendar_today),
                          ),
                          onTap: () {
                            _selectDate(context);
                          },
                          title: Text(
                            'Issuing Date: $formattedDate',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      )),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 1, right: 16, left: 16),
                        child: Container(
                          // width: getProportionateScreenHeight(
                          //     320),
                          child: DropdownButtonFormField<String>(
                            itemHeight: 50,
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.cyan,
                                  ),
                                ),
                                fillColor: Color(0xfff3f3f4),
                                filled: true,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(30, 10, 15, 10),
                                labelText: "Select POS Status",
                                border: InputBorder.none),
                            isExpanded: true,

                            value: ask1,
                            //elevation: 5,
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Ubuntu'),
                            iconEnabledColor: Colors.black,
                            items: ask
                                .map<DropdownMenuItem<String>>((String value) {
                              return new DropdownMenuItem(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0xfff3f3f4),
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1, color: kPrimaryColor),
                                    ),
                                  ),
                                  child: new Text(
                                    value,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                value: value,
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return "This Field is required";
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                ask1 = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _submitButton(),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(30),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
