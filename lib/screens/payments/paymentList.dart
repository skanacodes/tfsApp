// ignore_for_file: file_names, prefer_typing_uninitialized_variables, avoid_print, library_private_types_in_public_api, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/screens/payments/payments.dart';

import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/receiptArguments.dart';
import 'package:tfsappv1/services/renew_session.dart';

import 'package:tfsappv1/services/size_config.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

class PaymentList extends StatefulWidget {
  static String routeName = "/paymentList";
  final String system;
  const PaymentList(this.system, {Key? key}) : super(key: key);

  @override
  _PaymentListState createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {
  String? type;
  String? controlNo;
  List data = [];
  var seedToken;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String pastMonth = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(const Duration(days: 30)));
  String pastWeek = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(const Duration(days: 7)));
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      String stationId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getInt('station_id').toString());

      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url;
      widget.system == "PMIS"
          ? url = Uri.parse('$baseUrlPMIS/api/Bill/AccountsPayments')
          : url = Uri.parse('$baseUrlTest/api/v1/paid-bills/$stationId');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      ////////print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 201:
          setState(() {
            res = json.decode(response.body);
            //////////print(res);
            // data = res['data'];
            if (res["success"] && widget.system != "PMIS") {
              data = res['data'];
            }

            isLoading = false;
          });

          break;

        case 200:
          setState(() {
            res = json.decode(response.body);
            ////////////print(res);

            if (res["success"].toString() == "false" &&
                widget.system != "PMIS") {
              messages(res["message"].toString(), 'error');
            }
            if (res["status"].toString() == "Token is Expired") {
              //////////print("tokens");
              RenewSession().renewSessionForm(
                context,
              );
            }

            if (widget.system == "PMIS") {
              data = res["Result"]["data"];
            }

            isLoading = false;
          });
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', res["message"].toString());
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////print(e);
        messages('Server Or Connectivity Error', e.toString());
      });
    }
    _refreshController.refreshCompleted();
  }

  Future getDataEAuction() async {
    setState(() {
      isLoading = true;
    });
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse(
          "https://mis.tfs.go.tz/e-auction/api/Bill/AccountsPayments");
      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
      ////////////print(response.statusCode);

      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////////////print(res);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    _refreshController.refreshCompleted();
  }

  Future getDataSeed() async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      ////////////print(tokens);
      var url = Uri.parse('$baseUrlSeed/api/v1/paid-bills');

      var headers = {"Authorization": "Bearer " + tokens!};

      final response = await http.get(url, headers: headers);
      var res;

      //////////print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //////////print(res);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    _refreshController.refreshCompleted();
  }

  Future getDataHoneyTraceability() async {
    setState(() {
      isLoading = true;
    });
    try {
      String stationId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getInt('station_id').toString());
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      ////////////print(tokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      var url =
          Uri.parse('$baseUrlHoneyTraceability/api/v1/paid-bills/$stationId');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //////////print(response.statusCode);
      //////////print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////////////print(res);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    _refreshController.refreshCompleted();
  }

  Future sortData(String duration) async {
    setState(() {
      isLoading = true;
    });
    try {
      ////////////print(duration);
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // ////////////print(tokens);
      var headers = {"Authorization": "Bearer " + seedToken};
      var url = widget.system == "seedMIS"
          ? Uri.parse(
              'http://41.59.227.103:9092/api/v1/search-payment-history/$duration/$formattedDate')
          : Uri.parse(
              'https://mis.tfs.go.tz/honey-traceability/api/v1/search-payment-history/$duration/$formattedDate');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //////////print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //////////print(res);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    _refreshController.refreshCompleted();
  }

  Future searchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // ////////////print(tokens);
      var headers = {"Authorization": "Bearer " + seedToken};
      var url = widget.system == "seedMIS"
          ? Uri.parse(
              'http://41.59.227.103:9092/api/v1/bill-by-controlnumber/$controlNo/1')
          : Uri.parse(
              'https://mis.tfs.go.tz/honey-traceability/api/v1/bill-by-controlnumber/$controlNo/1');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //////////print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //////////print(res);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    _refreshController.refreshCompleted();
  }

  Future searchDataFremis() async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};

      var url = Uri.parse('$baseUrlTest/api/v1/search-bills/$controlNo');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      ////////print(response.statusCode);
      ////////print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////////print(res);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    _refreshController.loadComplete();
  }

  Future searchDataPMIS() async {
    BigInt controlNumber = BigInt.parse(controlNo.toString());
    setState(() {
      isLoading = true;
    });
    try {
      ////////print(controlNumber);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      //////////print(tokens);
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse(
        '$baseUrlPMIS/api/Bill/SearchAccountsPayments/$controlNumber',
      );

      final response = await http.get(
        url,
        headers: headers,
      );
      var res;
      //final sharedP prefs=await
      ////////print(response.statusCode);
      ////////print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);

            data = res["Result"]['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //////////////print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        //////////////print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    _refreshController.refreshCompleted();
  }

  messages(
    String type,
    String desc,
  ) {
    return Alert(
      style: AlertStyle(
          descStyle: TextStyle(
              fontSize: 10.sp, fontFamily: "Ubuntu", color: Colors.black54)),
      context: context,
      type: type == 'success'
          ? AlertType.success
          : type == "info"
              ? AlertType.success
              : AlertType.error,
      title: 'Status: Printed',
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

  searchBar() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 4,
              child: Form(
                key: _formKey,
                child: TextFormField(
                    onChanged: (value) {
                      return;
                    },
                    validator: (value) =>
                        value == '' ? 'This  Field Is Required' : null,
                    onSaved: (value) {
                      controlNo = value;
                    },
                    keyboardType: TextInputType.number,
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                        suffixIcon: InkWell(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              //////////////print(controlNo);
                              widget.system == "Fremis"
                                  ? await searchDataFremis()
                                  : widget.system == "PMIS"
                                      ? await searchDataPMIS()
                                      : await searchData();
                            }
                          },
                          child: const Icon(
                            Icons.search,
                            size: 23,
                            color: Colors.black,
                          ),
                        ),
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        border: InputBorder.none,
                        fillColor: const Color(0xfff3f3f4),
                        label: const Text(
                          "Control Number",
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                        filled: true)),
              )),
          Expanded(
            flex: 2,
            child: popBar(),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    widget.system == "seedmis"
        ? getDataSeed()
        : widget.system == "honeytraceability"
            ? getDataHoneyTraceability()
            : widget.system == "E-Auction"
                ? getDataEAuction()
                : getData();

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' List Of Paid Bills',
          style: TextStyle(
              color: Colors.black, fontFamily: 'ubuntu', fontSize: 17),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: getProportionateScreenHeight(900),
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: const WaterDropHeader(),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = const Text("pull up load");
                } else if (mode == LoadStatus.loading) {
                  body = const CupertinoActivityIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = const Text("Load Failed!Click retry!");
                } else if (mode == LoadStatus.canLoading) {
                  body = const Text("release to load more");
                } else {
                  body = const Text("No more Data");
                }
                return SizedBox(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            controller: _refreshController,
            onRefresh: () {
              widget.system == "seedmis"
                  ? getDataSeed()
                  : widget.system == "honeytraceability"
                      ? getDataHoneyTraceability()
                      : widget.system == "E-Auction"
                          ? getDataEAuction()
                          : getData();
            },
            onLoading: _onLoading,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: getProportionateScreenHeight(70),
                      color: Colors.white,
                      // decoration: BoxDecoration(color: Colors.white),
                    ),
                    Container(
                      height: getProportionateScreenHeight(50),
                      decoration: const BoxDecoration(color: kPrimaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Card(elevation: 10, child: searchBar()),
                      ),
                    )
                  ],
                ),
                // _divider
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: isLoading
                      ? const SpinKitCircle(
                          color: kPrimaryColor,
                        )
                      : data.isEmpty
                          ? Center(
                              child: SizedBox(
                                height: getProportionateScreenHeight(400),
                                child: const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Card(
                                      elevation: 10,
                                      child: ListTile(
                                        title: Text("No Data Found"),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          child: Icon(
                                              Icons.hourglass_empty_outlined),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: getProportionateScreenHeight(750),
                              color: Colors.white,
                              child: AnimationLimiter(
                                child: ListView.builder(
                                  itemCount: data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 1375),
                                      child: SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: InkWell(
                                            onTap: (() async {
                                              var station =
                                                  await SharedPreferences
                                                          .getInstance()
                                                      .then((prefs) =>
                                                          prefs.getString(
                                                              'StationName'));

                                              data[index]["IsPrinted"].toString() ==
                                                      "1"
                                                  ? messages("info",
                                                      "control No:  ${data[index]["ControlNumber"]} \nReceipt No:  ${data[index]["ReceiptNumber"]} \nPayer Name:  ${data[index]["DealerName"]} \nBill Amount:  ${data[index]["BillAmount"]} \nBill Desc:  ${data[index]["BillDesc"]} \n")
                                                  : Navigator.pushNamed(context,
                                                          Payments.routeName,
                                                          arguments:
                                                              ReceiptScreenArguments(
                                                                  data[index]["DealerName"]
                                                                      .toString(),
                                                                  data[index]["ControlNumber"]
                                                                      .toString(),
                                                                  data[index]["ReceiptNumber"]
                                                                      .toString(),
                                                                  widget.system == "E-Auction" ||
                                                                          widget.system ==
                                                                              "PMIS"
                                                                      ? data[index][
                                                                          "BillAmount"]
                                                                      : widget.system ==
                                                                              "honeytraceability"
                                                                          ? data[index]["BillAmount"]
                                                                              .toDouble()
                                                                          : double.parse(data[index][
                                                                              "BillAmount"]),
                                                                  false,
                                                                  data[index]["BillDesc"]
                                                                      .toString(),
                                                                  data[index]
                                                                          ["issuer"]
                                                                      .toString(),
                                                                  bankReceipt: data[index]["bank_receipt_no"].toString(),
                                                                  payedDate: data[index]["TrasDateTime"].toString(),
                                                                  plotname: widget.system == "E-Auction" ? data[index]["PlotName"].toString() : "null",
                                                                  station: widget.system == "E-Auction" ? data[index]["Station"].toString() : station,
                                                                  isPrinted: data[index]["IsPrinted"] == 0 ? false : true,
                                                                  system: widget.system,
                                                                  currency: data[index]["currency"].toString(),
                                                                  billId: data[index]["BillId"].toString()))
                                                      .then((value) async {
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      widget.system == "seedmis"
                                                          ? getDataSeed()
                                                          : widget.system ==
                                                                  "honeytraceability"
                                                              ? getDataHoneyTraceability()
                                                              : widget.system ==
                                                                      "E-Auction"
                                                                  ? getDataEAuction()
                                                                  : getData();

                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    });
                                            }),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                margin: const EdgeInsets.only(
                                                    bottom: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 0,
                                                        blurRadius: 5,
                                                        offset:
                                                            const Offset(0, 1),
                                                      ),
                                                    ]),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: Row(children: [
                                                            SizedBox(
                                                                width: 40,
                                                                height: 40,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  child: IntrinsicHeight(
                                                                      child: SizedBox(
                                                                          height: double.maxFinite,
                                                                          width: getProportionateScreenHeight(40),
                                                                          child: Row(
                                                                            children: [
                                                                              VerticalDivider(
                                                                                color: index.isEven ? kPrimaryColor : Colors.green[200],
                                                                                thickness: 5,
                                                                              )
                                                                            ],
                                                                          ))),
                                                                )),
                                                            Flexible(
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                        "Name: ${data[index]["DealerName"]}",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black87,
                                                                            fontSize: 11.sp,
                                                                            fontWeight: FontWeight.w500)),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                        "Control #: ${data[index]["ControlNumber"]}",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey[500])),
                                                                  ]),
                                                            )
                                                          ]),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            flex: 4,
                                                            child: Container(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 8,
                                                                  horizontal:
                                                                      10),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200),
                                                              child: data[index]
                                                                              [
                                                                              "IsPrinted"]
                                                                          .toString() ==
                                                                      "0"
                                                                  ? Text(
                                                                      "Status: Not Printed",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            11.sp,
                                                                        color: Colors
                                                                            .blue,
                                                                      ),
                                                                    )
                                                                  : Text(
                                                                      "Status: Printed",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            11.sp,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                            ),
                                                          ),
                                                          const Spacer(
                                                            flex: 2,
                                                          ),
                                                          Expanded(
                                                              flex: 1,
                                                              child:
                                                                  CircleAvatar(
                                                                radius: 13.sp,
                                                                backgroundColor:
                                                                    Colors.grey[
                                                                        200],
                                                                child: data[index]["IsPrinted"]
                                                                            .toString() ==
                                                                        "0"
                                                                    ? Icon(
                                                                        Icons
                                                                            .radio_button_unchecked_outlined,
                                                                        color: Colors
                                                                            .blue,
                                                                        size: 13
                                                                            .sp,
                                                                      )
                                                                    : Icon(
                                                                        Icons
                                                                            .check_circle_outline,
                                                                        color:
                                                                            kPrimaryColor,
                                                                        size: 13
                                                                            .sp,
                                                                      ),
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Card(
                                          //   elevation: 10,
                                          //   shadowColor: Colors.grey,
                                          //   child:
                                          //   ListTile(
                                          //     onTap: () async {
                                          //       var station =
                                          //           await SharedPreferences
                                          //                   .getInstance()
                                          //               .then((prefs) =>
                                          //                   prefs.getString(
                                          //                       'StationName'));

                                          //       data[index]["IsPrinted"]
                                          //                   .toString() ==
                                          //               "1"
                                          //           ? messages("info",
                                          //               "control No:  ${data[index]["ControlNumber"]} \nReceipt No:  ${data[index]["ReceiptNumber"]} \nPayer Name:  ${data[index]["DealerName"]} \nBill Amount:  ${data[index]["BillAmount"]} \nBill Desc:  ${data[index]["BillDesc"]} \n")
                                          //           : Navigator.pushNamed(
                                          //                   context,
                                          //                   Payments.routeName,
                                          //                   arguments: ReceiptScreenArguments(
                                          //                       data[index]["DealerName"].toString(),
                                          //                       data[index]["ControlNumber"].toString(),
                                          //                       data[index]["ReceiptNumber"].toString(),
                                          //                       widget.system == "E-Auction" || widget.system == "PMIS"
                                          //                           ? data[index]["BillAmount"]
                                          //                           : widget.system == "honeytraceability"
                                          //                               ? data[index]["BillAmount"].toDouble()
                                          //                               : double.parse(data[index]["BillAmount"]),
                                          //                       false,
                                          //                       data[index]["BillDesc"].toString(),
                                          //                       data[index]["issuer"].toString(),
                                          //                       bankReceipt: data[index]["bank_receipt_no"].toString(),
                                          //                       payedDate: data[index]["TrasDateTime"].toString(),
                                          //                       plotname: widget.system == "E-Auction" ? data[index]["PlotName"].toString() : "null",
                                          //                       station: widget.system == "E-Auction" ? data[index]["Station"].toString() : station,
                                          //                       isPrinted: data[index]["IsPrinted"] == 0 ? false : true,
                                          //                       system: widget.system,
                                          //                       currency: data[index]["currency"].toString(),
                                          //                       billId: data[index]["BillId"].toString()))
                                          //               .then((value) async {
                                          //               setState(() {
                                          //                 isLoading = true;
                                          //               });
                                          //               widget.system ==
                                          //                       "seedmis"
                                          //                   ? getDataSeed()
                                          //                   : widget.system ==
                                          //                           "honeytraceability"
                                          //                       ? getDataHoneyTraceability()
                                          //                       : widget.system ==
                                          //                               "E-Auction"
                                          //                           ? getDataEAuction()
                                          //                           : getData();

                                          //               setState(() {
                                          //                 isLoading = false;
                                          //               });
                                          //             });
                                          //     },
                                          //     trailing: Column(
                                          //       mainAxisAlignment:
                                          //           MainAxisAlignment.center,
                                          //       children: const [
                                          //         Icon(
                                          //           Icons
                                          //               .arrow_forward_ios_sharp,
                                          //           color: kPrimaryColor,
                                          //           size: 15,
                                          //         ),
                                          //       ],
                                          //     ),
                                          //     leading: IntrinsicHeight(
                                          //         child: SizedBox(
                                          //             height: double.maxFinite,
                                          //             width:
                                          //                 getProportionateScreenHeight(
                                          //                     50),
                                          //             child: Row(
                                          //               children: [
                                          //                 VerticalDivider(
                                          //                   color: index.isEven
                                          //                       ? kPrimaryColor
                                          //                       : Colors
                                          //                           .green[200],
                                          //                   thickness: 5,
                                          //                 )
                                          //               ],
                                          //             ))),
                                          //     title: Text(
                                          //       "Name: ${data[index]["DealerName"]}",
                                          //     ),
                                          //     subtitle: Text(
                                          //       "Control #: ${data[index]["ControlNumber"]}",
                                          //     ),
                                          //   ),
                                          // ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  popBar() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: PopupMenuButton(
        tooltip: 'Sort',
        color: const Color(0xfff3f3f4),
        offset: const Offset(20, 40),
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () {
              sortData(pastMonth);
            },
            child: Row(
              children: [
                Icon(
                  Icons.sort,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    "Sort By Month",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () {
              sortData(pastWeek);
            },
            child: Row(
              children: [
                Icon(
                  Icons.sort,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    "Sort By Week",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () {
              sortData(formattedDate);
            },
            child: Row(
              children: [
                Icon(
                  Icons.sort,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    "Sort By Day",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    "Custom Date",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Sort"),
            Icon(
              Icons.sort_outlined,
              size: 28.0,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
