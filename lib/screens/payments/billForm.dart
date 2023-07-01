// ignore_for_file: file_names, prefer_typing_uninitialized_variables, avoid_print, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/dealer.dart';
import 'package:tfsappv1/services/modal/gfsCodes.dart';

import 'package:tfsappv1/services/size_config.dart';

class BillForm extends StatefulWidget {
  static String routeName = "/billForm";
  const BillForm({Key? key}) : super(key: key);

  @override
  _BillFormState createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? dealerName;
  var datas;
  var gfsCodes;
  int result = 0;
  String? dropdownvalue;
  String? billDesc;
  int quantity = 0;
  int? levelOneId;
  int? levelTwoId;
  int amount = 0;
  double subtotal = 0.0;
  final _dealerEditTextController = TextEditingController();
  String? currency;
  bool isLevelOne = false;
  bool isLevelTwo = false;
  bool isLevelThree = false;

  //DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final formKey = GlobalKey<FormState>();
  final List<DropdownMenuItem<String>> _currencyType = [
    const DropdownMenuItem(
      value: "USD",
      child: Text("USD"),
    ),
    const DropdownMenuItem(
      value: "TSH",
      child: Text("TSH"),
    ),
  ];
  getSum() {
    setState(() {
      print(amount);
      print(quantity);
      result = (amount * quantity);
      print(result);
    });
  }

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

  @override
  void dispose() {
    // Clean up the controller when the widget is removed
    _dealerEditTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    RealTimeCommunication().createConnection(
      "6",
    );
    // this.getDealers();

    super.initState();
  }

  Future getGFSCode() async {
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // print(tokens);
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('http://41.59.227.103:5013/api/Setup/GetTarrifs');
      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            gfsCodes = res;
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

  Future getDealers() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrl/api/v1/dealers');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            // data = res['cargo_data'];
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

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Fill',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: ' Bill ',
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

  Future postDetails() async {
    print("executing");
    try {
      var url = Uri.parse('http://41.59.82.189:9292/api/Bill/PostBillRequest');
      final response = await http.post(
        url,
        body: jsonEncode({
          "ClientPrimaryKey": "ireiuhdbhvjhjfbviufvnnnn",
          "RequestId": 5,
          "CallBackServer": "https://mis.tfs.go.tz",
          "CallBack": "fremis-test/api/v1/update-bill",
          "ValidDays": 3,
          "PyrId": 59,
          "PyrName": "Juma & Company",
          "BillDesc": "Multiple Payments",
          "BillApprBy": null,
          "PaymentCallBack": "fremis-test/api/v1/receive-payment",
          "PyrCellNum": "0764184955",
          "PyrEmail": null,
          "Ccy": "TZS",
          "BillItems": [
            {
              "BillItemRef": 48,
              "BillItemAmt": 2000,
              "BillItemEqvAmt": 200,
              "GfsCode": 142201710276
            }
          ]
        }),
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          // var x = await storetUserDetailsLocaly(0, res['user']['username'],
          //     res['user']['username'], res['user']['email'], password!);
          // if (x == 'success') {
          //   if (res['message'] == 'Login successfully') {
          //     setState(() {
          //       auth = 'success';
          //       useremail = res['user']['email'];
          //     });

          //     await createUser(res['user']['token'], res['user']['username'],
          //         res['user']['email']);
          //     // await storeVehicleTypeLocal();
          //     // await storeCargoChargeLocal();
          //     // await storeDefaultPrivateList();
          //   } else if (res['message'] == 'Invalid username or password') {
          //     addError(error: 'Incorrect Password or Email');
          //   } else {
          //     addError(error: 'Something Went Wrong');
          //   }
          // }

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
      });
    }
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        await postDetails();
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

  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    // print(args.gfsCode);
    // print(args.description);
    // print(args.unitPrice);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' Bill Form',
          style: TextStyle(color: Colors.black, fontFamily: 'ubuntu'),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: getProportionateScreenHeight(700),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: getProportionateScreenHeight(140),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: getProportionateScreenHeight(100),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(100),
                                bottomRight: Radius.circular(100)),
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
                                  subtitle: Text(
                                      DateFormat('yyyy-MM-dd hh:mm:ss')
                                          .format(DateTime.now())
                                          .toString()),
                                  title: const Text(
                                    'Generate Bill Form',
                                    style: TextStyle(color: Colors.black),
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
                                  _title(),
                                  SizedBox(
                                    height: getProportionateScreenHeight(10),
                                  ),
                                  SizedBox(
                                      height: getProportionateScreenHeight(10)),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 18, left: 18),
                                    child: DropdownSearch<GfsModel>(
                                      // showSelectedItem: true,
                                      showSearchBox: true,
                                      validator: (v) => v == null
                                          ? "This Field Is required"
                                          : null,
                                      popupTitle: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                            child: Text(
                                          'List Of GFS-CODE for Level One',
                                        )),
                                      ),
                                      searchFieldProps: TextFieldProps(
                                        controller: _dealerEditTextController,
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
                                                _dealerEditTextController
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
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  30, 5, 10, 5),
                                          hintText: "Select Level 1 GFS Code",
                                          border: InputBorder.none),
                                      compareFn: (i, s) => i!.isEqual(s),

                                      onFind: (filter) => getData(filter, "1"),

                                      onChanged: (data) {
                                        setState(() {
                                          levelOneId = int.parse(data!.id);
                                          print(levelOneId);

                                          isLevelTwo = true;
                                          isLevelThree = false;
                                          // unit = data.unit;
                                        });
                                      },

                                      popupItemBuilder:
                                          _customPopupItemBuilderGFS,
                                    ),
                                  ),
                                  isLevelTwo
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, right: 18, left: 18),
                                          child: DropdownSearch<GfsModel>(
                                            // showSelectedItem: true,
                                            showSearchBox: true,
                                            validator: (v) => v == null
                                                ? "This Field Is required"
                                                : null,
                                            popupTitle: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Center(
                                                  child: Text(
                                                'List of Level Two GFS-CODE',
                                              )),
                                            ),
                                            searchFieldProps: TextFieldProps(
                                              controller:
                                                  _dealerEditTextController,
                                              decoration: InputDecoration(
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.cyan,
                                                    ),
                                                  ),
                                                  fillColor:
                                                      const Color(0xfff3f3f4),
                                                  filled: true,
                                                  labelText: "Search",
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets.fromLTRB(
                                                          30, 10, 15, 10),
                                                  suffixIcon: IconButton(
                                                    icon:
                                                        const Icon(Icons.clear),
                                                    color: Colors.red,
                                                    onPressed: () {
                                                      _dealerEditTextController
                                                          .clear();
                                                    },
                                                  )),
                                            ),
                                            mode: Mode.BOTTOM_SHEET,
                                            popupElevation: 20,

                                            dropdownSearchDecoration:
                                                InputDecoration(
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.cyan,
                                                      ),
                                                    ),
                                                    fillColor:
                                                        const Color(0xfff3f3f4),
                                                    filled: true,
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets
                                                                .fromLTRB(
                                                            30, 5, 10, 5),
                                                    hintText:
                                                        "Select Level 2 GFS Code",
                                                    border: InputBorder.none),
                                            compareFn: (i, s) => i!.isEqual(s),

                                            onFind: (filter) =>
                                                getData(filter, "2"),

                                            onChanged: (data) {
                                              setState(() {
                                                levelTwoId =
                                                    int.parse(data!.id);

                                                isLevelThree = true;
                                                // unit = data.unit;
                                              });
                                            },

                                            popupItemBuilder:
                                                _customPopupItemBuilderGFS,
                                          ),
                                        )
                                      : Container(),
                                  isLevelThree
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, right: 18, left: 18),
                                          child: DropdownSearch<GfsModel>(
                                            // showSelectedItem: true,
                                            showSearchBox: true,
                                            validator: (v) => v == null
                                                ? "This Field Is required"
                                                : null,
                                            popupTitle: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Center(
                                                  child: Text(
                                                'List of Level Three GFS-CODE',
                                              )),
                                            ),
                                            searchFieldProps: TextFieldProps(
                                              controller:
                                                  _dealerEditTextController,
                                              decoration: InputDecoration(
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.cyan,
                                                    ),
                                                  ),
                                                  fillColor:
                                                      const Color(0xfff3f3f4),
                                                  filled: true,
                                                  labelText: "Search",
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets.fromLTRB(
                                                          30, 10, 15, 10),
                                                  suffixIcon: IconButton(
                                                    icon:
                                                        const Icon(Icons.clear),
                                                    color: Colors.red,
                                                    onPressed: () {
                                                      _dealerEditTextController
                                                          .clear();
                                                    },
                                                  )),
                                            ),
                                            mode: Mode.BOTTOM_SHEET,
                                            popupElevation: 20,

                                            dropdownSearchDecoration:
                                                InputDecoration(
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.cyan,
                                                      ),
                                                    ),
                                                    fillColor:
                                                        const Color(0xfff3f3f4),
                                                    filled: true,
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets
                                                                .fromLTRB(
                                                            30, 5, 10, 5),
                                                    hintText:
                                                        "Select Level 3 GFS Code",
                                                    border: InputBorder.none),
                                            compareFn: (i, s) => i!.isEqual(s),

                                            onFind: (filter) =>
                                                getData(filter, "3"),

                                            onChanged: (data) {
                                              setState(() {
                                                //levelTwoId = int.parse(data!.id);
                                                // unit = data.unit;
                                              });
                                            },

                                            popupItemBuilder:
                                                _customPopupItemBuilderGFS,
                                          ),
                                        )
                                      : Container(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 18, left: 18),
                                    child: DropdownSearch<DealerModel>(
                                      // showSelectedItem: true,
                                      showSearchBox: true,
                                      validator: (v) => v == null
                                          ? "This Field Is required"
                                          : null,
                                      popupTitle: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                            child: Text(
                                          'List Of  Dealers',
                                        )),
                                      ),
                                      searchFieldProps: TextFieldProps(
                                        controller: _dealerEditTextController,
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
                                                _dealerEditTextController
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
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  30, 5, 10, 5),
                                          hintText: "Select Dealer Name",
                                          border: InputBorder.none),
                                      compareFn: (i, s) => i!.isEqual(s),

                                      onFind: (filter) => getDataDealer(filter),

                                      onChanged: (data) {
                                        setState(() {
                                          dealerName = data!.companyName ==
                                                  "null"
                                              ? " ${data.fname}" == "null"
                                                  ? ""
                                                  : "${data.fname} ${data.mname}" ==
                                                          "null"
                                                      ? ""
                                                      : "${data.mname} ${data.lname}" ==
                                                              "null"
                                                          ? "null"
                                                          : data.lname
                                                              .toString()
                                              : data.companyName.toString() ==
                                                      "null"
                                                  ? ""
                                                  : data.companyName.toString();
                                        });
                                      },

                                      popupItemBuilder:
                                          _customPopupItemBuilder2,
                                    ),
                                  ),
                                  SizedBox(
                                    height: getProportionateScreenHeight(10),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 1, right: 16, left: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 1, right: 1, left: 1),
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              key: const Key("plat"),
                                              // onSaved: (val) => task.licencePlateNumber = val,
                                              decoration: InputDecoration(
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.cyan,
                                                  ),
                                                ),
                                                fillColor:
                                                    const Color(0xfff3f3f4),
                                                filled: true,
                                                labelText: "Amount",
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        30, 10, 15, 10),
                                              ),
                                              onChanged: (val) {
                                                setState(() {
                                                  val.isEmpty
                                                      ? print(val)
                                                      : amount = int.parse(val);
                                                  getSum();
                                                });
                                              },
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return "This Field Is Required";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 1, right: 1, left: 1),
                                            child: TextFormField(
                                              initialValue: quantity.toString(),
                                              keyboardType:
                                                  TextInputType.number,
                                              key: const Key("plat"),
                                              // onSaved: (val) => task.licencePlateNumber = val,
                                              onChanged: (value) {
                                                setState(() {
                                                  value.isEmpty
                                                      ? print(value)
                                                      : quantity =
                                                          int.parse(value);

                                                  getSum();
                                                });
                                              },
                                              decoration: InputDecoration(
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.cyan,
                                                  ),
                                                ),
                                                fillColor:
                                                    const Color(0xfff3f3f4),
                                                filled: true,
                                                border: InputBorder.none,
                                                isDense: true,
                                                labelText: 'Quantity',
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
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: getProportionateScreenHeight(10),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 1, right: 16, left: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 1, right: 1, left: 1),
                                            child: SafeArea(
                                              child: DropdownButtonFormField(
                                                  decoration: InputDecoration(
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.cyan,
                                                      ),
                                                    ),
                                                    fillColor:
                                                        const Color(0xfff3f3f4),
                                                    filled: true,
                                                    labelText: "Currency",
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets
                                                                .fromLTRB(
                                                            30, 7, 15, 7),
                                                  ),
                                                  items: _currencyType,
                                                  value: currency,
                                                  validator: (value) => value ==
                                                          null
                                                      ? "This Field is Required"
                                                      : null,
                                                  onChanged: (value) async {}),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 1, right: 1, left: 1),
                                            child: TextFormField(
                                              initialValue: result.toString(),
                                              keyboardType:
                                                  TextInputType.number,
                                              enabled: false,

                                              key: const Key("plat"),
                                              // onSaved: (val) => task.licencePlateNumber = val,
                                              decoration: InputDecoration(
                                                labelText: "Total",
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.cyan,
                                                  ),
                                                ),
                                                fillColor:
                                                    const Color(0xfff3f3f4),
                                                filled: true,
                                                border: InputBorder.none,
                                                isDense: true,

                                                // subtotal.toString() ==
                                                //         'null'
                                                //     ? args.unitPrice
                                                //     : subtotal.toString(),

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
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 1, right: 16, left: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          //flex: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 1, right: 1, left: 1),
                                            child: TextFormField(
                                              maxLines: 5,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              key: const Key("plat"),
                                              decoration: InputDecoration(
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  borderSide: const BorderSide(
                                                    color: Colors.cyan,
                                                  ),
                                                ),
                                                fillColor:
                                                    const Color(0xfff3f3f4),
                                                filled: true,
                                                labelText: "Bill Description",
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
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: getProportionateScreenHeight(10),
                                  ),
                                  SizedBox(
                                    height: getProportionateScreenHeight(20),
                                  ),
                                  _submitButton(),
                                  SizedBox(
                                    height: getProportionateScreenHeight(40),
                                  ),
                                ],
                              ),
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
      ),
    );
  }

  Widget _customPopupItemBuilderGFS(
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
          title: Text(item.description),
          subtitle: Text("GFS - CODE: ${item.gfsCode}"),
          tileColor: const Color(0xfff3f3f4),
          leading: const CircleAvatar(
            backgroundColor: Colors.pink,
            child: Icon(Icons.code),
          ),
        ),
      ),
    );
  }

  Future<List<GfsModel>> getData(filter, level) async {
    String url;

    level == "1"
        ? url = "http://41.59.82.189:5555/api/v1/gfs_lv_one"
        : level == "2"
            ? url = "http://41.59.82.189:5555/api/v1/gfs_lv_two/$levelOneId"
            : url = "http://41.59.82.189:5555/api/v1/gfs_lv_three/$levelTwoId";
    var response = await Dio().get(
      url,
      queryParameters: {"filter": filter},
    );

    final data = response.data;
    print(data['data']);
    if (data != null) {
      setState(() {
        // datas = data[];
      });
      return GfsModel.fromJsonList(data['data']);
    }

    return [];
  }

  Future<List<DealerModel>> getDataDealer(filter) async {
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    print(tokens);
    var headers = {"Authorization": "Bearer ${tokens!}"};
    // BaseOptions options = new BaseOptions(
    //     baseUrl: "https://mis.tfs.go.tz/fremis-test/",
    //     connectTimeout: 50000,
    //     receiveTimeout: 50000,
    //     headers: headers);
    // var dio = Dio(options);
    var response = await Dio().get(
        "https://mis.tfs.go.tz/fremis-test/api/v1/dealers",
        queryParameters: {"filter": filter},
        options: Options(headers: headers));

    final data = response.data;
    print(data);
    if (data != null) {
      setState(() {
        datas = data;
      });
      return DealerModel.fromJsonList(data['dealers']);
    }

    return [];
  }

  Widget _customPopupItemBuilder2(
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
              ? " ${item.fname}" == "null"
                  ? ""
                  : "${item.fname} ${item.mname}" == "null"
                      ? ""
                      : "${item.mname} ${item.lname}" == "null"
                          ? "null"
                          : item.lname.toString()
              : item.companyName.toString() == "null"
                  ? ""
                  : item.companyName.toString()),
          //subtitle: Text(item.phoneNumber),
          tileColor: const Color(0xfff3f3f4),
          leading: const CircleAvatar(
            backgroundColor: Colors.pink,
            child: Icon(Icons.code),
          ),
        ),
      ),
    );
  }
}
