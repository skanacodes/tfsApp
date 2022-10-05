// ignore_for_file: file_names, avoid_//print

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/services/constants.dart';

import 'package:tfsappv1/services/modal/dealer.dart';
import 'package:tfsappv1/services/modal/gfsCodes.dart';
import 'package:tfsappv1/services/renew_session.dart';
import 'package:tfsappv1/services/size_config.dart';

import 'package:sizer/sizer.dart';

class FremisBills extends StatefulWidget {
  const FremisBills({Key? key}) : super(key: key);

  @override
  State<FremisBills> createState() => _FremisBillsState();
}

class _FremisBillsState extends State<FremisBills> {
  String result = "";
  final _gfsTextController = TextEditingController();
  final _dealerEditTextController = TextEditingController();
  List billData = [];
  List distributions = [];
  String? desc;
  String? billdesc;
  double? unitAmount;
  String? gfcCode;
  String? levelTwoCode;
  bool isVerify = false;
  bool isBillDescrAvailable = false;
  final value = NumberFormat("#,##0.00", "en_US");
  bool isLoading = false;
  bool isCustomerSelected = false;
  bool isCustomerRegistered = false;
  String? customerName;
  String? email;
  String? customerId;
  List<int> stationIds = [];

  bool isNewCustomer = false;
  double quantity = 1;

  String? fullname;
  String? mobileNumber;

  List<int> quantities = [];

  final GlobalKey<ExpansionTileCardState> cardA = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardB = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardC = GlobalKey();
  List<String> ask = ['Registered Dealers', 'Non Registered Dealers'];
  List<String> typeseeds = ['Seed', 'Seedling'];
  String? type;
  int sum = 0;
  String? ask1;
  double? compountAmt;
  double total = 0;
  final _formKey = GlobalKey<FormState>();
  final _formKeydescr = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  var overallSumation;
  double calculateSum() {
    double sumation = 0;
    for (var i = 0; i < billData.length; i++) {
      setState(() {
        ////////////print(amount);
        sumation = sumation + double.parse(billData[i]["amount"].toString());
        total = sumation;
      });
      //////////print(sumation);
    }
    return sumation;
  }

  @override
  void dispose() {
    super.dispose();
    _dealerEditTextController.dispose();
    _gfsTextController.dispose();
  }

  Future uploadData() async {
    setState(() {
      isLoading = true;
    });
    ////print(billData);

    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    var stationId = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt('station_id'));
    var checkpoint = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('checkpointId'));

    try {
      var headers = {"Authorization": "Bearer ${tokens!}"};
      BaseOptions options = BaseOptions(
          baseUrl: baseUrlTest,
          connectTimeout: 50000,
          receiveTimeout: 50000,
          headers: headers);
      var dio = Dio(options);
      var formData = FormData.fromMap({
        "payer_id": customerId,
        "payer_name": customerName,
        "payer_cell_no": mobileNumber,
        "payer_email": email,
        "bill_desc": billdesc,
        "bill_amount": total,
        "station_id": stationId,
        "checkpoint_id": checkpoint,
        "bill_items": billData,
      });

      var response = await dio.post("$baseUrlTest/api/v1/pos/save-bill",
          data: formData, onSendProgress: (int sent, int total) {
        // setState(() {
        //   uploadMessage = sent.toString();
        // });
        //////////print('$sent $total');
      });
      ////print(response.statusCode);
      ////print(response.statusMessage);
      ////print(response.data);
      var res = response.data;
      //////print(res);
      if (response.statusCode == 201) {
        message(
          'Bill Generated Successfully',
          'success',
        );
      } else if (response.statusCode == 200) {
        if (res["status"].toString() == "Token is Expired") {
          // messages("error", "Token Expired.. Please Login Again");
          // ignore: use_build_context_synchronously
          RenewSession().renewSessionForm(
            context,
          );
        } else {
          message(res["message"].toString(), 'error');
        }
      } else {
        message(res["message"].toString(), 'error');
      }
    } on DioError catch (e) {
      //////////print('dio package');
      if (DioErrorType.receiveTimeout == e.type ||
          DioErrorType.connectTimeout == e.type) {
        message('Server Can Not Be Reached.', 'error');
        // throw Exception('Server Can Not Be Reached');
        //////////print(e);
      } else if (DioErrorType.response == e.type) {
        // throw Exception('Server Can Not Be Reached');

        message('Failed To Get Response From Server.', 'error');
        // throw Exception('Server Can Not Be Reached');
        //////////print(e);
      } else if (DioErrorType.other == e.type) {
        if (e.message.contains('SocketException')) {
          // throw Exception('Server Can Not Be Reached');
          message(
            'Network Connectivity Problem.',
            'error',
          );

          //////////print(e);
        }
      } else {
        //  throw Exception('Server Can Not Be Reached');
        message('error',
            'Network Connectivity Problem. Data Has Been Stored Localy');
        // throw Exception('Server Can Not Be Reached');
        //////////print(e);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        message("Are You Sure You Want To Generate This Bill", "info",
            isBillMessage: true);
      },
      child: Padding(
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

  message(String desc, String type,
      {int? index, bool? isBillMessage, StateSetter? updateState}) {
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
              updateState!(() {
                billData.removeAt(index);
                overallSumation = calculateSum();
                // honeyId.removeAt(index);
                // quantities.removeAt(index);
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
        title: "Add Dealer",
        style: AlertStyle(titleStyle: TextStyle(fontSize: 12.sp)),
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
                    labelStyle: TextStyle(fontSize: 12.sp),
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
                    labelStyle: TextStyle(fontSize: 12.sp),
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
                  keyboardType: TextInputType.emailAddress,
                  key: const Key(""),
                  onSaved: (val) => email = val!,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                      ),
                    ),
                    labelStyle: TextStyle(fontSize: 12.sp),
                    fillColor: const Color(0xfff3f3f4),
                    filled: true,
                    labelText: "Email Address",
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

                setState(() {
                  customerId = "11";
                });

                _dealerEditTextController.clear();
                setState(() {
                  isCustomerRegistered = true;
                });

                cardB.currentState?.expand();
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
                Navigator.pop(context);
              }
            },
            child: Text(
              "Register",
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
          DialogButton(
            color: Colors.red,
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          )
        ]).show();
  }

  Future computeQuantity(StateSetter updateState,
      {int? index, double? quantit}) {
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
                //////////print(index);
                updateState(() {
                  if (index != null) {
                    billData[index]["quantity"] = quantity;
                    // quantities[index] = quantity;
                    // //////////print(quantities);
                  }

                  ////print(billData);
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

  Future billDescr() {
    return Alert(
        context: context,
        onWillPopActive: true,
        title: "Enter Bill Description",
        content: Form(
          key: _formKeydescr,
          child: Column(
            children: <Widget>[
              const Divider(
                thickness: 1.0,
                height: 1.0,
                color: Colors.black26,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  key: const Key("name"),
                  maxLines: 4,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                      ),
                    ),
                    fillColor: const Color(0xfff3f3f4),
                    filled: true,
                    labelText: "Enter Bill Description",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "This Field Is Required";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    billdesc = value;
                  },
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
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
      child: isLoading
          ? SpinKitFadingCircle(
              color: kPrimaryColor,
              size: 35.0.sp,
            )
          : forms(),
    );
  }

  forms() {
    return Column(children: [
      SizedBox(
        height: getProportionateScreenHeight(1200),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey1,
              child: Expanded(
                child: Column(
                  children: <Widget>[
                    SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 1, right: 16, left: 16),
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
                              labelText: "Select Type Of Dealer",
                              border: InputBorder.none),
                          isExpanded: true,

                          value: ask1,
                          //elevation: 5,
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'Ubuntu'),
                          iconEnabledColor: Colors.black,
                          items:
                              ask.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xfff3f3f4),
                                  // boxShadow: <BoxShadow>[
                                  //   // BoxShadow(color: Colors.grey)
                                  //   // BoxShadow(
                                  //   //     color: Colors.grey.shade200,
                                  //   //     offset: Offset(2, 4),
                                  //   //     blurRadius: 5,
                                  //   //     spreadRadius: 2)
                                  // ],
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: kPrimaryColor),
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
                              ask1 = value!;
                              ask1 != "Registered Dealers"
                                  ? createUser()
                                  : null;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    ask1 == "Registered Dealers"
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 1, right: 16, left: 16),
                            child: DropdownSearch<DealerModel>(
                              // showSelectedItem: true,
                              showSearchBox: true,

                              // validator: (v) => v == null
                              //     ? "This Field Is required"
                              //     : null,
                              popupTitle: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                    child: Text(
                                  'List Of Registered Dealers',
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
                                    labelText: "Search By First Name",
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
                                  // icon: isCustomerSelected
                                  //     ? const Icon(
                                  //         Icons.verified_user_outlined,
                                  //         color: Colors.green,
                                  //       )
                                  //     : const Icon(
                                  //         Icons.person_add_alt_1_outlined,
                                  //         color: Colors.red,
                                  //       ),
                                  fillColor: const Color(0xfff3f3f4),
                                  filled: true,
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(30, 5, 10, 5),
                                  hintText: "Select Customer",
                                  border: InputBorder.none),
                              compareFn: (i, s) => i!.isEqual(s),

                              onFind: (filter) => getDataDealer(filter, "1"),

                              onChanged: (data) {
                                setState(() {
                                  customerId = data!.id;
                                  customerName = data.companyName == "null"
                                      ? "${data.fname} ${data.mname} ${data.lname}"
                                      : data.companyName;
                                  mobileNumber = data.phoneNumber;
                                  email = data.email;

                                  isCustomerRegistered = false;
                                });
                              },

                              popupItemBuilder: _customPopupItemBuilderCustomer,
                            ),
                          )
                        : Container(),
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
                        title: const Text('Add Bill Information'),
                        children: <Widget>[
                          const Divider(
                            thickness: 1.0,
                            height: 1.0,
                            color: Colors.cyan,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5, right: 5, left: 5),
                            child: DropdownSearch<GfsModel>(
                              // showSelectedItem: true,
                              showSearchBox: true,
                              validator: (v) =>
                                  v == null ? "This Field Is required" : null,
                              popupTitle: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                    child: Text(
                                  'List Of GFSCodes',
                                )),
                              ),
                              searchFieldProps: TextFieldProps(
                                controller: _gfsTextController,
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
                                        _gfsTextController.clear();
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
                                  fillColor: const Color(0xfff3f3f4),
                                  filled: true,
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(30, 5, 10, 5),
                                  hintText: "Select GFS Code",
                                  border: InputBorder.none),
                              compareFn: (i, s) => i!.isEqual(s),

                              onFind: (filter) => getData(filter, "1"),

                              onChanged: (data) {
                                setState(() {
                                  desc = data!.description;
                                  unitAmount = double.parse(data.amount);
                                  gfcCode = data.gfsCode;
                                  levelTwoCode = data.levelTwoId;
                                  distributions = data.distributions;
                                  !isBillDescrAvailable
                                      ? billdesc = data.description
                                      : "";

                                  //////print(distributions);
                                  ////////print(desc);
                                });
                                // //////////print(amount);
                              },

                              popupItemBuilder: _customPopupItemBuilderGFSCode,
                            ),
                          ),
                          levelTwoCode == "4"
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5, right: 5, left: 5),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    key: const Key(""),
                                    onSaved: (val) =>
                                        compountAmt = double.parse(val!),
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
                                      labelText: "Compounding Amount",
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          30, 10, 15, 10),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "This Field Is Required";
                                      }
                                      return null;
                                    },
                                  ),
                                )
                              : levelTwoCode == "14" &&
                                      (desc ==
                                              "Receipts from sale of Confiscated Forest Products" ||
                                          desc ==
                                              "Inspection Fee For Private Planted Trees - 20% of original")
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 5, left: 5),
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        key: const Key(""),
                                        onSaved: (val) =>
                                            compountAmt = double.parse(val!),
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
                                          labelText: " Amount",
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  30, 10, 15, 10),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "This Field Is Required";
                                          }
                                          return null;
                                        },
                                      ),
                                    )
                                  : unitAmount == 0
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, right: 5, left: 5),
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            key: const Key(""),
                                            onSaved: (val) => compountAmt =
                                                double.parse(val!),
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                borderSide: const BorderSide(
                                                  color: Colors.cyan,
                                                ),
                                              ),
                                              fillColor:
                                                  const Color(0xfff3f3f4),
                                              filled: true,
                                              labelText: " Amount",
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.fromLTRB(
                                                      30, 10, 15, 10),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "This Field Is Required";
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, right: 5, left: 5),
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            key: const Key(""),
                                            onSaved: (val) =>
                                                quantity = double.parse(val!),
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                borderSide: const BorderSide(
                                                  color: Colors.cyan,
                                                ),
                                              ),
                                              fillColor:
                                                  const Color(0xfff3f3f4),
                                              filled: true,
                                              labelText: "Quantity",
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.fromLTRB(
                                                      30, 10, 15, 10),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "This Field Is Required";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                          !isBillDescrAvailable
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, right: 10, left: 10),
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    key: const Key("name"),
                                    maxLines: 4,
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
                                      labelText: "Enter Bill Description",
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          30, 10, 15, 10),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "This Field Is Required";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      billdesc = value;
                                    },
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: getProportionateScreenHeight(10),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: getProportionateScreenHeight(30),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    if (_formKey1.currentState!.validate()) {
                                      _formKey1.currentState!.save();
                                      ////////print(bill)0p9

                                      var amt;
                                      levelTwoCode == "4"
                                          ? amt = compountAmt
                                          : levelTwoCode == "14" &&
                                                  (desc ==
                                                          "Receipts from sale of Confiscated Forest Products" ||
                                                      desc ==
                                                          "Inspection Fee For Private Planted Trees - 20% of original")
                                              ? amt = compountAmt
                                              : unitAmount == 0
                                                  ? amt = compountAmt
                                                  : amt =
                                                      (unitAmount! * quantity);

                                      Map billElements = {
                                        "amount": amt,
                                        "product_name": desc,
                                        "gfs_code": gfcCode,
                                        "quantity": quantity,
                                        "prod_desc": desc
                                      };
                                      //////////print(billElements);

                                      billData.add(billElements);
                                      //////////print(billData);

                                      setState(() {
                                        desc = null;
                                        unitAmount = null;
                                        gfcCode = null;
                                        quantity = 0;
                                        isBillDescrAvailable = true;
                                        cardB.currentState?.collapse();

                                        overallSumation = calculateSum();
                                      });
                                      // _dealerEditTextController = TextEditingController();
                                      _formKey1.currentState!.reset();
                                      //billDescr();
                                      showModal();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green, // Background color
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.inventory_outlined),
                                      SizedBox(
                                        width: getProportionateScreenWidth(10),
                                      ),
                                      const Text("Save Bill Item")
                                    ],
                                  )),
                              SizedBox(
                                height: getProportionateScreenHeight(20),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: getProportionateScreenHeight(10),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              showModal();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green, // Background color
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.mail),
                                SizedBox(
                                  width: getProportionateScreenWidth(10),
                                ),
                                const Text("Show Bill(s) Item")
                              ],
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  showModal() {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.0),
          ),
        ),
        builder: (context) {
          return StatefulBuilder(builder: (context, state) {
            return Wrap(children: [
              ListTile(
                leading: const Icon(
                  Icons.select_all_outlined,
                  color: Colors.green,
                ),
                title: const Text(
                  "Bills Item(s) List",
                ),
                trailing: InkWell(
                  onTap: (() => Navigator.of(context).pop()),
                  child: CircleAvatar(
                      radius: 10.sp,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.close_outlined,
                        size: 10.sp,
                      )),
                ),
              ),
              const Divider(
                thickness: 1.0,
                height: 3.0,
                color: Colors.grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 13.sp),
                          const Text("Add Item"),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        cardB.currentState?.expand();
                      }),
                ],
              ),
              const Divider(
                thickness: 1.0,
                height: 3.0,
                color: Colors.grey,
              ),
              Column(
                //mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Divider(
                    thickness: 1.0,
                    height: 1.0,
                    color: Colors.grey,
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
                                "desc",
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
                                      "${i + 1}.",
                                    ),
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      billData[i]["product_name"].toString(),
                                    ),
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      value.format(billData[i]["amount"]),
                                    ),
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
                                              computeQuantity(state,
                                                  index: i,
                                                  quantit: billData[i]
                                                          ["quantity"]
                                                      .toDouble());
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
                                                index: i,
                                                updateState: state,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.remove_circle_outline_sharp,
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
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Expanded(
                            flex: 1, child: Center(child: Text(" "))),
                        const Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                "Total amount:  ",
                                style: TextStyle(color: Colors.black),
                              ),
                            )),
                        Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                overallSumation == null
                                    ? "0"
                                    : value.format(overallSumation),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                        const Expanded(
                            flex: 2, child: Center(child: Text(" "))),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Divider(
                      thickness: 1.0,
                      height: 1.0,
                      color: Colors.grey,
                    ),
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
                  SizedBox(
                    height: getProportionateScreenHeight(30),
                  ),
                ],
              ),
            ]);
          });
        });
  }

  loading() {
    return Alert(
        context: context,
        desc: "Generating Bill...",
        style: AlertStyle(
            descStyle: TextStyle(
              fontSize: 13.sp,
              fontFamily: "Ubuntu",
            ),
            isButtonVisible: false,
            isCloseButton: false),
        onWillPopActive: true,
        content: Column(
          children: [
            SpinKitThreeBounce(
              color: kPrimaryColor,
              size: 20.sp,
            )
          ],
        )).show();
  }

  Widget _customPopupItemBuilderGFSCode(
      BuildContext context, GfsModel item, bool isSelected) {
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
          title: Text("Description: ${item.description}"),
          subtitle: Text("Bill Amount: ${item.amount}"),
          tileColor: const Color(0xfff3f3f4),
          leading: IntrinsicHeight(
              child: SizedBox(
                  height: double.maxFinite,
                  width: getProportionateScreenHeight(50),
                  child: Row(
                    children: [
                      VerticalDivider(
                        color: int.parse(item.id).isEven
                            ? kPrimaryColor
                            : Colors.green[200],
                        thickness: 5,
                      )
                    ],
                  ))),
        ),
      ),
    );
  }

  Future<List<DealerModel>> getDataDealer(filter, level) async {
    String url;
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    //////////print(tokens);
    var headers = {"Authorization": "Bearer ${tokens!}"};
    url = "$baseUrlTest/api/v1/dealers";
    var response = await Dio().get(url,
        queryParameters: {
          "filter": filter,
        },
        options: Options(headers: headers));

    final data = response.data;
    if (data["status"].toString() == "Token is Expired") {
      // ignore: use_build_context_synchronously
      RenewSession().renewSessionForm(
        context,
      );
    }

    return DealerModel.fromJsonList(data['dealers']);
  }

  Widget _customPopupItemBuilderCustomer(
      BuildContext context, DealerModel item, bool isSelected) {
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
          title: Text(item.companyName == "null"
              ? ("${item.fname} ${item.mname == "null" ? " " : item.mname} ${item.lname}")
              : item.companyName),
          subtitle: Text("Phone#: ${item.phoneNumber}"),
          tileColor: const Color(0xfff3f3f4),
          leading: IntrinsicHeight(
              child: SizedBox(
                  height: double.maxFinite,
                  width: getProportionateScreenHeight(50),
                  child: Row(
                    children: [
                      VerticalDivider(
                        color: item.companyName == "null"
                            ? kPrimaryColor
                            : Colors.green[200],
                        thickness: 5,
                      )
                    ],
                  ))),
        ),
      ),
    );
  }

  Future<List<GfsModel>> getData(filter, level) async {
    String url;

    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    //////print(tokens);
    var headers = {"Authorization": "Bearer ${tokens!}"};
    url = "$baseUrlTest/api/v1/gfs_codes/pos";
    var response = await Dio().get(url,
        queryParameters: {
          "filter": filter,
        },
        options: Options(headers: headers));

    final data = response.data;
    ////print(data);
    // var res = jsonDecode(data);
    // ////print(res["status"]);
    if (data["status"].toString() == "Token is Expired") {
      // messages("error", "Token Expired.. Please Login Again");
      // ignore: use_build_context_synchronously
      RenewSession().renewSessionForm(
        context,
      );
    }
    if (data != null) {
      return GfsModel.fromJsonList(data['data']);
    }

    return [];
  }
}
