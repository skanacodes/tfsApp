// ignore_for_file: file_names, use_key_in_widget_constructors, avoid_print, prefer_typing_uninitialized_variables, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';

import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/accessionNumber.dart';
import 'package:tfsappv1/services/modal/customermodel.dart';
import 'package:tfsappv1/services/modal/seedModal.dart';
import 'package:tfsappv1/services/modal/seedlingModel.dart';
import 'package:tfsappv1/services/size_config.dart';

class HoneyTraceAbility extends StatefulWidget {
  final String token;
  const HoneyTraceAbility(this.token);

  @override
  _HoneyTraceAbilityState createState() => _HoneyTraceAbilityState();
}

class _HoneyTraceAbilityState extends State<HoneyTraceAbility> {
  String result = "";
  List billData = [];
  List honeyId = [];
  bool isVerify = false;
  final value = NumberFormat("#,##0.00", "en_US");
  bool isLoading = false;
  bool isCustomerRegistered = false;
  String? customerName;
  List<int> stationIds = [];

  bool isNewCustomer = false;
  int quantity = 1;

  String? fullname;
  String? mobileNumber;

  List<int> quantities = [];

  final GlobalKey<ExpansionTileCardState> cardA = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardB = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardC = GlobalKey();
  List<String> ask = ['Domestic Customer', 'Non Domestic Customer'];
  List<String> typeseeds = ['Seed', 'Seedling'];
  String? type;
  int sum = 0;
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  int calculateSum() {
    int sumation = 0;
    for (var i = 0; i < billData.length; i++) {
      setState(() {
        //print(price);
        sumation = sumation +
            (int.parse(billData[i]["price"].toString()) *
                int.parse(billData[i]["quantity"].toString()));
        //sum = sumation;
      });
      print(sumation);
    }
    return sumation;
  }

  Future uploadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      print(honeyId);
      print(quantities);
      var headers = {"Authorization": "Bearer ${widget.token}"};
      BaseOptions options = BaseOptions(
          baseUrl: "https://mis.tfs.go.tz/honey-traceability",
          connectTimeout: 50000,
          receiveTimeout: 50000,
          headers: headers);
      var dio = Dio(options);
      var formData = FormData.fromMap({
        "full_name": customerName,
        "phone_number": mobileNumber,
        "honey_id[]": honeyId,
        "quantity[]": quantities,
        "station_id": stationIds
      });

      var response = await dio.post(
          "https://mis.tfs.go.tz/honey-traceability/api/v1/generate-bill",
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
      if (response.statusCode == 200) {
        //var res = json.decode(response.data);
        var res = response.data;
        print(res);

        message(
          'Bill Generated Successfully',
          'success',
        );
      } else if (response.statusCode == 201) {
        if (res["message"] == "Failed! Insufficient balance for Honey") {
          setState(() {
            isLoading = false;
          });
          message("Failed! Insufficient balance for Honey", "error");
        }
      } else {
        message('Failed To Save Data', 'error');
      }
    } on DioError catch (e) {
      print('dio package');
      if (DioErrorType.receiveTimeout == e.type ||
          DioErrorType.connectTimeout == e.type) {
        message('Server Can Not Be Reached.', 'error');
        // throw Exception('Server Can Not Be Reached');
        print(e);
      } else if (DioErrorType.response == e.type) {
        // throw Exception('Server Can Not Be Reached');

        message('Failed To Get Response From Server.', 'error');
        // throw Exception('Server Can Not Be Reached');
        print(e);
      } else if (DioErrorType.other == e.type) {
        if (e.message.contains('SocketException')) {
          // throw Exception('Server Can Not Be Reached');
          message(
            'Network Connectivity Problem.',
            'error',
          );

          print(e);
        }
      } else {
        //  throw Exception('Server Can Not Be Reached');
        message('error',
            'Network Connectivity Problem. Data Has Been Stored Localy');
        // throw Exception('Server Can Not Be Reached');
        print(e);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (customerName != null && mobileNumber != null) {
          message("Are You Sure You Want To Create This Bill", "info",
              isBillMessage: true);
        } else {
          message("Please Fill Customer Name and Phone Number", "info");
        }
      },
      child: isLoading
          ? SpinKitFadingCircle(
              color: kPrimaryColor,
              size: 35.0.sp,
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
              child: Container(
                height: 50,
                width: getProportionateScreenWidth(200),
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
                        colors: [kPrimaryColor, Colors.green[50]!])),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    'Generate Bill',
                    style: TextStyle(fontSize: 13.0.sp, color: Colors.black),
                  ),
                ),
              ),
            ),
    );
  }

  Future _scanQR() async {
    try {
      // String? barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      //     "GREEN", "Cancel", true, ScanMode.QR);
      // print(barcodeScanRes.toString() + "huushfuiewiu");

      // // ignore: unnecessary_null_comparison
      // var x = barcodeScanRes.toString() == "-1" ? null : barcodeScanRes;
      // print(barcodeScanRes);
      // // String tokens = await SharedPreferences.getInstance()
      // //     .then((prefs) => prefs.getString('token').toString());
      // print(x.toString() + "hfdhg");
      // if (x != null) {
      //   setState(() {
      //     isVerify = true;
      //     quantity = 1;
      //   });
      //   await computeQuantity();
      //   var res = jsonDecode(barcodeScanRes);
      //   Map billElements = {
      //     "price": res["price"],
      //     "station_name": res["station_id"]["name"],
      //     "station_id": res["station_id"]["id"],
      //     "quantity": quantity
      //   };
      //   print(billElements);
      //   honeyId.add(res["honey_id"]);
      //   quantities.add(billElements["quantity"]);
      //   stationIds.add(billElements["station_id"]);
      //   billData.add(billElements);
      //   print(billData);
      //   print(honeyId);
      //   cardC.currentState?.expand();
      //   setState(() {
      //     isVerify = false;
      //   });
      // } else {
      //   //enterTpNoPrompt(tokens);
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
                // permitNumber = value;
                // print(permitNumber);
              },
              cursorColor: kPrimaryColor,
              decoration: const InputDecoration(
                icon: Icon(Icons.folder_open),
                labelText: 'Enter Bill Id',
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              Navigator.pop(context);
              // setState(() {
              //   isVerify = true;
              // });
              // await verify(permitNumber!, tokens);
              // setState(() {
              //   isVerify = false;
              // });
            },
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            color: Colors.red,
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCEL",
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
          )
        ]).show();
  }

  message(String desc, String type, {int? index, bool? isBillMessage}) {
    return Alert(
      context: context,
      type: type == 'error'
          ? AlertType.warning
          : type == 'success'
              ? AlertType.success
              : AlertType.info,
      title: "Information",
      desc: desc,
      buttons: [
        DialogButton(
          onPressed: () async {
            if (index != null) {
              setState(() {
                billData.removeAt(index);
                honeyId.removeAt(index);
                quantities.removeAt(index);
              });
            }
            Navigator.pop(context);
            isBillMessage! ? await uploadData() : "";
          },
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          color: Colors.red,
          onPressed: () async {
            Navigator.pop(context);
          },
          width: 120,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  createUser() {
    return Alert(
        context: context,
        title: "Register New User",
        content: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const Divider(
                thickness: 1.0,
                height: 1.0,
                color: Colors.black26,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  key: const Key(""),
                  onSaved: (val) => customerName = val!,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                      ),
                    ),
                    fillColor: const Color(0xfff3f3f4),
                    filled: true,
                    labelText: "Full Name",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  // onChanged: (val) {
                  //   setState(() {});
                  // },
                  validator: (value) {
                    if (value!.isEmpty) return "This Field Is Required";
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 5, right: 5, left: 5, bottom: 10),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  key: const Key(""),
                  onSaved: (val) => mobileNumber = val!,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                      ),
                    ),
                    fillColor: const Color(0xfff3f3f4),
                    filled: true,
                    labelText: "Phone Number",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  // onChanged: (val) {
                  //   setState(() {});
                  // },
                  validator: (value) {
                    if (value!.isEmpty) return "This Field Is Required";
                    return null;
                  },
                ),
              ),
              const Divider(
                thickness: 1.0,
                height: 1.0,
                color: Colors.cyan,
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                print(customerName);

                print(mobileNumber);
                setState(() {
                  isCustomerRegistered = true;
                });

                Navigator.pop(context);
              }
            },
            child: const Text(
              "Register",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ),
          DialogButton(
            color: Colors.red,
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          )
        ]).show();
  }

  Future computeQuantity({int? index, int? quantit}) {
    return Alert(
        context: context,
        title: "Enter Quantity",
        content: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const Divider(
                thickness: 1.0,
                height: 1.0,
                color: Colors.black26,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: TextFormField(
                  initialValue: quantit == null ? "0" : quantit.toString(),
                  keyboardType: TextInputType.number,
                  key: const Key(""),
                  onSaved: (val) => quantity = int.parse(val!),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                      ),
                    ),
                    fillColor: const Color(0xfff3f3f4),
                    filled: true,
                    labelText: "Quantity",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  // onChanged: (val) {
                  //   setState(() {});
                  // },
                  validator: (value) {
                    if (value!.isEmpty) return "This Field Is Required";
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(20),
              ),
              const Divider(
                thickness: 1.0,
                height: 1.0,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {
                  if (index != null) {
                    billData[index]["quantity"] = quantity;
                    quantities[index] = quantity;
                    print(quantities);
                  }

                  print(billData);
                });
              }
              Navigator.pop(context);
            },
            child: const Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ),
          DialogButton(
            color: Colors.red,
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          )
        ]).show();
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

  List? beeProduct;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: forms(),
    );
  }

  forms() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: getProportionateScreenHeight(800),
            child: Column(
              children: <Widget>[
                // Adding the form here
                Form(
                  key: _formKey1,
                  child: Expanded(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(.0),
                          child: Card(
                            elevation: 10,
                            shadowColor: kPrimaryColor,
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  onTap: () {
                                    createUser();
                                  },
                                  trailing: isCustomerRegistered
                                      ? const Icon(
                                          Icons.verified_outlined,
                                          color: Colors.blue,
                                        )
                                      : const Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          color: Colors.blue,
                                        ),
                                  tileColor: const Color(0xfff3f3f4),
                                  leading: const CircleAvatar(
                                    foregroundColor: kPrimaryColor,
                                    backgroundColor: Colors.black12,
                                    child: Icon(
                                      Icons.app_registration,
                                    ),
                                  ),
                                  title: const Text(
                                    "Register Customer",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(10),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(.0),
                                child: Card(
                                  elevation: 10,
                                  shadowColor: kPrimaryColor,
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        onTap: () => _scanQR(),
                                        tileColor: const Color(0xfff3f3f4),
                                        leading: const CircleAvatar(
                                          foregroundColor: kPrimaryColor,
                                          backgroundColor: Colors.black12,
                                          child: Icon(
                                            Icons.qr_code,
                                            // size: 30,
                                          ),
                                        ),
                                        title: const Text(
                                          "QR Code",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(10),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: ExpansionTileCard(
                            key: cardC,
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
                                  Icons.production_quantity_limits_rounded,
                                  color: kPrimaryColor,
                                )),
                            title: const Text('Products List'),
                            children: <Widget>[
                              const Divider(
                                thickness: 1.0,
                                height: 1.0,
                                color: Colors.brown,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: const [
                                    Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Text(
                                            "S/N",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 3,
                                        child: Center(
                                          child: Text(
                                            "Station",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 3,
                                        child: Center(
                                          child: Text(
                                            "SubTotal",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: Text(
                                            "Action",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              const Divider(
                                thickness: 1.0,
                                height: 1.0,
                                color: Colors.brown,
                              ),
                              for (var i = 0; i < billData.length; i++)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Center(
                                                child: Text(
                                                  (i + 1).toString(),
                                                ),
                                              )),
                                          Expanded(
                                              flex: 3,
                                              child: Center(
                                                child: Text(
                                                  billData[i]["station_name"]
                                                      .toString(),
                                                ),
                                              )),
                                          Expanded(
                                              flex: 3,
                                              child: Center(
                                                child: Text(
                                                  (billData[i]["price"] *
                                                          billData[i]
                                                              ["quantity"])
                                                      .toString(),
                                                ),
                                              )),
                                          Expanded(
                                              flex: 2,
                                              child: Center(
                                                  child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Expanded(
                                                    child: IconButton(
                                                        onPressed: () {
                                                          computeQuantity(
                                                              index: i,
                                                              quantit: billData[
                                                                      i]
                                                                  ["quantity"]);
                                                        },
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          size: 17,
                                                          color: Colors.blue,
                                                        )),
                                                  ),
                                                  Expanded(
                                                    child: IconButton(
                                                        onPressed: () {
                                                          message(
                                                              "Are You Sure You Want To Remove Item?",
                                                              "info",
                                                              index: i);
                                                        },
                                                        icon: const Icon(
                                                          Icons
                                                              .remove_circle_outline_sharp,
                                                          size: 17,
                                                          color: Colors.red,
                                                        )),
                                                  ),
                                                ],
                                              ))),
                                        ],
                                      ),
                                      // SizedBox(
                                      //   height: getProportionateScreenHeight(5),
                                      // ),
                                      const Divider(
                                        thickness: 1.0,
                                        height: 0.0,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: getProportionateScreenHeight(10),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Expanded(
                                      flex: 1, child: Center(child: Text(" "))),
                                  const Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Text(
                                          "Total Price:  ",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      )),
                                  Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Text(
                                          value.format(calculateSum()),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                  const Expanded(
                                      flex: 2, child: Center(child: Text(" "))),
                                ],
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(10),
                              ),
                              isLoading
                                  ? SpinKitFadingCircle(
                                      color: kPrimaryColor,
                                      size: 35.0.sp,
                                    )
                                  : _submitButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<CustomerModel>> getData(filter, level) async {
    String url;
    var headers = {"Authorization": "Bearer ${widget.token}"};
    url = "http://41.59.227.103:9092/api/v1/customers";
    var response = await Dio().get(url,
        queryParameters: {
          "filter": filter,
        },
        options: Options(headers: headers));

    final data = response.data;
    print(data['data']);
    if (data != null) {
      setState(() {
        // datas = data[];
      });
      return CustomerModel.fromJsonList(data['data']);
    }

    return [];
  }

  Future<List<AccessionNumberModel>> getDataAccessionNumber(
      filter, seedId) async {
    String url;
    var headers = {"Authorization": "Bearer ${widget.token}"};
    url = "http://41.59.227.103:9092/api/v1/accession-number/$seedId";
    var response = await Dio().get(url,
        queryParameters: {
          "filter": filter,
        },
        options: Options(headers: headers));

    final data = response.data;
    print(data['data']);
    if (data != null) {
      setState(() {
        // datas = data[];
      });
      return AccessionNumberModel.fromJsonList(data['data']);
    }

    return [];
  }

  Future<List<SeedModel>> getDataSeed(filter, level) async {
    String url;
    var headers = {"Authorization": "Bearer ${widget.token}"};
    url = "http://41.59.227.103:9092/api/v1/seeds";
    var response = await Dio().get(url,
        queryParameters: {"filter": filter},
        options: Options(headers: headers));

    final data = response.data;
    print(data['data']);
    if (data != null) {
      setState(() {
        // datas = data[];
      });
      return SeedModel.fromJsonList(data['data']);
    }

    return [];
  }

  Future<List<SeedlingModel>> getDataSeedling(filter, level) async {
    String url;
    var headers = {"Authorization": "Bearer ${widget.token}"};
    url = "http://41.59.227.103:9092/api/v1/seedlings";
    var response = await Dio().get(url,
        queryParameters: {"filter": filter},
        options: Options(headers: headers));

    final data = response.data;
    print(data['data']);
    if (data != null) {
      setState(() {
        // datas = data[];
      });
      return SeedlingModel.fromJsonList(data['data']);
    }

    return [];
  }

  Future getBill(id) async {
    setState(() {
      isLoading = true;
    });
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      print(id);
      print("djvnjdw");
      var headers = {"Authorization": "Bearer ${widget.token}"};
      var url = Uri.parse('http://41.59.227.103:9092/api/v1/bills/$id');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          await getControllNumber(4);
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
    setState(() {
      isLoading = false;
    });
  }

  Future getControllNumber(billId) async {
    setState(() {
      isLoading = true;
    });
    try {
      print("Bills");
      var headers = {"Authorization": "Bearer ${widget.token}"};
      var url = Uri.parse(
          'https://mis.tfs.go.tz/honey-traceability/api/v1/controlnumber/$billId');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            //widget.callback(jsonEncode(res["data"]));
            messages(
                "success", "C/N:  ${res["data"]["control_number"]}");
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
    setState(() {
      isLoading = false;
    });
  }
}
