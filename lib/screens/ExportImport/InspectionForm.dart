import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/inspectionModal.dart';
import 'package:tfsappv1/services/modal/productmodel.dart';
import 'package:tfsappv1/services/modal/speciesModel.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:path/path.dart' as path;

class InspectionForm extends StatefulWidget {
  static String routeName = "/inspection";
  InspectionForm({Key? key}) : super(key: key);

  @override
  _InspectionFormState createState() => _InspectionFormState();
}

class _InspectionFormState extends State<InspectionForm> {
  bool isLoading = false;
  String local = '';
  var bytes;
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  final _speciesEditTextController = TextEditingController();
  final _productEditTextController = TextEditingController();
  String? volume;
  String? mark;
  String? receiptNo;
  String imageErr = ' ';

  String quantity = '';
  List data = [];
  List data1 = [];
  List data2 = [];
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

  Widget _previewImage(var _imageFile) {
    // ignore: unnecessary_null_comparison
    if (_imageFile != null) {
      return Container(
        // height: 100,
        // width: 100,
        child: Image.file(File(_imageFile.path)),

        // RaisedButton(
        //   onPressed: () async {
        //     var res = await uploadImage(_imageFile.path, uploadUrl);
        //     print(res);
        //   },
        //   child: const Text('Upload'),
        // )
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  void _pickImage(int numb) async {
    try {
      await Future.delayed(Duration(milliseconds: 1000));
      final pickedFile = await _picker.getImage(
        source: ImageSource.camera,
        imageQuality: 40,
        preferredCameraDevice: CameraDevice.rear,
      );
      await Future.delayed(Duration(milliseconds: 100));
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
            textStyle: Theme.of(context).textTheme.display1,
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

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    print(picked);
    setState(() {
      formattedDate = DateFormat('yyyy-MM-dd').format(picked!);
    });
    return picked;
  }

  Future<String> uploadData(jobId, userId, type) async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var stationIsd = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getInt('station_id'));
      var fname = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('fname'));
      var lname = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('lname'));

      print(tokens);

      var headers = {"Authorization": "Bearer " + tokens!};
      BaseOptions options = new BaseOptions(
          baseUrl: "$baseUrl",
          connectTimeout: 50000,
          receiveTimeout: 50000,
          headers: headers);
      var dio = Dio(options);
      var formData = type == 'Export Inspection'
          ? FormData.fromMap({
              'export_id': jobId,
              'product_name': productName,
              'species_name': speciesName,
              'no_of_pieces': quantity,
              'unit': unit,
              'inspector': '$fname  $lname',
              'station_id': stationIsd,
              'volume': volume,
              'receipt_no': receiptNo,
              'amount_paid': paid,
              'receipt_date': formattedDate,
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
              'import_id': jobId,
              'product_name': productName,
              'species_name': speciesName,
              'no_of_pieces': quantity,
              'unit': unit,
              'inspector': '$fname  $lname',
              'station_id': stationIsd,
              'volume': volume,
              'receipt_no': receiptNo,
              'amount_paid': paid,
              'receipt_date': formattedDate,
              'identification_mark': mark,
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
                style: TextStyle(fontSize: 20, color: Colors.green[700]),
              ),
            ),
    );
  }

  @override
  void initState() {
    // this.getCategory();
    // this.getSpecies();
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as InspectionArguments;
    print(args.id);
    print(args.type);
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
                    height: getProportionateScreenHeight(140),
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
                                  title: _title(args.type),
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
                  forms(args.id, "6", args.type)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  forms(id, userId, type) {
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
                      child: DropdownSearch<SpeciesModel>(
                        // showSelectedItem: true,
                        showSearchBox: true,
                        popupTitle: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Text(
                            'List Of Species',
                          )),
                        ),
                        validator: (v) =>
                            v == null ? "This Field Is required" : null,
                        mode: Mode.BOTTOM_SHEET,
                        popupElevation: 20,
                        searchFieldProps: TextFieldProps(
                          controller: _speciesEditTextController,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.cyan,
                                ),
                              ),
                              fillColor: Color(0xfff3f3f4),
                              filled: true,
                              labelText: "Search",
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(30, 10, 15, 10),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                color: Colors.red,
                                onPressed: () {
                                  _speciesEditTextController.clear();
                                },
                              )),
                        ),
                        dropdownSearchDecoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true,
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(30, 5, 10, 5),
                            hintText: "Select Species Name",
                            border: InputBorder.none),
                        compareFn: (i, s) => i!.isEqual(s),

                        onFind: (filter) => getData(filter),

                        onChanged: (data) {
                          // print(data!.scientificName);

                          setState(() {
                            speciesName = data!.scientificName;
                          });
                        },
                        //  dropdownBuilder: _customDropDownExample,
                        popupItemBuilder: _customPopupItemBuilderExample2,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 18, left: 18),
                      child: DropdownSearch<ProductModel>(
                        // showSelectedItem: true,
                        showSearchBox: true,
                        validator: (v) =>
                            v == null ? "This Field Is required" : null,
                        popupTitle: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Text(
                            'List Of Products',
                          )),
                        ),
                        searchFieldProps: TextFieldProps(
                          controller: _productEditTextController,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.cyan,
                                ),
                              ),
                              fillColor: Color(0xfff3f3f4),
                              filled: true,
                              labelText: "Search",
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(30, 10, 15, 10),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                color: Colors.red,
                                onPressed: () {
                                  _productEditTextController.clear();
                                },
                              )),
                        ),
                        mode: Mode.BOTTOM_SHEET,
                        popupElevation: 20,

                        dropdownSearchDecoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true,
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(30, 5, 10, 5),
                            hintText: "Select Product Name",
                            border: InputBorder.none),
                        compareFn: (i, s) => i!.isEqual(s),

                        onFind: (filter) => getData1(filter),

                        onChanged: (data) {
                          setState(() {
                            productName = data!.productname;
                            unit = data.unit;
                          });
                        },
                        //  dropdownBuilder: _customDropDownExample,
                        popupItemBuilder: _customPopupItemBuilder2,
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
                          key: Key("Amount"),
                          onSaved: (val) => paid = val!,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true,
                            labelText: "Amount Paid",
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
                    productName == 'Sawn Timber'
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 16, left: 16),
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
                                  contentPadding:
                                      EdgeInsets.fromLTRB(30, 10, 15, 10),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          key: Key("vol"),
                          onSaved: (val) => receiptNo = val!,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true,
                            labelText: "Receipt Number",
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
                    type == 'Export Inspection'
                        ? Container()
                        : productName == 'Sawn Timber'
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, right: 16, left: 16),
                                child: Container(
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    key: Key("vol"),
                                    onSaved: (val) => mark = val!,
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                          color: Colors.cyan,
                                        ),
                                      ),
                                      fillColor: Color(0xfff3f3f4),
                                      filled: true,
                                      labelText:
                                          "Identification Mark Of Timber",
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(30, 10, 15, 10),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: Container(
                          child: Card(
                        elevation: 10,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kPrimaryColor,
                            child: Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            _selectDate(context);
                          },
                          title: Text(
                            'Receipt Date: $formattedDate',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      )),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Container(
                      width: double.infinity,
                      height: getProportionateScreenHeight(70),
                      child: Card(
                        elevation: 10,
                        child: Center(
                          child: Text(
                              "Click On The Icons To Take Atleast Two Pictures"),
                        ),
                      ),
                    ),
                    Container(
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
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _submitButton(id, userId, type),
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

  Future<List<SpeciesModel>> getData(filter) async {
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    var headers = {"Authorization": "Bearer " + tokens!};
    var response =
        await Dio().get("https://mis.tfs.go.tz/fremis/api/v1/get-species",
            queryParameters: {
              "filter": filter,
            },
            options: Options(headers: headers));

    final data = response.data;
    // print(data['species']);
    // print('hfr');
    if (data != null) {
      return SpeciesModel.fromJsonList(data['species']);
    }

    return [];
  }

  Future<List<ProductModel>> getData1(filter) async {
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    var headers = {"Authorization": "Bearer " + tokens!};
    var response = await Dio().get(
        "https://mis.tfs.go.tz/fremis-test/api/v1/get-products",
        queryParameters: {"filter": filter},
        options: Options(headers: headers));

    final data = response.data;
    print(data);
    if (data != null) {
      return ProductModel.fromJsonList(data['products']);
    }

    return [];
  }

  Widget _customPopupItemBuilder2(
      BuildContext context, ProductModel item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: kPrimaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: Card(
        elevation: 5,
        child: ListTile(
          selected: isSelected,
          title: Text(item.productname),
          subtitle: Text('Unit: ' + item.unit.toString()),
          tileColor: Color(0xfff3f3f4),
          leading: CircleAvatar(
            backgroundColor: Colors.pink,
            child: Icon(Icons.code),
          ),
        ),
      ),
    );
  }

  Widget _customPopupItemBuilderExample2(
      BuildContext context, SpeciesModel item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: Card(
        elevation: 5,
        child: ListTile(
          selected: isSelected,
          title: Text(item.scientificName),
          //subtitle: Text(item.id.toString()),
          tileColor: Color(0xfff3f3f4),
          leading: CircleAvatar(
            backgroundColor: Colors.pink,
            child: Icon(Icons.code),
          ),
        ),
      ),
    );
  }
}
