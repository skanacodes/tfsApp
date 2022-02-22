import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/payments/payments.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/receiptArguments.dart';
import 'package:tfsappv1/services/size_config.dart';

class ListPendingBills extends StatefulWidget {
  static String routeName = "/pendingBills";
  final String system;
  ListPendingBills(this.system);

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
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Future getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // print(tokens);
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('http://mis.tfs.go.tz/fremis-test/api/v1/paid-bills');
      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          setState(() {
            res = json.decode(response.body);
            print(res);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print(e);
        messages('Server Or Connectivity Error', 'error');
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
      // print(tokens);
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url =
          Uri.parse('https://mis.tfs.go.tz/e-auction/api/Bill/AccountsBill');
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
            print(res);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print(e);
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
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // print(tokens);
      var headers = {"Authorization": "Bearer " + seedToken};
      var url = widget.system == "seedMIS"
          ? Uri.parse('http://41.59.227.103:9092/api/v1/bills')
          : Uri.parse('https://mis.tfs.go.tz/honey-traceability/api/v1/bills');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
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
          child: Text(
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

  Future searchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // print(tokens);
      var headers = {"Authorization": "Bearer " + seedToken};
      var url = widget.system == "seedMIS"
          ? Uri.parse(
              'http://41.59.227.103:9092/api/v1/bill-by-controlnumber/$controlNo/2')
          : Uri.parse(
              'https://mis.tfs.go.tz/honey-traceability/api/v1/bill-by-controlnumber/$controlNo/2');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            data = res['data'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    _refreshController.refreshCompleted();
  }

  searchBar() {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 4,
                child: Container(
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
                                print(controlNo);
                                await searchData();
                              }
                            },
                            child: Icon(
                              Icons.search,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          label: Text(
                            "Search By Control Number",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          filled: true)),
                )),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    widget.system == "seedMIS"
        ? this.getUserDetails()
        : widget.system == "HoneyTraceability"
            ? this.getUserDetails()
            : widget.system == "E-Auction"
                ? this.getDataEAuction()
                : this.getData();

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' List Of Pending Bills',
          style: TextStyle(
              color: Colors.black, fontFamily: 'ubuntu', fontSize: 17),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
          child: SingleChildScrollView(
              child: Container(
        height: getProportionateScreenHeight(700),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus? mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text("pull up load");
              } else if (mode == LoadStatus.loading) {
                body = CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text("Load Failed!Click retry!");
              } else if (mode == LoadStatus.canLoading) {
                body = Text("release to load more");
              } else {
                body = Text("No more Data");
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: () {
            widget.system == "seedMIS"
                ? this.getUserDetails()
                : widget.system == "HoneyTraceability"
                    ? this.getUserDetails()
                    : widget.system == "E-Auction"
                        ? this.getDataEAuction()
                        : this.getData();
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
                    decoration: BoxDecoration(color: kPrimaryColor),
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
                padding: EdgeInsets.all(10),
                child: isLoading
                    ? SpinKitCircle(
                        color: kPrimaryColor,
                      )
                    : data.isEmpty
                        ? Center(
                            child: Container(
                              height: getProportionateScreenHeight(400),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
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
                                itemBuilder: (BuildContext context, int index) {
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
                                          child: Container(
                                            child: ListTile(
                                              onTap: () {
                                                widget.system == "E-Auction"
                                                    ? null
                                                    : Navigator.pushNamed(
                                                        context,
                                                        Payments.routeName,
                                                        arguments:
                                                            ReceiptScreenArguments(
                                                          data[index]
                                                                  ["payer_name"]
                                                              .toString(),
                                                          data[index][
                                                                  "control_number"]
                                                              .toString(),
                                                          widget.system ==
                                                                  "seedMIS"
                                                              ? ""
                                                              : data[index][
                                                                      "control_number"]
                                                                  .toString(),
                                                          data[index]
                                                              ["bill_amount"],
                                                          true,
                                                          data[index]
                                                                  ["bill_desc"]
                                                              .toString(),
                                                          "",
                                                        ));
                                              },
                                              trailing: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .pending_actions_outlined,
                                                    color: Colors.pink,
                                                    size: 15,
                                                  ),
                                                ],
                                              ),
                                              leading: CircleAvatar(
                                                  backgroundColor: Colors.grey,
                                                  child: Text('${index + 1}')),
                                              title: Text(widget.system ==
                                                      "E-Auction"
                                                  ? "Name: " +
                                                      data[index]["DealerName"]
                                                          .toString()
                                                  : "Name: " +
                                                      data[index]["payer_name"]
                                                          .toString()),
                                              subtitle: Text(widget.system ==
                                                      "E-Auction"
                                                  ? 'Control #: ' +
                                                      data[index]
                                                              ["ControlNumber"]
                                                          .toString()
                                                  : 'Control #: ' +
                                                      data[index]
                                                              ["control_number"]
                                                          .toString()),
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
      ))),
    );
  }

  Future<String> getUserDetails() async {
    try {
      setState(() {
        isLoading = true;
      });
      var url = Uri.parse(widget.system == "HoneyTraceability"
          ? "https://mis.tfs.go.tz/honey-traceability/api/v1/login"
          : '$baseUrlSeed/api/v1/login');
      String email = widget.system == "HoneyTraceability"
          ? 'onestpaul8@gmail.com'
          : 'admin@localhost';
      String password =
          widget.system == "HoneyTraceability" ? '12345678' : 'muyenjwa';
      print(email);
      print(password);
      final response = await http.post(
        url,
        body: {'email': email, 'password': password},
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            seedToken = res["token"];
          });
          await getDataSeed();
          return 'success';
          // ignore: dead_code
          break;
        case 403:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          return 'fail';
          // ignore: dead_code
          break;

        case 1200:
          setState(() {
            res = json.decode(response.body);
            print(res);
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
            print(res);
            // addError(error: 'Something Went Wrong');
            // isLoading = false;
          });
          return 'fail';
          // ignore: dead_code
          break;
      }
    } catch (e) {
      setState(() {
        print(e);

        // addError(error: 'Server Or Network Connectivity Error');
        // isLoading = false;
      });
      return 'fail';
    }
  }
}
