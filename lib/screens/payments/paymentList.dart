import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/payments/billForm.dart';
import 'package:tfsappv1/screens/payments/payments.dart';

import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/receiptArguments.dart';

import 'package:tfsappv1/services/size_config.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

class PaymentList extends StatefulWidget {
  static String routeName = "/paymentList";
  PaymentList({Key? key}) : super(key: key);

  @override
  _PaymentListState createState() => _PaymentListState();
}

class _PaymentListState extends State<PaymentList> {
  String? type;
  List data = [];
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

  @override
  void initState() {
    RealTimeCommunication().createConnection(
      "5",
    );
    this.getData();
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' Generate Bill',
          style: TextStyle(color: Colors.black, fontFamily: 'ubuntu'),
        ),
        backgroundColor: kPrimaryColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          'Generate Bill',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        icon: Icon(Icons.add),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        tooltip: 'Generate Bill',
        onPressed: () {
          Navigator.pushNamed(
            context,
            BillForm.routeName,
          ).then((_) => RealTimeCommunication().createConnection("5"));
        },
      ),
      body: SingleChildScrollView(
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
            onRefresh: getData,
            onLoading: _onLoading,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: isLoading
                      ? SpinKitCircle(
                          color: kPrimaryColor,
                        )
                      : Container(
                          height: getProportionateScreenHeight(650),
                          color: Colors.white,
                          child: AnimationLimiter(
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 1375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Card(
                                        elevation: 10,
                                        shadowColor: Colors.grey,
                                        child: Container(
                                          child: ListTile(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, Payments.routeName,
                                                  arguments:
                                                      ReceiptScreenArguments(
                                                    data[index]["payer_name"]
                                                        .toString(),
                                                    data[index]
                                                            ["control_number"]
                                                        .toString(),
                                                    data[index]["receipt_no"]
                                                        .toString(),
                                                    data[index]["bill_amount"]
                                                        .toString(),
                                                    data[index]["bill_desc"]
                                                        .toString(),
                                                    data[index]["issuer"]
                                                        .toString(),
                                                  ));
                                            },
                                            trailing: Icon(
                                              Icons.arrow_right,
                                              color: Colors.cyan,
                                            ),
                                            leading: CircleAvatar(
                                                backgroundColor: kPrimaryColor,
                                                child: Text('${index + 1}')),
                                            title: Text("Name: " +
                                                data[index]["payer_name"]
                                                    .toString()),
                                            subtitle: Text('Control #: ' +
                                                data[index]["control_number"]
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
        ),
      ),
    );
  }
}
