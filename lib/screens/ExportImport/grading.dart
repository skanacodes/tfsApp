import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/gradingModal.dart';
import 'package:tfsappv1/services/size_config.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class Grading extends StatefulWidget {
  static String routeName = "/grading";
  Grading({Key? key}) : super(key: key);

  @override
  _GradingState createState() => _GradingState();
}

class _GradingState extends State<Grading> {
  bool isLoading = false;
  String local = '';
  String? paid;
  String? receiptNo;
  var bytes;
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  String? volume;
  String imageErr = ' ';

  String quantity = '';
  List data = [];
  bool showPermitType = false;
  bool showPackagingMaterial = false;
  final _formKey = GlobalKey<FormState>();
  // final _formKey1 = GlobalKey<FormState>();
  List? beeProduct;
  String? ask1;
  List<String> ask = [
    'Prime',
    'Select',
    'Standard',
    'Specified',
  ];
  bool isSigned = false;
  String? classy;
  String img1 = '';
  String img2 = '';

  bool isImageTaken = false;
  bool isImageTaken1 = false;
  final String uploadUrl = 'https://api.imgur.com/3/upload';

  //DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future getCategory() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrl/api/v1/export/grade-cats');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            data = res['categories'];
            print(res);
          });
          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        print(res);
      });
    }
  }

  _handleSaveButtonPressed() async {
    final data =
        await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
    final byte = await data.toByteData(
      format: ui.ImageByteFormat.png,
    );
    var path = signatureGlobalKey.currentState!.toPathList();
    print(path);
    // getting a directory path for saving
    Directory appDocDir = await getApplicationDocumentsDirectory();
    print(appDocDir);
    String appDocPath = appDocDir.path;
    print(appDocPath);
    String imageName = 'mark';
    setState(() {
      bytes = byte!.buffer.asUint8List();
    });

    File('$appDocPath/$imageName.png')
        .writeAsBytesSync(byte!.buffer.asInt8List());
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    print(tokens);
    print(bytes);

    Navigator.pop(context);
  }

  alertDialog1() {
    return Alert(
        context: context,
        content: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Enter Idenfication Mark",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: getProportionateScreenHeight(160),
                  width: double.infinity,
                  child: SfSignaturePad(
                      key: signatureGlobalKey,
                      backgroundColor: Colors.white,
                      strokeColor: Colors.black,
                      onDrawStart: () {
                        return false;
                      },
                      onDrawEnd: () {
                        setState(() {
                          isSigned = true;
                        });
                      },
                      minimumStrokeWidth: 1.0,
                      maximumStrokeWidth: 2.0),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                Expanded(
                  //flex: 4,
                  child: Container(
                    child: Text(
                      "Clear Mark",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ),
                Expanded(
                  // flex: 4,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 15.sp,
                    child: IconButton(
                        //color: Colors.red,
                        iconSize: 15.sp,
                        onPressed: () =>
                            signatureGlobalKey.currentState!.clear(),
                        icon: Icon(Icons.clear)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                " $formattedDate",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () async => _handleSaveButtonPressed(),
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
          text: ' Grad',
          style: GoogleFonts.portLligatSans(
            //  textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: 'ing',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0.sp,
              ),
            ),
            TextSpan(
              text: ' Form',
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

  Future<String> uploadData(jobId, exportId) async {
    try {
      // print(jobId);
      // print(exportId);
      // print(bytes);
      // print("am here");
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);

      var headers = {"Authorization": "Bearer " + tokens!};
      BaseOptions options = new BaseOptions(
          baseUrl: "$baseUrl",
          connectTimeout: 50000,
          receiveTimeout: 50000,
          headers: headers);
      var dio = Dio(options);
      var formData = FormData.fromMap({
        'grading_id': jobId,
        'export_id': exportId,
        'category_id': classy,
        'no_of_pieces': quantity,
        'grading_class': ask1,
        'volume': volume,
        'identification_mark': base64Encode(bytes)
      });

      var response = await dio.post('$baseUrl/api/v1/export/grade/store',
          data: formData, onSendProgress: (int sent, int total) {
        // setState(() {
        //   uploadMessage = sent.toString();
        // });
        print('$sent $total');
      });
      print(response.statusCode);
      print(response.statusMessage);
      var res = response.data;
      print(res);
      if (response.statusCode == 201) {
        //var res = json.decode(response.data);
        var res = response.data;
        print(res);
        setState(() {
          classy = null;
        });
        message('success', 'Data Submitted Successfull');
        return 'success';
      } else {
        message('error', 'Failed To Save Data');
        return 'fail';
      }
    } on DioError catch (e) {
      print('dio package');
      if (DioErrorType.receiveTimeout == e.type ||
          DioErrorType.connectTimeout == e.type) {
        message('error', 'Server Can Not Be Reached.');
        // throw Exception('Server Can Not Be Reached');
        print(e);

        setState(() {
          isLoading = false;
        });
        return 'fail';
      } else if (DioErrorType.response == e.type) {
        // throw Exception('Server Can Not Be Reached');

        message('error', 'Failed To Get Response From Server.');
        // throw Exception('Server Can Not Be Reached');
        print(e);
        setState(() {
          isLoading = false;
        });
        return 'fail';
      } else if (DioErrorType.other == e.type) {
        if (e.message.contains('SocketException')) {
          // throw Exception('Server Can Not Be Reached');
          message('error', 'Network Connectivity Problem.');

          print(e);
          setState(() {
            isLoading = false;
          });
          return 'fail';
        }
      } else {
        //  throw Exception('Server Can Not Be Reached');
        message('error',
            'Network Connectivity Problem. Data Has Been Stored Localy');
        // throw Exception('Server Can Not Be Reached');
        print(e);
        setState(() {
          isLoading = false;
        });
        return 'fail';
      }
      return 'fail';
    }
  }

  grandingMark() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              // height: getProportionateScreenHeight(800),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Draw Grading Mark",
                          style: TextStyle(fontSize: 16),
                        ),
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.red,
                          child: Center(
                            child: IconButton(
                              onPressed: () =>
                                  signatureGlobalKey.currentState!.clear(),
                              icon: Icon(
                                Icons.undo_sharp,
                                size: 17,
                              ),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.green,
                          child: Center(
                            child: IconButton(
                                onPressed: () async {
                                  await _handleSaveButtonPressed();
                                  //Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.mark_chat_read_outlined,
                                  color: Colors.black,
                                  size: 17,
                                )),
                          ),
                        ),
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.grey,
                          child: Center(
                            child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: Colors.black,
                                  size: 17,
                                )),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Container(
                        height: getProportionateScreenHeight(550),
                        width: double.infinity,
                        child: SfSignaturePad(
                            key: signatureGlobalKey,
                            backgroundColor: Colors.white,
                            strokeColor: Colors.black,
                            onDrawStart: () {
                              return false;
                            },
                            onDrawEnd: () {
                              setState(() {
                                isSigned = true;
                              });
                            },
                            minimumStrokeWidth: 1.0,
                            maximumStrokeWidth: 2.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey))),
                  ),
                  Container(
                    height: getProportionateScreenHeight(50),
                  )
                ],
              ),
            ),
          );
        });
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

  Widget _submitButton(String jobid, String exportId) {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          setState(() {
            isLoading = true;
          });

          var x = await uploadData(jobid, exportId);

          ask1 = null;
          setState(() {
            print(x);

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

  @override
  void initState() {
    RealTimeCommunication().createConnection(
      "15",
    );
    this.getCategory();
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GradingArguments;
    print(args.id);
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
                  forms(args.id, args.exportId)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  forms(id, exportId) {
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
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 18, left: 18),
                      child: SafeArea(
                        child: data.isEmpty
                            ? SpinKitFadingCircle(
                                color: kPrimaryColor,
                                size: 35.0.sp,
                              )
                            : Container(
                                child: new DropdownButtonFormField(
                                  itemHeight: 50,
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.cyan,
                                        ),
                                      ),
                                      fillColor: Color(0xfff3f3f4),
                                      filled: true,
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(30, 10, 15, 10),
                                      labelText: "Select Category",
                                      border: InputBorder.none),
                                  isExpanded: true,
                                  isDense: true,
                                  validator: (value) => value == null
                                      ? "This Field is Required"
                                      : null,
                                  items: data.map((item) {
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
                                          item['name'].toString(),
                                        ),
                                      ),
                                      value: item['id'].toString(),
                                    );
                                  }).toList(),
                                  onChanged: (newVal) {
                                    setState(() {
                                      classy = newVal.toString();
                                      print(classy);
                                    });
                                  },
                                  value: classy,
                                ),
                              ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          key: Key("No"),
                          onSaved: (val) => quantity = val!,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true,
                            labelText: "No. Of Pieces",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(30, 10, 15, 10),
                          ),
                          validator: (value) {
                            if (value == '') return "This Field Is Required";
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          key: Key("vol"),
                          onSaved: (val) => volume = val!,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true,
                            labelText: "Volume",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(30, 10, 15, 10),
                          ),
                          validator: (value) {
                            if (value == '') return "This Field Is Required";
                            return null;
                          },
                        ),
                      ),
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
                                labelText: "Select Grading Class",
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
                              return null;
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
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 5, right: 16, left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Card(
                              elevation: 5,
                              child: ListTile(
                                onTap: () {
                                  grandingMark();
                                },
                                title: Text('Write Grading Mark'),
                                leading: Icon(
                                  isSigned
                                      ? Icons.verified
                                      : Icons.pending_actions,
                                  color: isSigned ? kPrimaryColor : Colors.red,
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Flexible(
                              flex: 2,
                              child: InkWell(
                                onTap: () async {
                                  isSigned
                                      ? await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return Scaffold(
                                                appBar: AppBar(),
                                                body: Center(
                                                  child: Container(
                                                    color: Colors.grey[300],
                                                    child: Image.memory(bytes
                                                        .buffer
                                                        .asUint8List()),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Container();
                                },
                                child: Container(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _submitButton(id, exportId),
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
