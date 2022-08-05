// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class SignatureScreen extends StatefulWidget {
  static String routeName = "/signaturescreen";
  const SignatureScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  var bytes;
  bool isLoading = false;
  bool isSigned = false;
  message(String hint, String message) {
    return Alert(
      context: context,
      type: hint == "error" ? AlertType.error : AlertType.success,
      title: "Information",
      desc: message,
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

  Future uploadSign() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};

      var dio = Dio();

      var formData = FormData.fromMap({
        'signature': base64Encode(bytes),
      });
      var response = await dio.post('$baseUrl/api/v1/signature',
          data: formData, options: Options(headers: headers));
      // print("gone");
      print(response.statusCode);
      print(response.data);
      switch (response.statusCode) {
        case 200:
          var res;
          setState(() {
            res = json.decode(response.data);
          });
          message("error", res["message"].toString());

          break;
        case 201:
          message("success", "Signature Was Uploaded Successfully");

          break;
        case 500:
          message("error", "Server Error");
          break;
        default:
      }
    } catch (e) {
      print(e);
      message("error", "There Was An Error While Uploading Signature");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
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
    if (mounted) {
      setState(() {
        bytes = byte!.buffer.asUint8List();
      });
    }
    File('$appDocPath/$imageName.png')
        .writeAsBytesSync(byte!.buffer.asInt8List());
    // var tokens = await SharedPreferences.getInstance()
    //     .then((prefs) => prefs.getString('token'));
    //print(tokens);
    // print(bytes);
    if (mounted) {
      setState(() {
        isSigned = true;
      });
    }
    Navigator.pop(context);
  }

  mark() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: false,
        builder: (context) {
          return SingleChildScrollView(
            child: SizedBox(
              // height: getProportionateScreenHeight(800),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Write Your Signature",
                          style: TextStyle(fontSize: 16),
                        ),
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.red,
                          child: Center(
                            child: IconButton(
                              onPressed: () =>
                                  signatureGlobalKey.currentState!.clear(),
                              icon: const Icon(
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
                                icon: const Icon(
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
                                icon: const Icon(
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
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: SfSignaturePad(
                            key: signatureGlobalKey,
                            backgroundColor: Colors.white,
                            strokeColor: Colors.black,
                            onDrawStart: () {
                              return false;
                            },
                            minimumStrokeWidth: 1.0,
                            maximumStrokeWidth: 2.0)),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            'Digital Signature ',
            style: TextStyle(
                fontFamily: 'Ubuntu', color: Colors.black, fontSize: 17),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: getProportionateScreenHeight(20),
              ),
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, right: 16, left: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Card(
                          elevation: 5,
                          child: ListTile(
                            onTap: () {
                              mark();
                            },
                            title: const Text('Tap To Write Your Signature'),
                            leading: Icon(
                              isSigned ? Icons.verified : Icons.pending_actions,
                              color: isSigned ? kPrimaryColor : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      height: getProportionateScreenHeight(50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            offset: const Offset(0, 15),
                            color: Colors.grey[400]!,
                          )
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.grey[50]!, Colors.grey[100]!],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await uploadSign();
                              },
                              child: Row(
                                children: const [
                                  Expanded(
                                      child: Center(child: Text("Upload"))),
                                  Expanded(
                                      child: Icon(
                                    Icons.upload,
                                    color: Colors.red,
                                  )),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                //signatureGlobalKey.currentState!.clear();
                              },
                              child: Row(
                                children: const [
                                  Expanded(
                                      child: Center(child: Text("Delete"))),
                                  Expanded(
                                      child: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ))
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(20),
                  ),
                  isLoading && isSigned
                      ? SpinKitFadingCircle(
                          color: kPrimaryColor,
                          size: 35.0.sp,
                        )
                      : SizedBox(
                          // height: getProportionateScreenHeight(0.2),
                          width: double.infinity,
                          child: Center(
                              child: isSigned
                                  ? Container(
                                      color: Colors.grey[300],
                                      child: Image.memory(
                                          bytes.buffer.asUint8List()),
                                    )
                                  : const Center(
                                      child: Text("No Written Signature"),
                                    )),
                        ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
