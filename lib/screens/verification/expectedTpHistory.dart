// ignore_for_file: file_names, prefer_typing_uninitialized_variables, avoid_//print(

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/screens/verification/tpTimeline.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class ExpectedTP extends StatefulWidget {
  static String routeName = "/expectedTp";
  const ExpectedTP({Key? key}) : super(key: key);

  @override
  State<ExpectedTP> createState() => _ExpectedTPState();
}

class _ExpectedTPState extends State<ExpectedTP> {
  String? type;
  String? controlNo;
  List data = [];

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
      String checkpointId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('checkpointId').toString());

      //////print((stationId);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/expected-tp/$checkpointId');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //print((response.statusCode);
      //print((response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print((res);
            if (res["status"] == "Token is Expired") {
              messages("error", "Token Expired.. Please Login Again");
              return;
            }
            data = res['data'];

            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////print((res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////print((e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    _refreshController.refreshCompleted();
  }

  // Future sortData(String duration) async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   try {
  //     ////print((duration);
  //     // var tokens = await SharedPreferences.getInstance()
  //     //     .then((prefs) => prefs.getString('token'));
  //     // ////print((tokens);
  //     var headers = {"Authorization": "Bearer " + seedToken};
  //     var url = Uri.parse(
  //         'https://mis.tfs.go.tz/honey-traceability/api/v1/search-payment-history/$duration/$formattedDate');

  //     final response = await http.get(url, headers: headers);
  //     var res;
  //     //final sharedP prefs=await
  //     ////print((response.statusCode);
  //     switch (response.statusCode) {
  //       case 200:
  //         setState(() {
  //           res = json.decode(response.body);
  //           ////print((res);
  //           data = res['data'];
  //           isLoading = false;
  //         });

  //         break;

  //       default:
  //         setState(() {
  //           res = json.decode(response.body);
  //           ////print((res);
  //           isLoading = false;
  //           messages('Ohps! Something Went Wrong', 'error');
  //         });

  //         break;
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //       ////print((e);
  //       messages('Server Or Connectivity Error', 'error');
  //     });
  //   }
  //   _refreshController.refreshCompleted();
  // }

  // Future searchData() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   try {
  //     // var tokens = await SharedPreferences.getInstance()
  //     //     .then((prefs) => prefs.getString('token'));
  //     // ////print((tokens);
  //     var headers = {"Authorization": "Bearer " + seedToken};
  //     var url = Uri.parse(
  //         'https://mis.tfs.go.tz/honey-traceability/api/v1/bill-by-controlnumber/$controlNo/1');

  //     final response = await http.get(url, headers: headers);
  //     var res;
  //     //final sharedP prefs=await
  //     ////print((response.statusCode);
  //     switch (response.statusCode) {
  //       case 200:
  //         setState(() {
  //           res = json.decode(response.body);
  //           ////print((res);
  //           data = res['data'];
  //           isLoading = false;
  //         });

  //         break;

  //       default:
  //         setState(() {
  //           res = json.decode(response.body);
  //           ////print((res);
  //           isLoading = false;
  //           messages('Ohps! Something Went Wrong', 'error');
  //         });

  //         break;
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //       ////print((e);
  //       messages('Server Or Connectivity Error', 'error');
  //     });
  //   }
  //   _refreshController.refreshCompleted();
  // }

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
      style: const AlertStyle(descStyle: TextStyle(fontSize: 17)),
      context: context,
      type: type == 'success'
          ? AlertType.success
          : type == "info"
              ? AlertType.info
              : AlertType.error,
      // title: 'Information',
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
                              // ////print((controlNo);
                              // await searchData();
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
                          "Search by TP Number",
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
    getData();

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' List Of Expected TP',
          style: TextStyle(
              color: Colors.black, fontFamily: 'ubuntu', fontSize: 17),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: getProportionateScreenHeight(700),
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
              getData();
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
                              height: getProportionateScreenHeight(530),
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
                                          child: Card(
                                            elevation: 10,
                                            shadowColor: Colors.grey,
                                            child: ListTile(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TPtimeline(
                                                              tpNumber: data[
                                                                          index]
                                                                      ["tp_id"]
                                                                  .toString(),
                                                            )));
                                              },
                                              trailing: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons
                                                        .arrow_forward_ios_sharp,
                                                    color: kPrimaryColor,
                                                    size: 15,
                                                  ),
                                                ],
                                              ),
                                              leading: IntrinsicHeight(
                                                  child: SizedBox(
                                                      height: double.maxFinite,
                                                      width:
                                                          getProportionateScreenHeight(
                                                              50),
                                                      child: Row(
                                                        children: [
                                                          VerticalDivider(
                                                            color: index.isEven
                                                                ? kPrimaryColor
                                                                : Colors
                                                                    .green[200],
                                                            thickness: 5,
                                                          )
                                                        ],
                                                      ))),
                                              title: Text(
                                                "TP-Number: ${data[index]["tp_number"]}",
                                              ),
                                              subtitle: Text(
                                                data[index]["remained"]
                                                            .toString() ==
                                                        "0"
                                                    ? "Arriving Soon"
                                                    : "Station(s) Remained: ${data[index]["remained"]}",
                                              ),
                                            ),
                                          ),
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
              //  sortData(pastMonth);
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
              // sortData(pastWeek);
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
              //  sortData(formattedDate);
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
