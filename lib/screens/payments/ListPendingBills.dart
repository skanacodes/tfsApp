// ignore_for_file: file_names, prefer_typing_uninitialized_variables, avoid_//print, library_private_types_in_public_api, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/screens/payments/payments.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/receiptArguments.dart';
import 'package:tfsappv1/services/renew_session.dart';
import 'package:tfsappv1/services/size_config.dart';

class ListPendingBills extends StatefulWidget {
  static String routeName = "/pendingBills";
  final String system;
  const ListPendingBills(this.system, {Key? key}) : super(key: key);

  @override
  _ListPendingBillsState createState() => _ListPendingBillsState();
}

class _ListPendingBillsState extends State<ListPendingBills> {
  String? type;
  List data = [];
  var seedToken;
  var controlNo;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Future getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      print("kaza");
      String stationId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getInt('station_id').toString());
      print("kaza");
      ////////////(printstationId);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url;
      widget.system == "PMIS"
          ? url = Uri.parse('https://mis.tfs.go.tz/pmis/api/Bill/AccountsBill')
          : url = Uri.parse('$baseUrlTest/api/v1/unpaid-bills/$stationId');
      final response = await http.get(url, headers: headers);
      var res;
      print("sfdswf");
      //final sharedP prefs=await
      (response.body);
      (response.statusCode);
      (response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            // //////(printres);
            // RenewSession().renewSessionForm(context);

            if (res["success"].toString() == "true" &&
                widget.system != "PMIS") {
              data = res['data'];
            }
            if (res["success"].toString() == "false" &&
                widget.system != "PMIS") {
              messages(res["message"].toString(), 'error');
            }
            if (res["status"].toString() == "Token is Expired") {
              //////(print"tokens");
              RenewSession().renewSessionForm(
                context,
              );
            }
            if (widget.system == "PMIS") {
              data = res["Result"]["data"];
            }

            // widget.system == "PMIS"
            //     ? data = res["Result"]["data"]
            //     : data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);

            isLoading = false;
            messages(res["message"].toString(), 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;

        messages(e.toString(), e.toString());
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
      // ////////////(printtokens);
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url =
          Uri.parse('https://mis.tfs.go.tz/e-auction/api/Bill/AccountsBill');
      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
      ////////////(printresponse.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////(printe);
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
      // ////////////(printtokens);
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/search-bills/$controlNo');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      ////////////(printresponse.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////(printe);
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
      ////////////(printtokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse(
          '$baseUrlHoneyTraceability/api/v1/pending-bills/$stationId');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      ////(printresponse.statusCode);
      ////(printresponse.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////(printe);
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
      ////////////(printtokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrlSeed/api/v1/bills');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      ////(printresponse.statusCode);
      ////(printresponse.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////(printe);
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

  Future searchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      // ////////////(printtokens);
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = widget.system == "seedmis"
          ? Uri.parse('$baseUrlSeed/api/v1/bill-by-controlnumber/$controlNo/2')
          : widget.system == "honeytraceability"
              ? Uri.parse(
                  '$baseUrlHoneyTraceability/api/v1/search-bills/$controlNo')
              : Uri.parse(
                  'https://mis.tfs.go.tz/honey-traceability/api/v1/bill-by-controlnumber/$controlNo/2');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      ////////////(printresponse.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////(printe);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    _refreshController.refreshCompleted();
  }

  Future searchDataPMIS() async {
    BigInt controlNumber = BigInt.parse(controlNo.toString());
    setState(() {
      isLoading = true;
    });
    try {
      ////////(printcontrolNumber);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      ////////(printtokens);
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
      //////(printresponse.statusCode);
      //////(printresponse.body);
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
            ////////////(printres);
            isLoading = false;
            //  messages('Ohps! Something Went Wrong', 'Not Found');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////(printe);
        messages('Server Or Connectivity Error', 'Not Found');
      });
    }
    _refreshController.refreshCompleted();
  }

  searchBar() {
    return Form(
      key: _formKey,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 4,
                child: TextFormField(
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
                              widget.system == "Fremis"
                                  ? await searchDataFremis()
                                  : widget.system == "PMIS"
                                      ? await searchDataPMIS()
                                      : await searchData();
                            }
                          },
                          child: const Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        border: InputBorder.none,
                        fillColor: const Color(0xfff3f3f4),
                        label: const Text(
                          "Search By Control Number",
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                        filled: true))),
          ],
        ),
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
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' List Of Pending Bills',
          style: TextStyle(
              color: Colors.black, fontFamily: 'ubuntu', fontSize: 17),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
          child: SingleChildScrollView(
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
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
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
                            height: getProportionateScreenHeight(700),
                            color: Colors.white,
                            child: AnimationLimiter(
                              child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (BuildContext context, int index) {
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
                                            var fname = await SharedPreferences
                                                    .getInstance()
                                                .then((prefs) =>
                                                    prefs.getString('fname'));
                                            var lname = await SharedPreferences
                                                    .getInstance()
                                                .then((prefs) =>
                                                    prefs.getString('lname'));
                                            var username =
                                                "${fname!} ${lname!}";

                                            widget.system == "E-Auction"
                                                ? null
                                                : Navigator.pushNamed(
                                                    context, Payments.routeName,
                                                    arguments:
                                                        ReceiptScreenArguments(
                                                            data[index]["DealerName"]
                                                                .toString(),
                                                            data[index]["ControlNumber"]
                                                                .toString(),
                                                            data[index]["bank_receipt_no"]
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
                                                            true,
                                                            data[index]["BillDesc"]
                                                                .toString(),
                                                            username,
                                                            system:
                                                                widget.system,
                                                            station: station,
                                                            currency: data[index]
                                                                    ["currency"]
                                                                .toString(),
                                                            billId: widget.system == "seedmis"
                                                                ? data[index]["id"]
                                                                    .toString()
                                                                : data[index]["BillId"].toString()));
                                          }),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, right: 8),
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Row(children: [
                                                          SizedBox(
                                                              width: 40,
                                                              height: 40,
                                                              child: ClipRRect(
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
                                                          const SizedBox(
                                                              width: 5),
                                                          Flexible(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      "Name: ${data[index]["DealerName"]}",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize: 11
                                                                              .sp,
                                                                          fontWeight:
                                                                              FontWeight.w500)),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                      "Control #: ${data[index]["ControlNumber"]}",
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.black54)),
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
                                                              decoration:
                                                                  BoxDecoration(
                                                                      //   border: Border.all(color: Colors.green),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Center(
                                                                  child: Text(
                                                                    data[index]["BillAmount"]
                                                                            .toString() +
                                                                        " " +
                                                                        data[index]["currency"]
                                                                            .toString(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11.sp,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )),
                                                        ),
                                                        const Spacer(
                                                          flex: 2,
                                                        ),
                                                        Expanded(
                                                            flex: 1,
                                                            child: CircleAvatar(
                                                                radius: 12.sp,
                                                                backgroundColor:
                                                                    Colors.grey[
                                                                        200],
                                                                child: Icon(
                                                                  Icons
                                                                      .pending_actions,
                                                                  color: Colors
                                                                      .blue,
                                                                  size: 11.sp,
                                                                ))),
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
                                        //   child: ListTile(
                                        //     onTap: () async {
                                        //       var station =
                                        //           await SharedPreferences
                                        //                   .getInstance()
                                        //               .then((prefs) =>
                                        //                   prefs.getString(
                                        //                       'StationName'));
                                        //       var fname =
                                        //           await SharedPreferences
                                        //                   .getInstance()
                                        //               .then((prefs) => prefs
                                        //                   .getString('fname'));
                                        //       var lname =
                                        //           await SharedPreferences
                                        //                   .getInstance()
                                        //               .then((prefs) => prefs
                                        //                   .getString('lname'));
                                        //       var username =
                                        //           "${fname!} ${lname!}";

                                        //       widget.system == "E-Auction"
                                        //           ? null
                                        //           : Navigator.pushNamed(context,
                                        //               Payments.routeName,
                                        //               arguments:
                                        //                   ReceiptScreenArguments(
                                        //                       data[index]["DealerName"]
                                        //                           .toString(),
                                        //                       data[index]["ControlNumber"]
                                        //                           .toString(),
                                        //                       data[index]["bank_receipt_no"]
                                        //                           .toString(),
                                        //                       widget.system ==
                                        //                                   "E-Auction" ||
                                        //                               widget.system ==
                                        //                                   "PMIS"
                                        //                           ? data[index][
                                        //                               "BillAmount"]
                                        //                           : widget.system ==
                                        //                                   "honeytraceability"
                                        //                               ? data[index]["BillAmount"]
                                        //                                   .toDouble()
                                        //                               : double.parse(
                                        //                                   data[index][
                                        //                                       "BillAmount"]),
                                        //                       true,
                                        //                       data[index]["BillDesc"]
                                        //                           .toString(),
                                        //                       username,
                                        //                       station: station,
                                        //                       currency:
                                        //                           data[index]["currency"]
                                        //                               .toString(),
                                        //                       billId: data[index]
                                        //                               ["BillId"]
                                        //                           .toString()));
                                        //     },
                                        //     trailing: Column(
                                        //       mainAxisAlignment:
                                        //           MainAxisAlignment.center,
                                        //       children: const [
                                        //         Icon(
                                        //           Icons
                                        //               .pending_actions_outlined,
                                        //           color: Colors.pink,
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
                                        //         "Name: ${data[index]["DealerName"]}"),
                                        //     subtitle: Text(
                                        //         'Control #: ${data[index]["ControlNumber"]}'),
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
      ))),
    );
  }
}
