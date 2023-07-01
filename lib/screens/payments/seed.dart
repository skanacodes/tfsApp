// ignore_for_file: use_key_in_widget_constructors, avoid_//print(, unrelated_type_equality_checks, prefer_typing_uninitialized_variables, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/accessionNumber.dart';
import 'package:tfsappv1/services/modal/customermodel.dart';
import 'package:tfsappv1/services/modal/seedModal.dart';
import 'package:tfsappv1/services/modal/seedlingModel.dart';
import 'package:tfsappv1/services/size_config.dart';

class Seeds extends StatefulWidget {
  final String token;
  //final Function(String) callback;

  const Seeds(
    this.token,
  );

  @override
  _SeedsState createState() => _SeedsState();
}

class _SeedsState extends State<Seeds> {
  //Variables
  String? seedname;
  bool isCustomerSelected = false;
  bool isCustomerRegistered = false;
  String? categoryId;
  String? categoryName;
  final _seedEditTextController = TextEditingController();
  final _seedlingEditTextController = TextEditingController();
  bool isLoading = false;
  String? customerName;
  String? customerId;
  String? accessionNumber;
  bool isNewCustomer = false;
  double quantity = 0.0;
  double? price;
  String seedId = "0";
  String seedlingId = "0";
  bool isSeed = false;
  String? fullname;
  String? mobileNumber;
  String? physicalAdress;
  String? typeSeed;
  String? customerCategory;
  List<String> typeOperation = [];
  List<int> quantities = [];
  List<String> products = [];
  List orderData = [];
  List<int> unitPrice = [];
  final _dealerEditTextController = TextEditingController();
  final _accessionEditTextController = TextEditingController();
  final GlobalKey<ExpansionTileCardState> cardA = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardB = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardC = GlobalKey();
  List<String> ask = ['Domestic Customer', 'Non Domestic Customer'];
  List<String> typeseeds = ['Seed', 'Seedling'];
  String? type;
  int sum = 0;
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  double calculateSum() {
    double sumation = 0.0;
    for (var i = 0; i < orderData.length; i++) {
      double price = double.parse(orderData[i]["price"].toString()) *
          double.parse(orderData[i]["quantity"].toString());
      //print((price);
      setState(() {
        ////print((quantity);
        sumation = sumation + price;
        //sum = sumation;
      });
      //print((sumation);
    }
    return sumation;
  }

  Future postBill() async {
    setState(() {
      isLoading = true;
      //print((orderData);
    });
    try {
      // //print((widget.token);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {
        "Authorization": "Bearer $tokens",
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE'
      };
      BaseOptions options = BaseOptions(
          baseUrl: baseUrlSeed,
          connectTimeout: const Duration(minutes: 4),
          receiveTimeout: const Duration(minutes: 4),
          headers: headers);
      var dio = Dio(options);
      var formData = FormData.fromMap({
        "customer_id": customerId.toString(),
        "full_name": customerName,
        "phone_number": mobileNumber,
        "category_id": categoryId,
        "address": physicalAdress,
        "data": orderData
      });

      var response = await dio.post("$baseUrlSeed/api/v1/generate-bill",
          data: formData, onSendProgress: (int sent, int total) {
        // setState(() {
        //   uploadMessage = sent.toString();
        // });
        //print(('$sent $total');
      });
      //print((response.statusCode);
      //print((response.statusMessage);
      var res = response.data;
      //print((res);
      if (response.statusCode == 200) {
        if (res["status"].toString() == "Token is Expired") {
          message("Token Is Expired Please Login Again", "info");
        } else if (res["message"].toString() ==
            "Bill Generated Successfully!") {
          message(
            'Bill Generated Successfully',
            'success',
          );
        } else {
          message("Problem While Processing Request", "error");
        }
      } else if (response.statusCode == 201) {
        if (res["message"] == "Customer phone $mobileNumber exists") {
          setState(() {
            isLoading = false;
          });
          message(res["message"], "error");
        } else if (res["message"] ==
            "Seed not available in your current stock") {
          setState(() {
            isLoading = false;
          });
          message("Seed not available in your current stock", "error");
        } else {
          message("Problem while Processing", "error");
        }
      } else if (response.statusCode == "500") {
        //print((res.toString());
      } else {
        message('Failed To Save Data', 'error');
      }
    } on DioError catch (e) {
      //print(('dio package');
      if (DioErrorType.receiveTimeout == e.type ||
          DioErrorType.sendTimeout == e.type) {
        //print((e.toString());
        message('Server Can Not Be Reached.', 'error');
        // throw Exception('Server Can Not Be Reached');
        //print((e);
      } else if (DioErrorType.badResponse == e.type) {
        // throw Exception('Server Can Not Be Reached');
        // //print((e.message);
        message('Failed To Get Response From Server.', 'error');
        // throw Exception('Server Can Not Be Reached');
        //print((e);
      } else if (DioErrorType.badCertificate == e.type) {
        if (e.message!.contains('SocketException')) {
          // throw Exception('Server Can Not Be Reached');
          message(
            'Network Connectivity Problem.',
            'error',
          );

          //print((e);
        }
      } else {
        //  throw Exception('Server Can Not Be Reached');
        message('error',
            'Network Connectivity Problem. Data Has Been Stored Localy');
        // throw Exception('Server Can Not Be Reached');
        //print((e);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  postBills() async {
    try {
      //print((widget.token);
      var headers = {
        "Authorization": "Bearer ${widget.token}",
      };
      var url = Uri.parse('$baseUrlSeed/api/v1/generate-bill');
      //print(("yaaa");
      final response = await http.post(url, headers: headers, body: {
        "customer_id": customerId,
        "full_name": fullname,
        "phone_number": mobileNumber,
        "category_id": categoryId,
        "address": physicalAdress,
        "data": [
          {
            "order_item": "Seed",
            "seed_id": "53",
            "seedling_id": "null",
            "assesment_id": "74",
            "quantity": "2",
            "price": "20000",
            "seed_name": "Acacia mangium"
          }
        ]
      });
      var res;
      //final sharedP prefs=await
      //print((response.statusCode);
      setState(() {
        res = json.decode(response.body);
      });
      //print((res);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
          });
          //print((res);
          Future.delayed(const Duration(seconds: 5), () async {
// Here you can write your code
            await getControllNumber(res["data"]["bill_id"]);
          });
          return 'success';
          // ignore: dead_code
          break;
        case 403:
          setState(() {
            res = json.decode(response.body);
            //print((res);
          });
          return 'fail';
          // ignore: dead_code
          break;

        case 1200:
          setState(() {
            res = json.decode(response.body);
            //print((res);
            // addError(
            //     error:
            //         'Your Device Is Locked Please Contact User Support Team');
          });
          return 'fail';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print((res);
            // addError(error: 'Something Went Wrong');
            // isLoading = false;
          });
          return 'fail';
          // ignore: dead_code
          break;
      }
    } catch (e) {
      setState(() {
        //print((e);

        // addError(error: 'Server Or Network Connectivity Error');
        // isLoading = false;
      });
      return 'fail';
    }
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: "Seeds",
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: '/Seedling ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0.sp,
              ),
            ),
            TextSpan(
              text: '  Form',
              style: TextStyle(
                color: Colors.green[200],
                fontSize: 15.0.sp,
              ),
            ),
          ]),
    );
  }

  createUser() {
    return Alert(
        context: context,
        title: "Register New Dealer",
        content: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const Divider(
                thickness: 1.0,
                height: 1.0,
                color: Colors.black26,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0, right: 5, left: 5),
                  child: DropdownButtonFormField<String>(
                    itemHeight: 50,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(
                            color: Colors.cyan,
                          ),
                        ),
                        fillColor: const Color(0xfff3f3f4),
                        filled: true,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(30, 10, 15, 10),
                        labelText: "Customer Category",
                        border: InputBorder.none),
                    isExpanded: true,

                    value: categoryName,
                    //elevation: 5,
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'Ubuntu'),
                    iconEnabledColor: Colors.black,
                    items: ask.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xfff3f3f4),
                            border: Border(
                              bottom:
                                  BorderSide(width: 1, color: kPrimaryColor),
                            ),
                          ),
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
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
                        FocusScope.of(context).requestFocus(FocusNode());
                        categoryName = value!;
                        value == "Domestic Customer"
                            ? categoryId = "1"
                            : categoryId = "3";
                        //print((categoryId);
                      });
                    },
                    onSaved: (value) {
                      setState(() {
                        FocusScope.of(context).requestFocus(FocusNode());
                        // categoryId = value!;
                        value == "Domestic Customer"
                            ? categoryId = "1"
                            : categoryId = "3";
                        //print((categoryId);
                      });
                    },
                  ),
                ),
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
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
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
              Padding(
                padding: const EdgeInsets.only(
                    top: 5, right: 5, left: 5, bottom: 10),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  key: const Key(""),
                  onSaved: (val) => physicalAdress = val!,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                      ),
                    ),
                    fillColor: const Color(0xfff3f3f4),
                    filled: true,
                    labelText: "Physical Address",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  // onChanged: (val) {
                  //   setState(() {});
                  // },
                  // validator: (value) {
                  //   if (value!.isEmpty) return "This Field Is Required";
                  //   return null;
                  // },
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Dealer Registered Successfull"),
                    //padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    dismissDirection: DismissDirection.up,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 5),
                  ),
                );
                customerId = null;
                isCustomerRegistered = true;
                isCustomerSelected = false;

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

  messages(
    String type,
    String desc,
  ) {
    typeOperation.clear();
    unitPrice.clear();
    quantities.clear();
    seedname = null;
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
      child: SizedBox(
        height: getProportionateScreenHeight(1000),
        child: Column(
          children: <Widget>[
            // Adding the form here
            Form(
              key: _formKey1,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(.0),
                    child: Card(
                      elevation: 10,
                      shadowColor: kPrimaryColor,
                      child: Column(
                        children: <Widget>[
                          _title(),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 18, left: 18),
                            child: DropdownSearch<CustomerModel>(
                              // showSelectedItem: true,
                              showSearchBox: true,
                              // validator: (v) => v == null
                              //     ? "This Field Is required"
                              //     : null,
                              popupTitle: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                    child: Text(
                                  'List Of Registered Customers',
                                )),
                              ),
                              searchFieldProps: TextFieldProps(
                                controller: _dealerEditTextController,
                                decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.cyan,
                                      ),
                                    ),
                                    fillColor: const Color(0xfff3f3f4),
                                    filled: true,
                                    labelText: "Search",
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.fromLTRB(
                                        30, 10, 15, 10),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.clear),
                                      color: Colors.red,
                                      onPressed: () {
                                        _dealerEditTextController.clear();
                                      },
                                    )),
                              ),
                              mode: Mode.BOTTOM_SHEET,
                              popupElevation: 20,

                              dropdownSearchDecoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  icon: isCustomerSelected
                                      ? const Icon(
                                          Icons.verified_user_outlined,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          Icons.person_add_alt_1_outlined,
                                          color: Colors.red,
                                        ),
                                  fillColor: const Color(0xfff3f3f4),
                                  filled: true,
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(30, 5, 10, 5),
                                  hintText: "Select Customer",
                                  border: InputBorder.none),
                              compareFn: (i, s) => i!.isEqual(s),

                              onFind: (filter) => getData(filter, "1"),

                              onChanged: (data) {
                                setState(() {
                                  customerId = data!.id;
                                  customerName = null;
                                  mobileNumber = null;
                                  categoryId = null;
                                  physicalAdress = null;
                                  isCustomerSelected = true;
                                  isCustomerRegistered = false;
                                });
                              },

                              popupItemBuilder: _customPopupItemBuilderCustomer,
                            ),
                          ),
                          SizedBox(
                            height: getProportionateScreenHeight(10),
                          ),
                          InkWell(
                            onTap: () {
                              createUser();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(
                                  flex: 4,
                                  child: Center(
                                    child: Text(
                                      "New Customer",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: isCustomerRegistered
                                      ? const Icon(Icons.verified_user_outlined,
                                          color: Colors.green)
                                      : const Icon(
                                          Icons.app_registration,
                                          color: Colors.pink,
                                        ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: getProportionateScreenHeight(20),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(10),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: ExpansionTileCard(
                      key: cardB,
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
                            Icons.sell_outlined,
                            color: kPrimaryColor,
                          )),
                      title: const Text('Make Order'),
                      children: <Widget>[
                        const Divider(
                          thickness: 1.0,
                          height: 1.0,
                          color: Colors.cyan,
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 5, right: 5, left: 5),
                            child: DropdownButtonFormField<String>(
                              itemHeight: 50,
                              decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  fillColor: const Color(0xfff3f3f4),
                                  filled: true,
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(30, 10, 15, 10),
                                  labelText: "Select Type",
                                  border: InputBorder.none),
                              isExpanded: true,

                              value: typeSeed,
                              //elevation: 5,
                              style: const TextStyle(
                                  color: Colors.white, fontFamily: 'Ubuntu'),
                              iconEnabledColor: Colors.black,
                              items: typeseeds.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem(
                                  value: value,
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
                                      value,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
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
                                      .requestFocus(FocusNode());
                                  typeSeed = value!;
                                  typeSeed == "Seed"
                                      ? isSeed = true
                                      : isSeed = false;
                                  //print((typeSeed);
                                });
                              },
                            ),
                          ),
                        ),
                        isSeed
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, right: 5, left: 5),
                                child: DropdownSearch<SeedModel>(
                                  // showSelectedItem: true,
                                  showSearchBox: true,
                                  validator: (v) => v == null
                                      ? "This Field Is required"
                                      : null,
                                  popupTitle: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text(
                                      'List Of Seeds',
                                    )),
                                  ),
                                  searchFieldProps: TextFieldProps(
                                    controller: _seedEditTextController,
                                    decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: Colors.cyan,
                                          ),
                                        ),
                                        fillColor: const Color(0xfff3f3f4),
                                        filled: true,
                                        labelText: "Search",
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                30, 10, 15, 10),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear),
                                          color: Colors.red,
                                          onPressed: () {
                                            _seedEditTextController.clear();
                                          },
                                        )),
                                  ),
                                  mode: Mode.BOTTOM_SHEET,
                                  popupElevation: 20,

                                  dropdownSearchDecoration: InputDecoration(
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
                                          30, 5, 10, 5),
                                      hintText: "Select Seed",
                                      border: InputBorder.none),
                                  compareFn: (i, s) => i!.isEqual(s),

                                  onFind: (filter) => getDataSeed(filter, "1"),

                                  onChanged: (data) {
                                    seedname = data!.name;
                                    price = double.parse(data.price);
                                    seedId = data.id;

                                    // //print((seedname);
                                    // //print((price);
                                  },

                                  popupItemBuilder: _customPopupItemBuilderSeed,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, right: 5, left: 5),
                                child: DropdownSearch<SeedlingModel>(
                                  // showSelectedItem: true,
                                  showSearchBox: true,
                                  validator: (v) => v == null
                                      ? "This Field Is required"
                                      : null,
                                  popupTitle: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text(
                                      'List Of Seedlings',
                                    )),
                                  ),
                                  searchFieldProps: TextFieldProps(
                                    controller: _seedlingEditTextController,
                                    decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: Colors.cyan,
                                          ),
                                        ),
                                        fillColor: const Color(0xfff3f3f4),
                                        filled: true,
                                        labelText: "Search",
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                30, 10, 15, 10),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear),
                                          color: Colors.red,
                                          onPressed: () {
                                            _seedlingEditTextController.clear();
                                          },
                                        )),
                                  ),
                                  mode: Mode.BOTTOM_SHEET,
                                  popupElevation: 20,

                                  dropdownSearchDecoration: InputDecoration(
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
                                          30, 5, 10, 5),
                                      hintText: "Select Seedling",
                                      border: InputBorder.none),
                                  compareFn: (i, s) => i!.isEqual(s),

                                  onFind: (filter) =>
                                      getDataSeedling(filter, "1"),

                                  onChanged: (data) {
                                    seedname = data!.name;
                                    price = double.parse(data.price);
                                    seedlingId = data.id;
                                    //print((seedlingId.toString());
                                    //print((seedname);
                                    //print((price);
                                  },

                                  popupItemBuilder:
                                      _customPopupItemBuilderSeedling,
                                ),
                              ),
                        isSeed
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, right: 5, left: 5),
                                child: DropdownSearch<AccessionNumberModel>(
                                  // showSelectedItem: true,
                                  showSearchBox: true,
                                  validator: (v) => v == null
                                      ? "This Field Is required"
                                      : null,
                                  popupTitle: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text(
                                      'List Of Accession Number',
                                    )),
                                  ),
                                  searchFieldProps: TextFieldProps(
                                    controller: _accessionEditTextController,
                                    decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: Colors.cyan,
                                          ),
                                        ),
                                        fillColor: const Color(0xfff3f3f4),
                                        filled: true,
                                        labelText: "Search",
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                30, 10, 15, 10),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear),
                                          color: Colors.red,
                                          onPressed: () {
                                            _accessionEditTextController
                                                .clear();
                                          },
                                        )),
                                  ),
                                  mode: Mode.BOTTOM_SHEET,
                                  popupElevation: 20,

                                  dropdownSearchDecoration: InputDecoration(
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
                                          30, 5, 10, 5),
                                      hintText: "Select Accession Number",
                                      border: InputBorder.none),
                                  compareFn: (i, s) => i!.isEqual(s),

                                  onFind: (filter) =>
                                      getDataAccessionNumber(filter, seedId),

                                  onChanged: (data) {
                                    accessionNumber = data!.id;
                                    // acc = int.parse(data.price);
                                    //seedId = data.id;

                                    // //print((seedname);
                                    // //print((price);
                                  },

                                  popupItemBuilder:
                                      _customPopupItemBuilderAccessionNumber,
                                ),
                              )
                            : Container(),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 5, right: 5, left: 5),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            key: const Key(""),
                            onSaved: (val) => quantity = double.parse(val!),
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: const BorderSide(
                                  color: Colors.cyan,
                                ),
                              ),
                              fillColor: const Color(0xfff3f3f4),
                              filled: true,
                              labelText: "Quantity(Kg/Pcs)",
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(30, 10, 15, 10),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "This Field Is Required";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(10),
                        ),
                        _saveData()
                      ],
                    ),
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
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                      "Name",
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
                        for (var i = 0; i < orderData.length; i++)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                          child: Text(orderData[i]["seed_name"]
                                              .toString()),
                                        )),
                                    Expanded(
                                        flex: 3,
                                        child: Center(
                                          child: Text((double.parse(
                                                      orderData[i]["price"]) *
                                                  double.parse(
                                                      orderData[i]["quantity"]))
                                              .toString()),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Center(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: IconButton(
                                                  onPressed: () {
                                                    computeQuantity(
                                                        index: i,
                                                        quantit: double.parse(
                                                            orderData[i]
                                                                ["quantity"]));
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                    formatNumber.format(calculateSum()),
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

            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom,
            ),
          ],
        ),
      ),
    );
  }

  message(String desc, String type, {int? index, bool? isBillMessage}) {
    return Alert(
      style: const AlertStyle(descStyle: TextStyle(fontSize: 17)),
      context: context,
      type: type == 'error'
          ? AlertType.warning
          : type == 'success'
              ? AlertType.success
              : AlertType.info,
      desc: desc,
      buttons: [
        DialogButton(
          onPressed: () async {
            if (index != null) {
              setState(() {
                orderData.removeAt(index);
              });
            }
            Navigator.pop(context);
            //print((orderData);
            //print((customerId);
            //print((customerName);
            //print((mobileNumber);
            //print((categoryId);
            isBillMessage! ? await postBill() : "";
          },
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          color: Colors.red,
          onPressed: () {
            Navigator.pop(context);
            //isBillMessage! ? await uploadData() : ""
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

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (isCustomerRegistered || isCustomerSelected) {
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

  Future computeQuantity({int? index, double? quantit}) {
    return Alert(
        style: const AlertStyle(descStyle: TextStyle(fontSize: 17)),
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
                  initialValue: quantit == null ? "1" : quantit.toString(),
                  keyboardType: TextInputType.number,
                  key: const Key(""),
                  onSaved: (val) => quantity = double.parse(val!),
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
                    orderData[index]["quantity"] = quantity.toString();
                  }

                  //print((orderData);
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

  Widget _saveData() {
    return InkWell(
      onTap: () async {
        if (_formKey1.currentState!.validate()) {
          _formKey1.currentState!.save();

          setState(() {
            var data = {
              "order_item": typeSeed,
              "seed_id": seedId,
              "seedling_id": seedlingId,
              "assesment_id": accessionNumber,
              "quantity": quantity.toString(),
              "price": price.toString(),
              "seed_name": seedname
            };
            orderData.add(data);
            _dealerEditTextController.clear();
            _accessionEditTextController.clear();
            _seedEditTextController.clear();
            _seedlingEditTextController.clear();
            seedId = "0";
            seedlingId = "0";
            price = null;
            seedname = null;
            typeSeed = null;
            accessionNumber = null;

            cardB.currentState?.collapse();
            ////print((orderData);

            cardC.currentState?.expand();

            calculateSum();
          });
          // _dealerEditTextController = TextEditingController();
          _formKey1.currentState!.reset();
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
                    'Save Bill Data',
                    style: TextStyle(fontSize: 13.0.sp, color: Colors.black),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _customPopupItemBuilderCustomer(
      BuildContext context, CustomerModel item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
          title: Text(item.name),
          subtitle: Text("Phone#: ${item.phoneNumber}"),
          tileColor: const Color(0xfff3f3f4),
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person_add_alt_1_outlined),
          ),
        ),
      ),
    );
  }

  Widget _customPopupItemBuilderAccessionNumber(
      BuildContext context, AccessionNumberModel item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
          title: Text("Accession#: ${item.accessionNumber}"),
          subtitle: Text("balance: ${item.assesmentNumber}"),
          tileColor: const Color(0xfff3f3f4),
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.format_list_numbered_outlined),
          ),
        ),
      ),
    );
  }

  Widget _customPopupItemBuilderSeedling(
      BuildContext context, SeedlingModel item, bool isSelected) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: !isSelected
            ? null
            : BoxDecoration(
                border: Border.all(color: kPrimaryColor),
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ]),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(children: [
                      SizedBox(
                          width: 50,
                          height: 40,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[200],
                                child: const Icon(
                                  Icons.line_weight_outlined,
                                  color: Colors.black38,
                                ),
                              ))),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("name: ${item.name}",
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(
                                height: 5,
                              ),
                              Text("Price: ${item.price}",
                                  style: TextStyle(color: Colors.grey[500])),
                            ]),
                      )
                    ]),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        //job.isMyFav = !job.isMyFav;
                      });
                    },
                    child: AnimatedContainer(
                        height: 35,
                        padding: const EdgeInsets.all(5),
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.yellow.shade100)),
                        child: const Center(
                            child: Icon(
                          Icons.arrow_forward_ios,
                          color: kPrimaryColor,
                        ))),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue.shade50),
                        child: Center(
                          child: Text(
                            item.balance == "null"
                                ? " "
                                : "Balance: ${item.balance}",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(30)),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.deepPurple.shade50),
                        child: Center(
                          child: Text(
                            item.size == "null"
                                ? "Size: "
                                : "Size: ${item.size}",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(5),
              ),
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.green.shade50),
                        child: Center(
                          child: Text(
                            item.category == "null"
                                ? "Category: "
                                : "Category: ${item.category}",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(30)),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.cyan.shade50),
                        child: Center(
                          child: Text(
                            item.type == "null"
                                ? "Type: "
                                : "Type: ${item.type}",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget _customPopupItemBuilderSeed(
      BuildContext context, SeedModel item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
          title: Text(item.name),
          subtitle: Text("Unit Price: ${item.price}"),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Balance",
                style: TextStyle(color: Colors.blue),
              ),
              Text("${item.balance}Kg"),
            ],
          ),
          tileColor: const Color(0xfff3f3f4),
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.ac_unit_outlined),
          ),
        ),
      ),
    );
  }

  Future<List<CustomerModel>> getData(filter, level) async {
    String url;
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    //print((tokens);
    var headers = {"Authorization": "Bearer $tokens"};
    url = "$baseUrlSeed/api/v1/customers";
    var response = await Dio().get(url,
        queryParameters: {
          "filter": filter,
        },
        options: Options(headers: headers));

    final data = response.data;
    //print((data['data']);
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
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    //print((tokens);
    var headers = {"Authorization": "Bearer $tokens"};
    url = "$baseUrlSeed/api/v1/accession-number/$seedId";
    var response = await Dio().get(url,
        queryParameters: {
          "filter": filter,
        },
        options: Options(headers: headers));

    final data = response.data;
    //print((data['data']);
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
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    //print((tokens);
    var headers = {"Authorization": "Bearer $tokens"};
    url = "$baseUrlSeed/api/v1/seeds";
    var response = await Dio().get(url,
        queryParameters: {"filter": filter},
        options: Options(headers: headers));

    final data = response.data;
    //print((data);
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
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    //print((tokens);
    var headers = {"Authorization": "Bearer $tokens"};
    url = "$baseUrlSeed/api/v1/seedlings";
    var response = await Dio().get(url,
        queryParameters: {"filter": filter},
        options: Options(headers: headers));

    final data = response.data;
    //print((data['data']);
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
      //print((id);
      //print(("djvnjdw");
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      //print((tokens);
      var headers = {"Authorization": "Bearer $tokens"};
      var url = Uri.parse('$baseUrlSeed/api/v1/bills/$id');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //print((response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print((res);
          });
          await getControllNumber(4);
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print((res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        //print((e);
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
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // //print((tokens);
      // //print((id.toString());
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      //print((tokens);
      var headers = {"Authorization": "Bearer $tokens"};
      var url = Uri.parse('$baseUrlSeed/api/v1/controlnumber/$billId');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //print((response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print((res);
            //widget.callback(jsonEncode(res["data"]));
            messages("success", "C/N:  ${res["data"]["control_number"]}");
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print((res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        //print((e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
