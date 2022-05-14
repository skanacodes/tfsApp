// ignore_for_file: unused_import, prefer_typing_uninitialized_variables, deprecated_member_use, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/verification/scanQr.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class AfterVerification extends StatefulWidget {
  final tpData;
  final previousCheckpoint;
  final tpProduct;
  final bool isAlreadyVerified;
  final String? verificationCode;
  const AfterVerification(
      {Key? key, required this.tpData,
      required this.previousCheckpoint,
      required this.tpProduct,
      required this.isAlreadyVerified,
      this.verificationCode}) : super(key: key);
  @override
  _AfterVerificationState createState() => _AfterVerificationState();
}

class _AfterVerificationState extends State<AfterVerification> {
  final GlobalKey<ExpansionTileCardState> cardA = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardB = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardC = GlobalKey();
  String img1 = '';
  String img2 = '';
  late PickedFile _imageFile;
  late PickedFile _imageFile1;
  bool isImageTaken = false;
  bool isImageTaken1 = false;
  final ImagePicker _picker = ImagePicker();
  String imageErr = ' ';
  bool isLoading = false;
  String? qn;
  String? quantityExceeded;
  String? otherOffence;
  String? offenceTypeVal;
  int? _compoundingTimesVal;
  int marketValue = 0;
  final _formKey = GlobalKey<FormState>();
  String verCode = "";

  //DateTime now = DateTime.now();

  final formKey = GlobalKey<FormState>();
  final List<DropdownMenuItem<String>> _qnType = [
    const DropdownMenuItem(
      child: Text("Laggage As Per TP"),
      value: "Laggage As Per TP",
    ),
    const DropdownMenuItem(
      child: Text("TP Offence"),
      value: "TP Offence",
    ),
  ];
  final List<DropdownMenuItem<int>> _compoundingTimes = [
    const DropdownMenuItem(
      child: Text("1"),
      value: 1,
    ),
    const DropdownMenuItem(
      child: Text("2"),
      value: 2,
    ),
    const DropdownMenuItem(
      child: Text("3"),
      value: 3,
    ),
    const DropdownMenuItem(
      child: Text("4"),
      value: 4,
    ),
    const DropdownMenuItem(
      child: Text("5"),
      value: 5,
    ),
  ];
  final List<DropdownMenuItem<String>> offenceType = [
    const DropdownMenuItem(
      child: Text("Laggage Exceed TP"),
      value: "Laggage Exceed TP",
    ),
    const DropdownMenuItem(
      child: Text("Other, Specify"),
      value: "Other",
    ),
  ];
  Future<void> retriveLostData(var _imageFile) async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file!;
      });
    } else {
      print('Retrieve error ' + response.exception!.code);
    }
  }

  verificationMessage(String hint, String message) {
    return Alert(
      context: context,
      type: hint == "info" ? AlertType.info : AlertType.success,
      title: "",
      desc: message,
      buttons: [
        DialogButton(
          color: kPrimaryColor,
          radius: const BorderRadius.all(Radius.circular(10)),
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              isLoading = true;
            });

            qn != "TP Offence" ? await uploadTPData() : await reportIssue();

            setState(() {
              isLoading = false;
            });
          },
          width: 120,
        ),
        DialogButton(
          color: Colors.red,
          radius: const BorderRadius.all(Radius.circular(10)),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
          width: 120,
        )
      ],
    ).show();
  }

  void _pickImage(int numb) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      final pickedFile = await _picker.getImage(
        source: ImageSource.camera,
        imageQuality: 40,
        preferredCameraDevice: CameraDevice.rear,
      );
      await Future.delayed(const Duration(milliseconds: 100));
      if (pickedFile != null) {
        setState(() {
          numb == 1 ? _imageFile = pickedFile : _imageFile1 = pickedFile;

          numb == 1 ? isImageTaken = true : isImageTaken1 = true;
        });
        final File file = File(numb == 1 ? _imageFile.path : _imageFile1.path);
        // getting a directory path for saving
        Directory appDocDir = await getApplicationDocumentsDirectory();
        print(appDocDir);
        String appDocPath = appDocDir.path;
        print(appDocPath);
        final fileName =
            path.basename(numb == 1 ? _imageFile.path : _imageFile1.path);
        print(fileName);
// copy the file to a new path
        final File newImage = await file.copy('$appDocPath/$fileName');
        print(newImage);
        setState(() {
          numb == 1 ? img1 = newImage.path : img2 = newImage.path;
        });
        print(img1);
      } else {
        print("Error While Taking Picture");
      }
    } catch (e) {
      print("Image picker error " + e.toString());
    }
  }

  Widget _previewImage(var _imageFile) {
    // ignore: unnecessary_null_comparison
    if (_imageFile != null) {
      return Image.file(File(_imageFile.path));
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
          text: 'Transit',
          style: GoogleFonts.portLligatSans(
            // textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: ' Pass ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0.sp,
              ),
            ),
            TextSpan(
              text: ' Details',
              style: TextStyle(
                color: Colors.green[200],
                fontSize: 15.0.sp,
              ),
            ),
          ]),
    );
  }

  Future<String> reportIssue() async {
    var station = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt('station_id'));
    var checkpoint = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('checkpointId'));
    var userId = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt('user_id'));

    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));

    // print(tokens);
    var headers = {"Authorization": "Bearer " + tokens!};
    print("nipo");
    //var username = fname! + " " + lname!;
    try {
      var url = Uri.parse('$baseUrlTest/api/v1/tp-offense/store');

      var compound = (_compoundingTimesVal == null
              ? 1
              : _compoundingTimesVal! * marketValue)
          .toString();
      final response = await http.post(
        url,
        headers: headers,
        body: {
          'checkpoint_id': checkpoint.toString(),
          'station_id': station.toString(),
          'reported_by': userId.toString(),
          'offence_type': offenceTypeVal,
          'compound_value': compound
        },
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          setState(() {
            res = json.decode(response.body);
            print(res);
            message('success', 'The Case Has Been Reported');
          });

          return 'success';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);

            isLoading = false;
          });
          return 'fail';
          // ignore: dead_code
          break;
      }
    } catch (e) {
      setState(() {
        print(e);

        isLoading = false;
      });
      return 'fail';
    }
  }

  Future<String> uploadTPData() async {
    // print("am here");
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      String checkpointId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('checkpointId').toString());
      String userId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getInt('user_id').toString());
      print(tokens);
      print(checkpointId);
      print(userId);
      print(widget.tpData['tp_number'].toString());

      var headers = {"Authorization": "Bearer " + tokens!};

      BaseOptions options = BaseOptions(
          baseUrl: "https://mis.tfs.go.tz/fremis-test",
          connectTimeout: 50000,
          receiveTimeout: 50000,
          headers: headers);
      var dio = Dio(options);
      var formData = FormData.fromMap({
        "tp_number": widget.tpData['tp_number'].toString(),
        "user_id": userId.toString(),
        "checkpoint_id": checkpointId.toString(),
        "is_valid": "true",
        "consignment_image[]": [
          await MultipartFile.fromFile(
            img1,
            filename: "image",
          ),
          await MultipartFile.fromFile(
            img2,
            filename: "images",
          ),
        ],
      });

      var response =
          await dio.post('https://mis.tfs.go.tz/fremis-test/api/v1/verify-tp',
              // options: Options(headers: headers),
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
        setState(() {
          verCode = res['code'];
        });

        message('success', 'Successfull!.. Verification Code is $verCode');
        return 'success';
      } else {
        message('fail', 'Failed To Save Data');
        return 'fail';
      }
    } on DioError catch (e) {
      print('dio package');
      if (DioErrorType.receiveTimeout == e.type ||
          DioErrorType.connectTimeout == e.type) {
        message('error', 'Server Can Not Be Reached.');
        print(e.message);
        // throw Exception('Server Can Not Be Reached');

        setState(() {
          isLoading = false;
        });
        return 'fail';
      } else if (DioErrorType.response == e.type) {
        // throw Exception('Server Can Not Be Reached');
        // print(e.message);
        // print("qerqf");
        message('error', 'Already Verified At This Checkpoint.');
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
          print(e.message);
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
        print(e.message);
        setState(() {
          isLoading = false;
        });
        return 'fail';
      }
      return 'fail';
    }
  }

  message(String hint, String message) {
    return Alert(
      context: context,
      type: hint == "error" ? AlertType.error : AlertType.success,
      title: "Information",
      desc: message,
      buttons: [
        DialogButton(
          child: const Text(
            "Ok",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          width: 120,
        )
      ],
    ).show();
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          verificationMessage(
              "info", "Are You Sure You Want To Mark This TP as right");
        }
      },
      child: isLoading
          ? const SpinKitCircle(
              color: kPrimaryColor,
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: const Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [kPrimaryColor, Colors.green[200]!])),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
    );
  }

  Widget _reportButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          verificationMessage(
              "info", "Are You Sure You Want To Report This TP");
        }
      },
      child: isLoading
          ? const SpinKitCircle(
              color: kPrimaryColor,
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: const Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [kPrimaryColor, Colors.green[200]!])),
              child: const Text(
                'Report This TP',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
    );
  }

  @override
  void initState() {
    RealTimeCommunication().createConnection(
      "8",
    );
    widget.isAlreadyVerified
        ? Future.delayed(Duration.zero, () {
            message("success",
                "Already Verified At This Checkpoint with Verification Code ${widget.verificationCode}");
          })
        : null;
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(qn! + " shbdfhb");
    // print(widget.tpData);
    // print(widget.tpProduct);
    // print(widget.previousCheckpoint);
    int len = widget.previousCheckpoint == null
        ? 0
        : widget.previousCheckpoint.length;

    print(len);
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: getProportionateScreenHeight(130),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: getProportionateScreenHeight(90),
                  decoration: const BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //     bottomLeft: Radius.circular(150),
                    //     bottomRight: Radius.circular(150)),
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
                          trailing: const Icon(
                            Icons.data_saver_off,
                            color: Colors.cyan,
                          ),
                          leading: const CircleAvatar(
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
          SizedBox(
            height: getProportionateScreenHeight(10),
          ),
          verCode != ""
              ? Container()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ExpansionTileCard(
                    key: cardA,
                    expandedTextColor: Colors.black,
                    shadowColor: kPrimaryColor,
                    duration: const Duration(milliseconds: 500),
                    animateTrailing: true,
                    baseColor: const Color(0xfff3f3f4),
                    elevation: 10,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    leading: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.data_usage_rounded,
                          color: kPrimaryColor,
                        )),
                    title: const Text('Transit Pass Informations'),
                    children: <Widget>[
                      const Divider(
                        thickness: 1.0,
                        height: 1.0,
                        color: Colors.cyan,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.person_pin,
                                color: Colors.purple,
                              )),
                          const Expanded(flex: 3, child: Text('Dealer : ')),
                          Expanded(
                              flex: 4,
                              child: Text(widget.tpData['dealer'].toString()))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.format_list_numbered,
                                color: Colors.pink,
                              )),
                          const Expanded(flex: 3, child: Text('TP Number : ')),
                          Expanded(
                              flex: 4,
                              child:
                                  Text(widget.tpData['tp_number'].toString()))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.pin_drop,
                                color: Colors.amber,
                              )),
                          const Expanded(flex: 3, child: Text('Source : ')),
                          Expanded(
                              flex: 4,
                              child: Text(widget.tpData['source'].toString()))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.location_city_rounded,
                                color: kPrimaryColor,
                              )),
                          const Expanded(flex: 3, child: Text('Destination : ')),
                          Expanded(
                              flex: 4,
                              child:
                                  Text(widget.tpData['destination'].toString()))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.car_rental,
                                color: Colors.brown,
                              )),
                          const Expanded(flex: 3, child: Text('Vehicle Number : ')),
                          Expanded(
                              flex: 4,
                              child:
                                  Text(widget.tpData['vehicle_no'].toString()))
                        ],
                      ),
                      widget.tpData['trailer_no'].toString() == "null"
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.traffic,
                                      color: Colors.indigoAccent,
                                    )),
                                const Expanded(
                                    flex: 3, child: Text('Trailer Number : ')),
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                        widget.tpData['trailer_no'].toString()))
                              ],
                            ),
                      widget.tpData['forest_name'].toString() == "null"
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.nature_outlined,
                                      color: Colors.green,
                                    )),
                                const Expanded(
                                    flex: 3, child: Text('Forest Name : ')),
                                Expanded(
                                    flex: 4,
                                    child: Text(widget.tpData['forest_name']
                                        .toString()))
                              ],
                            ),
                      widget.tpData['vehicle_capacity'].toString() == "null"
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.line_weight_rounded,
                                      color: Colors.deepOrangeAccent,
                                    )),
                                const Expanded(
                                    flex: 3,
                                    child: Text('Vehicle Capacity : ')),
                                Expanded(
                                    flex: 4,
                                    child: Text(widget
                                            .tpData['vehicle_capacity']
                                            .toString() +
                                        " Tons"))
                              ],
                            ),
                      widget.tpData['transport_mode'].toString() == "null"
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.add_road_outlined,
                                      color: Colors.black,
                                    )),
                                const Expanded(
                                    flex: 3, child: Text('Transport Mode : ')),
                                Expanded(
                                    flex: 4,
                                    child: Text(widget.tpData['transport_mode']
                                        .toString()))
                              ],
                            ),
                      widget.tpData['receipt_no'].toString() == "null"
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.receipt,
                                      color: Colors.grey,
                                    )),
                                const Expanded(
                                    flex: 3, child: Text('Receipt Number : ')),
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                        widget.tpData['receipt_no'].toString()))
                              ],
                            ),
                      widget.tpData['receipt_date'].toString() == "null"
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: Colors.cyan,
                                    )),
                                const Expanded(
                                    flex: 3, child: Text('Receipt Date : ')),
                                Expanded(
                                    flex: 4,
                                    child: Text(widget.tpData['receipt_date']
                                        .toString()))
                              ],
                            ),
                      widget.tpData['issued_by'].toString() == "null"
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.supervised_user_circle_outlined,
                                      color: Colors.red,
                                    )),
                                const Expanded(flex: 3, child: Text('Issued By : ')),
                                Expanded(
                                    flex: 4,
                                    child: Text(widget.tpData['issued_by']
                                        .toString()
                                        .toUpperCase()))
                              ],
                            ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        buttonHeight: 52.0,
                        buttonMinWidth: 90.0,
                        children: <Widget>[
                          TextButton(
                            style: flatButtonStyle,
                            onPressed: () {
                              cardA.currentState?.collapse();
                            },
                            child: Column(
                              children: const <Widget>[
                                Icon(Icons.arrow_upward),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text('Close'),
                              ],
                            ),
                          ),
                          TextButton(
                            style: flatButtonStyle,
                            onPressed: () {
                              cardA.currentState?.collapse();
                              cardB.currentState?.toggleExpansion();
                            },
                            child: Column(
                              children: const <Widget>[
                                Icon(Icons.swap_vert),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text('Next Card'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          verCode != ""
              ? Container()
              : SizedBox(
                  height: getProportionateScreenHeight(10),
                ),
          verCode != ""
              ? Container()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ExpansionTileCard(
                    key: cardB,
                    animateTrailing: true,
                    shadowColor: kPrimaryColor,
                    expandedTextColor: Colors.black,
                    duration: const Duration(milliseconds: 500),
                    baseColor: const Color(0xfff3f3f4),
                    elevation: 10,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),

                    leading: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.car_repair_outlined,
                          color: kPrimaryColor,
                        )),
                    title: const Text('Previous Checkpoints'),
                    // subtitle: Text(''),
                    children: <Widget>[
                      const Divider(
                        thickness: 1.0,
                        height: 1.0,
                        color: Colors.cyan,
                      ),
                      len == 0
                          ? const Center(
                              child: Text('There Is No Previous CheckPoint'),
                            )
                          : Container(),
                      for (var i = 0; i < len; i++)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.point_of_sale_rounded,
                                      color: kPrimaryColor,
                                    )),
                                const Expanded(
                                    flex: 3, child: Text('Check-Point Name: ')),
                                Expanded(
                                    flex: 4,
                                    child: Text(widget.previousCheckpoint[i]
                                                    ['checkpoint_name']
                                                .toString() ==
                                            'null'
                                        ? ''
                                        : widget.previousCheckpoint[i]
                                                ['checkpoint_name']
                                            .toString())),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.star_outline_sharp,
                                      color: Colors.cyan,
                                    )),
                                const Expanded(flex: 3, child: Text('Status : ')),
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      widget.previousCheckpoint[i]['remarks']
                                                  .toString() ==
                                              'null'
                                          ? "Verified"
                                          : widget.previousCheckpoint[i]
                                                  ['remarks']
                                              .toString(),
                                      style: TextStyle(
                                          color: widget.previousCheckpoint[i]
                                                          ['remarks']
                                                      .toString() ==
                                                  'null'
                                              ? Colors.green
                                              : Colors.orange),
                                    ))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.code,
                                      color: Colors.purple,
                                    )),
                                const Expanded(
                                    flex: 3,
                                    child: Text('Verification-Code: ')),
                                Expanded(
                                    flex: 4,
                                    child: Text(widget.previousCheckpoint[i]
                                                    ['verification_code']
                                                .toString() ==
                                            'null'
                                        ? ''
                                        : widget.previousCheckpoint[i]
                                                ['verification_code']
                                            .toString()))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.timelapse_rounded,
                                      color: Colors.pink,
                                    )),
                                const Expanded(
                                    flex: 3,
                                    child: Text('Verification-Time: ')),
                                Expanded(
                                    flex: 4,
                                    child: Text(widget.previousCheckpoint[i]
                                                    ['verified_at']
                                                .toString() ==
                                            'null'
                                        ? ''
                                        : widget.previousCheckpoint[i]
                                                ['verified_at']
                                            .toString()))
                              ],
                            ),
                            const Divider(
                              color: Colors.purple,
                              endIndent: 20,
                            )
                          ],
                        ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        buttonHeight: 52.0,
                        buttonMinWidth: 90.0,
                        children: <Widget>[
                          TextButton(
                            style: flatButtonStyle,
                            onPressed: () {
                              cardA.currentState?.collapse();
                            },
                            child: Column(
                              children: const <Widget>[
                                Icon(Icons.arrow_upward),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text('Close'),
                              ],
                            ),
                          ),
                          TextButton(
                            style: flatButtonStyle,
                            onPressed: () {
                              cardA.currentState?.toggleExpansion();
                            },
                            child: Column(
                              children: const <Widget>[
                                Icon(Icons.swap_vert),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text('Toggle'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          verCode != ""
              ? Container()
              : SizedBox(
                  height: getProportionateScreenHeight(10),
                ),
          verCode != ""
              ? Container()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ExpansionTileCard(
                    key: cardC,
                    duration: const Duration(milliseconds: 500),
                    animateTrailing: true,
                    baseColor: const Color(0xfff3f3f4),
                    expandedTextColor: Colors.black,
                    elevation: 10,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),

                    leading: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.star_purple500_outlined,
                          color: kPrimaryColor,
                        )),
                    title: const Text('Transit Pass Products'),
                    // subtitle: Text(''),
                    children: <Widget>[
                      const Divider(
                        thickness: 1.0,
                        height: 1.0,
                        color: Colors.cyan,
                      ),
                      for (var i = 0; i < widget.tpProduct.length; i++)
                        Column(
                          children: [
                            widget.tpProduct[i]['product_name'].toString() ==
                                    'null'
                                ? Container()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                          flex: 1,
                                          child: Icon(
                                            Icons.ac_unit,
                                            color: kPrimaryColor,
                                          )),
                                      const Expanded(
                                          flex: 3,
                                          child: Text('Product Name : ')),
                                      Expanded(
                                          flex: 4,
                                          child: Text(widget.tpProduct[i]
                                                  ['product_name']
                                              .toString())),
                                    ],
                                  ),
                            widget.tpProduct[i]['quantity'].toString() == 'null'
                                ? Container()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                          flex: 1,
                                          child: Icon(
                                            Icons
                                                .format_list_numbered_rtl_rounded,
                                            color: Colors.cyan,
                                          )),
                                      const Expanded(
                                          flex: 3, child: Text('Quantity : ')),
                                      Expanded(
                                          flex: 4,
                                          child: Text(widget.tpProduct[i]
                                                      ['quantity']
                                                  .toString() +
                                              " " +
                                              widget.tpProduct[i]['unit']
                                                  .toString()))
                                    ],
                                  ),
                            widget.tpProduct[i]['volume'].toString() == 'null'
                                ? Container()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                          flex: 1,
                                          child: Icon(
                                            Icons.aspect_ratio,
                                            color: Colors.purple,
                                          )),
                                      const Expanded(
                                          flex: 3, child: Text('Volume : ')),
                                      Expanded(
                                          flex: 4,
                                          child: Text(widget.tpProduct[i]
                                                  ['volume']
                                              .toString()))
                                    ],
                                  ),
                            const Divider(
                              color: Colors.purple,
                              endIndent: 20,
                            )
                          ],
                        ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        buttonHeight: 52.0,
                        buttonMinWidth: 90.0,
                        children: <Widget>[
                          TextButton(
                            style: flatButtonStyle,
                            onPressed: () {
                              cardC.currentState?.collapse();
                            },
                            child: Column(
                              children: const <Widget>[
                                Icon(Icons.arrow_upward),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text('Close'),
                              ],
                            ),
                          ),
                          TextButton(
                            style: flatButtonStyle,
                            onPressed: () {
                              cardA.currentState?.toggleExpansion();
                            },
                            child: Column(
                              children: const <Widget>[
                                Icon(Icons.swap_vert),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text('Toggle'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          verCode != ""
              ? Container()
              : SizedBox(
                  height: getProportionateScreenHeight(10),
                ),
          widget.isAlreadyVerified
              ? Container()
              : verCode != ""
                  ? Container()
                  : Form(
                      key: _formKey,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 1, right: 16, left: 16),
                          child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    color: Colors.cyan,
                                  ),
                                ),
                                fillColor: const Color(0xfff3f3f4),
                                filled: true,
                                labelText: "Select ",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(30, 10, 15, 10),
                              ),
                              items: _qnType,
                              value: qn,
                              validator: (value) => value == null
                                  ? "This Field is Required"
                                  : null,
                              onChanged: (String? value) {
                                setState(() {
                                  qn = value!;
                                });
                              }),
                        ),
                      ),
                    ),
          SizedBox(
            height: getProportionateScreenHeight(10),
          ),
          qn != "TP Offence"
              ? Container()
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1, right: 16, left: 16),
                    child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.cyan,
                            ),
                          ),
                          fillColor: const Color(0xfff3f3f4),
                          filled: true,
                          labelText: "Capture Type Of Offence",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                        ),
                        items: offenceType,
                        value: offenceTypeVal,
                        validator: (value) =>
                            value == null ? "This Field is Required" : null,
                        onChanged: (String? value) async {
                          setState(() {
                            // value = null;
                            quantityExceeded = null;
                            _compoundingTimesVal = 1;
                            // otherOffence = null;
                            offenceTypeVal = value!;

                            print(offenceTypeVal);
                            print(_compoundingTimes);
                            print(otherOffence);
                          });
                        }),
                  ),
                ),
          qn != "TP Offence"
              ? Container()
              : SizedBox(
                  height: getProportionateScreenHeight(10),
                ),
          qn != "TP Offence"
              ? Container()
              : offenceTypeVal == "Laggage Exceed TP"
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 5, right: 16, left: 16),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            quantityExceeded = val;
                          });
                        },
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.cyan,
                            ),
                          ),
                          fillColor: const Color(0xfff3f3f4),
                          filled: true,
                          labelText: "Quantity Exceeded",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                        ),
                        validator: (value) {
                          if (value == '') return "This Field Is Required";
                          return null;
                        },
                      ),
                    )
                  : offenceTypeVal != "Other"
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(
                              top: 5, right: 16, left: 16),
                          child: TextFormField(
                            maxLines: 4,
                            keyboardType: TextInputType.text,
                            onChanged: (val) {
                              setState(() {
                                otherOffence = val;
                              });
                            },
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: Colors.cyan,
                                ),
                              ),
                              fillColor: const Color(0xfff3f3f4),
                              filled: true,
                              labelText: "Other Offences, Specify",
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(30, 10, 15, 10),
                            ),
                            validator: (value) {
                              if (value == '') {
                                return "This Field Is Required";
                              }
                              return null;
                            },
                          ),
                        ),
          qn != "TP Offence"
              ? Container()
              : SizedBox(
                  height: getProportionateScreenHeight(5),
                ),
          qn != "TP Offence"
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 10, right: 16, left: 16),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          key: const Key("vol"),
                          onChanged: (val) => setState(() {
                            marketValue = int.parse(val);
                          }),
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: const Color(0xfff3f3f4),
                            filled: true,
                            labelText: "Value",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.fromLTRB(30, 10, 15, 10),
                          ),
                          validator: (value) {
                            if (value == '') return "* Required";
                            return null;
                          },
                        ),
                      ),
                    ),
                    offenceTypeVal == "Other"
                        ? Container()
                        : Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, right: 18, left: 18),
                              child: SafeArea(
                                child: DropdownButtonFormField(
                                  itemHeight: 50,
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: const BorderSide(
                                          color: Colors.cyan,
                                        ),
                                      ),
                                      fillColor: const Color(0xfff3f3f4),
                                      filled: true,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.fromLTRB(30, 10, 15, 10),
                                      labelText: "Times",
                                      border: InputBorder.none),
                                  isExpanded: true,
                                  isDense: true,
                                  validator: (value) =>
                                      value == null ? "* Required" : null,
                                  items: _compoundingTimes,
                                  onChanged: (newVal) {
                                    setState(() {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      _compoundingTimesVal =
                                          int.parse(newVal.toString());
                                    });
                                  },
                                  value: _compoundingTimesVal,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
          qn != "TP Offence"
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(top: 10, right: 16, left: 16),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    key: const Key(""),
                    //onSaved: (val) => quantity = val!,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Colors.cyan,
                        ),
                      ),
                      enabled: false,
                      fillColor: const Color(0xfff3f3f4),
                      filled: true,
                      labelText: "Compounding Fee: " +
                          (_compoundingTimesVal == null
                                  ? 1
                                  : _compoundingTimesVal! * marketValue)
                              .toString(),
                      //hintText: verCode,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                    ),
                    validator: (value) {
                      if (value == '') return "This Field Is Required";
                      return null;
                    },
                  ),
                ),
          qn == "TP Offence"
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(top: 10, right: 16, left: 16),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    key: const Key(""),
                    //onSaved: (val) => quantity = val!,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Colors.cyan,
                        ),
                      ),
                      enabled: false,
                      fillColor: const Color(0xfff3f3f4),
                      filled: true,
                      labelText: widget.isAlreadyVerified
                          ? "Verification Code: " +
                              widget.verificationCode.toString()
                          : "Verification Code: $verCode",
                      //hintText: verCode,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                    ),
                    validator: (value) {
                      if (value == '') return "This Field Is Required";
                      return null;
                    },
                  ),
                ),
          qn == "TP Offence"
              ? Container()
              : widget.isAlreadyVerified
                  ? Container()
                  : verCode != ""
                      ? Container()
                      : SizedBox(
                          height: getProportionateScreenHeight(10),
                        ),
          qn == "TP Offence"
              ? Container()
              : widget.isAlreadyVerified
                  ? Container()
                  : verCode != ""
                      ? Container()
                      : SizedBox(
                          width: double.infinity,
                          height: getProportionateScreenHeight(60),
                          child: const Card(
                            elevation: 10,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                    "Click On The Icons To Take Atleast Two Pictures"),
                              ),
                            ),
                          ),
                        ),
          qn == "TP Offence"
              ? Container()
              : widget.isAlreadyVerified
                  ? Container()
                  : verCode != ""
                      ? Container()
                      : SizedBox(
                          height: getProportionateScreenHeight(200),
                          width: double.infinity,
                          child: Row(
                            children: [
                              isImageTaken
                                  ? Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          _pickImage(1);
                                        },
                                        child: Card(
                                          elevation: 10,
                                          child: Center(
                                              child: FutureBuilder<void>(
                                            future: retriveLostData(_imageFile),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<void> snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.none:
                                                case ConnectionState.waiting:
                                                  return const Text(
                                                      'Picked an image');
                                                case ConnectionState.done:
                                                  return _previewImage(
                                                      _imageFile);
                                                default:
                                                  return const Text(
                                                      'Picked an image');
                                              }
                                            },
                                          )),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          _pickImage(1);
                                        },
                                        child: Card(
                                          elevation: 10,
                                          child: SvgPicture.asset(
                                            "assets/icons/addpic.svg",
                                            // height: 4.h,
                                            // width: 4.w,
                                          ),
                                        ),
                                      ),
                                    ),
                              isImageTaken1
                                  ? Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          _pickImage(2);
                                        },
                                        child: Card(
                                          elevation: 10,
                                          child: Center(
                                              child: FutureBuilder<void>(
                                            future:
                                                retriveLostData(_imageFile1),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<void> snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.none:
                                                case ConnectionState.waiting:
                                                  return const Text(
                                                      'Picked an image');
                                                case ConnectionState.done:
                                                  return _previewImage(
                                                      _imageFile1);
                                                default:
                                                  return const Text(
                                                      'Picked an image');
                                              }
                                            },
                                          )),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          _pickImage(2);
                                        },
                                        child: Card(
                                          elevation: 10,
                                          child: SvgPicture.asset(
                                            "assets/icons/addpic.svg",
                                            // height: 4.h,
                                            // width: 4.w,
                                          ),
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
          qn == "TP Offence"
              ? Container()
              : isImageTaken == false || isImageTaken1 == false
                  ? Card(
                      elevation: 10,
                      child: Center(
                        child: Text(
                          imageErr.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  : Container(),
          qn == "TP Offence"
              ? Container()
              : SizedBox(
                  height: getProportionateScreenHeight(20),
                ),
          widget.isAlreadyVerified
              ? Container()
              : verCode != ""
                  ? Container()
                  : isLoading
                      ? const CupertinoActivityIndicator(
                          radius: 20,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: qn != "TP Offence"
                              ? _submitButton()
                              : _reportButton(),
                        )
        ],
      ),
    );
  }
}
