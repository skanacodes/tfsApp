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
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/dealer.dart';
import 'package:tfsappv1/services/modal/gfsCodes.dart';

import 'package:tfsappv1/services/size_config.dart';

class BillForm extends StatefulWidget {
  static String routeName = "/billForm";
  BillForm({Key? key}) : super(key: key);

  @override
  _BillFormState createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  var datas;
  var gfsCodes;
  String? result;
  String? dropdownvalue;
  String? billDesc;
  int amount = 1;
  double subtotal = 0.0;
  String? currency;
  //DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final formKey = new GlobalKey<FormState>();
  final List<DropdownMenuItem<String>> _currencyType = [
    DropdownMenuItem(
      child: new Text("USD"),
      value: "USD",
    ),
    DropdownMenuItem(
      child: new Text("TSH"),
      value: "TSH",
    ),
  ];
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

  @override
  void dispose() {
    // Clean up the controller when the widget is removed

    super.dispose();
  }

  @override
  void initState() {
    // this.getDealers();
    this.getData('');
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
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('https://mis.tfs.go.tz/fremis-test/api/v1/dealers');
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
            textStyle: Theme.of(context).textTheme.display1,
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
    try {
      var url = Uri.parse('http://41.59.82.189:9292/api/Bill/PostBillRequest');
      final response = await http.post(
        url,
        body: jsonEncode({
          "ClientPrimaryKey": "",
          "RequestId": 4,
          "PaymentCallBack": "sdsd",
          "BillExprDt": null,
          "PyrId": 56456645,
          "PyrName": "Matoke",
          "BillDesc": "Some description",
          "BillGenDt": "Default",
          "BillApprBy": null,
          "PyrCellNum": "755237904",
          "PyrEmail": "baraka12@gmail.com",
          "BillItemRef": 3456435345,
          "BillItemAmt": 5,
          "BillItemEqvAmt": 1,
          "GfsCode": "46456",
          "BillItems": [
            {
              "BillItemRef": 3456435345,
              "BillItemAmt": 5,
              "BillItemEqvAmt": 1,
              "GfsCode": "110625"
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
                      colors: [kPrimaryColor, Colors.green[200]!])),
              child: Text(
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
        title: Text(
          ' Bill Form',
          style: TextStyle(color: Colors.black, fontFamily: 'ubuntu'),
        ),
        backgroundColor: kPrimaryColor,
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
                          height: getProportionateScreenHeight(100),
                          decoration: BoxDecoration(
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
                                  title: Text(
                                    'Generate Bill Form',
                                    style: TextStyle(color: Colors.black),
                                  ),
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 1, right: 16, left: 16),
                                    child: Container(
                                      height: getProportionateScreenHeight(70),
                                      child: Center(
                                        child: DropdownSearch<DealerModel>(
                                          // showSelectedItem: true,
                                          showSearchBox: true,
                                          showClearButton: true,
                                          mode: Mode.BOTTOM_SHEET,
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            filled: true,
                                            enabledBorder: InputBorder.none,
                                            contentPadding: EdgeInsets.all(5),
                                            fillColor: Color(0xfff3f3f4),
                                          ),
                                          compareFn: (i, s) => i!.isEqual(s),
                                          label: " Select Dealer",
                                          onFind: (String? filter) =>
                                              getDataDealer(filter),
                                          onChanged: (data) {
                                            print(data);
                                          },
                                          //  dropdownBuilder: _customDropDownExample,
                                          popupItemBuilder:
                                              _customPopupItemBuilderExampleForDealers,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: getProportionateScreenHeight(10)),
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
                                            child: Container(
                                              child: TextFormField(
                                                maxLines: 5,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                key: Key("plat"),
                                                // onSaved: (val) => task.licencePlateNumber = val,
                                                decoration: InputDecoration(
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    borderSide: BorderSide(
                                                      color: Colors.cyan,
                                                    ),
                                                  ),
                                                  fillColor: Color(0xfff3f3f4),
                                                  filled: true,
                                                  labelText: "Bill Description",
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          30, 10, 15, 10),
                                                ),

                                                validator: (value) {
                                                  if (value!.isEmpty)
                                                    return "This Field Is Required";
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: getProportionateScreenHeight(10),
                                  ),
                                  SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 1, right: 16, left: 16),
                                      child: Container(
                                        child: DropdownButtonFormField(
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
                                              labelText: "Currency",
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      30, 10, 15, 10),
                                            ),
                                            items: _currencyType,
                                            value: currency,
                                            validator: (value) => value == null
                                                ? "This Field is Required"
                                                : null,
                                            onChanged: (value) async {}),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: getProportionateScreenHeight(20),
                                  ),
                                  // DropdownSearch<GfsModel>.multiSelection(
                                  //   // searchFieldProps: TextFieldProps(
                                  //   //   controller:
                                  //   //       TextEditingController(text: 'Mrs'),
                                  //   // ),
                                  //   mode: Mode.DIALOG,
                                  //   maxHeight: 500,
                                  //   isFilteredOnline: true,
                                  //   showClearButton: true,

                                  //   compareFn: (item, selectedItem) =>
                                  //       item?.gfsCode == selectedItem?.gfsCode,
                                  //   showSearchBox: true,
                                  //   label: 'Services *',
                                  //   dropdownSearchDecoration: InputDecoration(
                                  //     filled: true,
                                  //     fillColor: Theme.of(context)
                                  //         .inputDecorationTheme
                                  //         .fillColor,
                                  //   ),
                                  //   autoValidateMode:
                                  //       AutovalidateMode.onUserInteraction,
                                  //   validator: (u) => u == null || u.isEmpty
                                  //       ? "user field is required "
                                  //       : null,
                                  //   onFind: (String? filter) => getData(filter),
                                  //   onChange: (data) {
                                  //     print(data);
                                  //   },
                                  //   dropdownBuilder:
                                  //       _customDropDownExampleMultiSelection,
                                  //   popupItemBuilder:
                                  //       _customPopupItemBuilderExample,
                                  //   popupSafeArea:
                                  //       PopupSafeArea(top: true, bottom: true),
                                  //   scrollbarProps: ScrollbarProps(
                                  //     isAlwaysShown: true,
                                  //     thickness: 7,
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 1, right: 16, left: 16),
                                    child: DropdownSearch<GfsModel>(
                                      // showSelectedItem: true,
                                      showSearchBox: true,
                                      showClearButton: true,
                                      mode: Mode.DIALOG,
                                      dropdownSearchDecoration: InputDecoration(
                                        filled: true,
                                        enabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.all(0),
                                        fillColor: Color(0xfff3f3f4),
                                      ),
                                      compareFn: (i, s) => i!.isEqual(s),
                                      label: "Select GFS code",
                                      onFind: (String? filter) =>
                                          getData(filter),
                                      onChanged: (data) {
                                        print(data);
                                      },
                                      //  dropdownBuilder: _customDropDownExample,
                                      popupItemBuilder:
                                          _customPopupItemBuilderExample2,
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 1, right: 16, left: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 1, right: 1, left: 1),
                                            child: Container(
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                key: Key("plat"),
                                                // onSaved: (val) => task.licencePlateNumber = val,
                                                decoration: InputDecoration(
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    borderSide: BorderSide(
                                                      color: Colors.cyan,
                                                    ),
                                                  ),
                                                  fillColor: Color(0xfff3f3f4),
                                                  filled: true,
                                                  labelText: "Item Amount",
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          30, 10, 15, 10),
                                                ),
                                                onChanged: (val) {
                                                  setState(() {
                                                    // if (val != '') {
                                                    //   amount = int.parse(val);
                                                    //   subtotal = amount *
                                                    //       double.parse(
                                                    //           args.unitPrice);
                                                    // } else {
                                                    //   val = '1';
                                                    //   amount = int.parse(val);
                                                    //   subtotal = amount *
                                                    //       double.parse(
                                                    //           args.unitPrice);
                                                    // }
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value!.isEmpty)
                                                    return "This Field Is Required";
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 1, right: 1, left: 1),
                                            child: Container(
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                key: Key("plat"),
                                                // onSaved: (val) => task.licencePlateNumber = val,
                                                decoration: InputDecoration(
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    borderSide: BorderSide(
                                                      color: Colors.cyan,
                                                    ),
                                                  ),
                                                  fillColor: Color(0xfff3f3f4),
                                                  filled: true,
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  enabled: false,
                                                  labelText: 'qef'
                                                  // subtotal.toString() ==
                                                  //         'null'
                                                  //     ? args.unitPrice
                                                  //     : subtotal.toString(),
                                                  ,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          30, 10, 15, 10),
                                                ),

                                                // validator: (value) {
                                                //   if (value!.isEmpty)
                                                //     return "This Field Is Required";
                                                //   return null;
                                                // },
                                              ),
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

  Widget _customPopupItemBuilderExample2(
      BuildContext context, GfsModel item, bool isSelected) {
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
          title: Text(item.description),
          subtitle: Text(item.gfsCode.toString()),
          leading: CircleAvatar(
            child: Icon(Icons.code),
          ),
        ),
      ),
    );
  }

  Widget _customPopupItemBuilderExampleForDealers(
      BuildContext context, DealerModel item, bool isSelected) {
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
          title: Text(item.fname == 'null'
              ? item.companyName
              : '${item.fname} ${item.lname}'),
          // subtitle: Text(item.gfsCode.toString()),
          leading: CircleAvatar(
            child: Icon(Icons.code),
          ),
        ),
      ),
    );
  }

  Future<List<GfsModel>> getData(filter) async {
    var response = await Dio().get(
      "http://41.59.227.103:5013/api/Setup/GetTarrifs",
      queryParameters: {"filter": filter},
    );

    final data = response.data;
    print(data);
    if (data != null) {
      setState(() {
        datas = data;
      });
      return GfsModel.fromJsonList(data);
    }

    return [];
  }

  Future<List<DealerModel>> getDataDealer(filter) async {
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    print(tokens);
    var headers = {"Authorization": "Bearer " + tokens!};
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
}
