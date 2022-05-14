// ignore_for_file: file_names, avoid_print

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
  String? desc;
  double? unitAmount;
  String? gfcCode;
  bool isVerify = false;
  final value = NumberFormat("#,##0.00", "en_US");
  bool isLoading = false;
  bool isCustomerSelected = false;
  bool isCustomerRegistered = false;
  String? customerName;
  String? email;
  String? customerId;
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
  double total = 0;
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  double calculateSum() {
    double sumation = 0;
    for (var i = 0; i < billData.length; i++) {
      setState(() {
        //print(amount);
        sumation = sumation + double.parse(billData[i]["amount"].toString());
        total = sumation;
      });
      print(sumation);
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
    print(total);
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    var stationId = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt('station_id'));
    var checkpoint = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('checkpointId'));
    try {
      var headers = {"Authorization": "Bearer " + tokens!};
      BaseOptions options = BaseOptions(
          baseUrl: baseUrlTest,
          connectTimeout: 50000,
          receiveTimeout: 50000,
          headers: headers);
      var dio = Dio(options);
      var formData = FormData.fromMap({
        "payer_id": customerId,
        " payer_name": customerName,
        "payer_cell_no": mobileNumber,
        "payer_email": email,
        "bill_desc": "bill",
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
        // if (customerName != null && mobileNumber != null) {
        //   message("Are You Sure You Want To Create This Bill", "info",
        //       isBillMessage: true);
        // } else {
        //   message("Please Fill Customer Name and Phone Number", "info");
        // }
        message("Are You Sure You Want To Create This Bill", "info",
            isBillMessage: true);
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
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            if (index != null) {
              setState(() {
                billData.removeAt(index);
                // honeyId.removeAt(index);
                // quantities.removeAt(index);
              });
            }
            Navigator.pop(context);
            isBillMessage! ? await uploadData() : "";
          },
          width: 120,
        ),
        DialogButton(
          color: Colors.red,
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
                print(customerName);

                print(mobileNumber);
                _dealerEditTextController.clear();
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
                print(index);
                setState(() {
                  if (index != null) {
                    billData[index]["quantity"] = quantity;
                    // quantities[index] = quantity;
                    // print(quantities);
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

  List? beeProduct;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: forms(),
    );
  }

  forms() {
    return SingleChildScrollView(
        child: Column(children: [
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
                      padding:
                          const EdgeInsets.only(top: 10, right: 18, left: 18),
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
                              contentPadding:
                                  const EdgeInsets.fromLTRB(30, 10, 15, 10),
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
                            contentPadding: const EdgeInsets.fromLTRB(30, 5, 10, 5),
                            hintText: "Select Customer",
                            border: InputBorder.none),
                        compareFn: (i, s) => i!.isEqual(s),

                        onFind: (filter) => getDataDealer(filter, "1"),

                        onChanged: (data) {
                          setState(() {
                            customerId = data!.id;
                            customerName = data.companyName == "null"
                                ? data.fname +
                                    " " +
                                    data.mname +
                                    " " +
                                    data.lname
                                : data.companyName;
                            mobileNumber = data.phoneNumber;
                            email = data.email;

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
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(30, 10, 15, 10),
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
                                desc = data!.description;
                                unitAmount = double.parse(data.amount);
                                gfcCode = data.gfsCode;

                                //print(seedname);
                                // print(amount);
                              },

                              popupItemBuilder: _customPopupItemBuilderGFSCode,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5, right: 5, left: 5),
                            child: TextFormField(
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
                                              (i + 1).toString(),
                                            ),
                                          )),
                                      Expanded(
                                          flex: 3,
                                          child: Center(
                                            child: Text(
                                              billData[i]["product_name"]
                                                  .toString(),
                                            ),
                                          )),
                                      Expanded(
                                          flex: 3,
                                          child: Center(
                                            child: Text(
                                              (billData[i]["amount"])
                                                  .toString(),
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
                                                      computeQuantity(
                                                          index: i,
                                                          quantit: billData[i]
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
            ),
          ],
        ),
      ),
    ]));
  }

  Widget _saveData() {
    return InkWell(
      onTap: () async {
        if (_formKey1.currentState!.validate()) {
          _formKey1.currentState!.save();
          Map billElements = {
            "amount": (unitAmount! * quantity),
            "product_name": desc,
            "gfs_code": gfcCode,
            "quantity": quantity,
            "prod_desc": desc
          };
          print(billElements);

          billData.add(billElements);
          print(billData);

          setState(() {
            desc = null;
            unitAmount = null;
            gfcCode = null;
            quantity = 0;
            cardB.currentState?.collapse();

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
                    'Save Data',
                    style: TextStyle(fontSize: 13.0.sp, color: Colors.black),
                  ),
                ),
              ),
            ),
    );
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
          title: Text("Description: " + item.description),
          subtitle: Text("Bill Amount: " + item.amount),
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
    print(tokens);
    var headers = {"Authorization": "Bearer " + tokens!};
    url = "https://mis.tfs.go.tz/fremis-test/api/v1/dealers";
    var response = await Dio().get(url,
        queryParameters: {
          "filter": filter,
        },
        options: Options(headers: headers));

    final data = response.data;
    print(data['dealers']);

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
              ? (item.fname +
                  " " +
                  (item.mname == "null" ? " " : item.mname) +
                  " " +
                  item.lname)
              : item.companyName),
          subtitle: Text("Phone#: " + item.phoneNumber),
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
    print(tokens);
    var headers = {"Authorization": "Bearer " + tokens!};
    url = "https://mis.tfs.go.tz/fremis-test/api/v1/gfs_codes/pos";
    var response = await Dio().get(url,
        queryParameters: {
          "filter": filter,
        },
        options: Options(headers: headers));

    final data = response.data;
    print(data['data']);
    if (data != null) {
      return GfsModel.fromJsonList(data['data']);
    }

    return [];
  }
}
