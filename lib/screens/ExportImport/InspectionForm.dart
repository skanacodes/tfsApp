// ignore_for_file: body_might_complete_normally_nullable, file_names, prefer_typing_uninitialized_variables, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/inspectionModal.dart';

import 'package:tfsappv1/services/size_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class InspectionForm extends StatefulWidget {
  static String routeName = "/inspection";
  const InspectionForm({Key? key}) : super(key: key);

  @override
  _InspectionFormState createState() => _InspectionFormState();
}

class _InspectionFormState extends State<InspectionForm> {
  bool isLoading = false;
  String local = '';
  var bytes;
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  String? volume;
  String? mark;
  String? receiptNo;
  String imageErr = ' ';
  String? inspectionMark;
  String? noOfPiece;
  String quantity = '';
  List data = [];
  List data1 = [];
  List data2 = [];
  int counter = 1;
  bool showPermitType = false;
  bool showPackagingMaterial = false;
  bool isProductset = false;
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
  String? productName;
  String? speciesName;

  bool isSigned = false;
  String? classy;
  String? paid;
  String img1 = '';
  String img2 = '';
  late PickedFile _imageFile;
  late PickedFile _imageFile1;
  bool isImageTaken = false;
  bool isImageTaken1 = false;
  String? unit;
  String? productId;
  final String uploadUrl = 'https://api.imgur.com/3/upload';
  final ImagePicker _picker = ImagePicker();
  //DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
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

  Future getUnit() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrl/api/v1/get-units');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            data1 = res['units'];

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

  void _handleSaveButtonPressed() async {
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
            const Padding(
              padding: EdgeInsets.all(8.0),
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
                  child: Text(
                    "Clear Mark",
                    style: TextStyle(fontSize: 12.sp),
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
                        icon: const Icon(Icons.clear)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                " $formattedDate",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () async => _handleSaveButtonPressed(),
            child: const Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
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

  Widget _title(String type) {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
          text: type == 'Export Inspection' ? ' Export ' : ' Import ',
          style: GoogleFonts.portLligatSans(
            // textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: 'Inspection',
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
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  Future<String> uploadData(jobId, userId, type) async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));

      var fname = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('fname'));
      var lname = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('lname'));

      print(tokens);

      var headers = {"Authorization": "Bearer " + tokens!};
      BaseOptions options = BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: 50000,
          receiveTimeout: 50000,
          headers: headers);
      var dio = Dio(options);
      var formData = type == 'Export Inspection'
          ? FormData.fromMap({
              'inspection_id': jobId,
              'insp_prod_id': productId,
              'no_of_pieces': noOfPiece,
              'quantity': quantity,
              'unit': unit,
              'inspection_type': 'export',
              'inspector': '$fname  $lname',
              'inspection_mark': inspectionMark.toString() == "null"
                  ? "null"
                  : inspectionMark.toString(),
              'identification_mark':
                  mark.toString() == "null" ? "null" : mark.toString(),
              'consignment_image[]': [
                img1 == ''
                    ? null
                    : await MultipartFile.fromFile(
                        img1,
                        filename: 'image',
                      ),
                img2 == ''
                    ? null
                    : await MultipartFile.fromFile(
                        img2,
                        filename: 'images',
                      ),
              ],
            })
          : FormData.fromMap({
              'inspection_id': jobId,
              'insp_prod_id': productId,
              'no_of_pieces': noOfPiece,
              'quantity': quantity,
              'inspection_type': 'import',
              'unit': unit,
              'inspector': '$fname  $lname',
              'inspection_mark': inspectionMark.toString() == "null"
                  ? "null"
                  : inspectionMark.toString(),
              'identification_mark': mark.toString() == "null" ? "null" : mark,
              'consignment_image[]': [
                img1 == ''
                    ? null
                    : await MultipartFile.fromFile(
                        img1,
                        filename: 'image',
                      ),
                img1 == ''
                    ? null
                    : await MultipartFile.fromFile(
                        img2,
                        filename: 'images',
                      ),
              ],
            });

      var response = await dio.post('$baseUrl/api/v1/export/insp/store',
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
        var res = response.data;
        print(res);
        counter++;
        setState(() {
          data2 = res['inspProd'];
          isProductset = true;
          ask1 = null;
          print(data);
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
        message('error', 'Request Timeout..Please Try Again.');
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

  Widget _submitButton(String jobid, String userId, String type) {
    return InkWell(
      onTap: () async {
        //  print(_connectionStatus.toString());
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          setState(() {
            isLoading = true;
          });
          var x = await uploadData(jobid, userId, type);

          ask1 = null;
          setState(() {
            print(x);
            isImageTaken = false;
            isImageTaken1 = false;
            isLoading = false;
          });
          _formKey.currentState!.reset();

          setState(() {
            // imageErr = "Please Capture Image";
            isLoading = false;
          });
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
                      colors: [kPrimaryColor, Colors.green[100]!])),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 20, color: Colors.green[700]),
              ),
            ),
    );
  }

  @override
  void initState() {
    getUnit();
    RealTimeCommunication().createConnection(
      "14",
    );
    // this.getSpecies();
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as InspectionArguments;
    // print(data[''])
    print(args.species.length);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          ' ',
          style: TextStyle(
              fontFamily: 'Ubuntu', color: Colors.black, fontSize: 17),
        ),
      ),
      floatingActionButton: SizedBox(
        height: getProportionateScreenHeight(30),
        child: FloatingActionButton.extended(
          label: counter > args.species.length
              ? const Icon(
                  Icons.verified,
                  color: Colors.green,
                )
              : Text(
                  '$counter Of ${args.species.length}',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
          icon: const Icon(
            Icons.star_border,
            color: Colors.black,
          ),
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.white,
          tooltip: 'Number Of Species',
          onPressed: () {},
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
                    height: getProportionateScreenHeight(110),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: getProportionateScreenHeight(60),
                          decoration: const BoxDecoration(
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
                                  title: _title(args.type),
                                  trailing:
                                      const Icon(Icons.document_scanner_rounded),
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
                  // Adding the form here
                  forms(args.id, "6", args.type,
                      isProductset ? data2 : args.species)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  forms(id, userId, type, List species) {
    setState(() {
      data = species;
    });
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
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    data.isEmpty
                        ? Container()
                        : SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 1, right: 16, left: 16),
                              child: DropdownButtonFormField<String>(
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
                                    enabled: true,
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(30, 10, 15, 10),
                                    labelText: "Select Species",
                                    border: InputBorder.none),
                                isExpanded: true,

                                value: ask1,
                                //elevation: 5,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Ubuntu'),
                                iconEnabledColor: Colors.black,
                                items: data.map((item) {
                                  // setState(() {
                                  //   // productId = item['id'].toString();
                                  //   // print(productId);
                                  // });
                                  return DropdownMenuItem(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Color(0xfff3f3f4),
                                        border: Border(
                                          bottom: BorderSide(
                                              width: 1, color: kPrimaryColor),
                                        ),
                                      ),
                                      child: Text(
                                        item['species_name'].toString(),
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    value: item['species_name'].toString(),
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
                                        .requestFocus(FocusNode());
                                    ask1 = value!;

                                    print(ask1);
                                  });

                                  for (var i = 0; i < data.length; i++) {
                                    if (data[i]['species_name'] == ask1) {
                                      setState(() {
                                        productId = data[i]['id'].toString();
                                      });
                                      // Found the person, stop the loop
                                      return;
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 5, right: 16, left: 16),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        key: const Key("No"),
                        onSaved: (val) => noOfPiece = val!,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.cyan,
                            ),
                          ),
                          fillColor: const Color(0xfff3f3f4),
                          filled: true,
                          labelText: "No. Of Pieces",
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 16, left: 16),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              key: const Key("vol"),
                              onSaved: (val) => quantity = val!,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.cyan,
                                  ),
                                ),
                                fillColor: const Color(0xfff3f3f4),
                                filled: true,
                                labelText: "Quantity",
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
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 18, left: 18),
                            child: SafeArea(
                              child: data1.isEmpty
                                  ? SpinKitFadingCircle(
                                      color: kPrimaryColor,
                                      size: 35.0.sp,
                                    )
                                  : DropdownButtonFormField(
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
                                        contentPadding: const EdgeInsets.fromLTRB(
                                            30, 10, 15, 10),
                                        labelText: "Unit",
                                        border: InputBorder.none),
                                    isExpanded: true,
                                    isDense: true,
                                    validator: (value) =>
                                        value == null ? "* Required" : null,
                                    items: data1.map((item) {
                                      return DropdownMenuItem(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: const BoxDecoration(
                                            color: Color(0xfff3f3f4),
                                            border: Border(
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: kPrimaryColor),
                                            ),
                                          ),
                                          child: Text(
                                            item['name'].toString(),
                                          ),
                                        ),
                                        value: item['name'].toString(),
                                      );
                                    }).toList(),
                                    onChanged: (newVal) {
                                      setState(() {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        unit = newVal.toString();
                                      });
                                    },
                                    value: unit,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    type == 'Export Inspection'
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 16, left: 16),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              key: const Key("vol"),
                              onSaved: (val) => mark = val!,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.cyan,
                                  ),
                                ),
                                fillColor: const Color(0xfff3f3f4),
                                filled: true,
                                labelText: "Identification Mark",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(30, 10, 15, 10),
                              ),
                            ),
                          )
                        : Container(),
                    type == 'Export Inspection'
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 16, left: 16),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              key: const Key("vol"),
                              onSaved: (val) => inspectionMark = val!,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Colors.cyan,
                                  ),
                                ),
                                fillColor: const Color(0xfff3f3f4),
                                filled: true,
                                labelText: "Inspection Mark",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(30, 10, 15, 10),
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    SizedBox(
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
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.none:
                                            case ConnectionState.waiting:
                                              return const Text(
                                                  'Picked an image');
                                            case ConnectionState.done:
                                              return _previewImage(_imageFile);
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
                                        future: retriveLostData(_imageFile1),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<void> snapshot) {
                                          switch (snapshot.connectionState) {
                                            case ConnectionState.none:
                                            case ConnectionState.waiting:
                                              return const Text(
                                                  'Picked an image');
                                            case ConnectionState.done:
                                              return _previewImage(_imageFile1);
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
                    isImageTaken == false || isImageTaken1 == false
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
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _submitButton(
                        id,
                        userId,
                        type,
                      ),
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

  // Future<List<SpeciesModel>> getData(filter) async {
  //   var tokens = await SharedPreferences.getInstance()
  //       .then((prefs) => prefs.getString('token'));
  //   var headers = {"Authorization": "Bearer " + tokens!};
  //   var response =
  //       await Dio().get("https://mis.tfs.go.tz/fremis/api/v1/get-species",
  //           queryParameters: {
  //             "filter": filter,
  //           },
  //           options: Options(headers: headers));

  //   final data = response.data;
  //   // print(data['species']);
  //   // print('hfr');
  //   if (data != null) {
  //     return SpeciesModel.fromJsonList(data['species']);
  //   }

  //   return [];
  // }

}
