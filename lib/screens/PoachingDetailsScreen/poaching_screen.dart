import 'dart:convert';

import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:http/http.dart' as http;
import 'package:tfsappv1/services/size_config.dart';

class PoachingActivitiesScreen extends StatefulWidget {
  static String routeName = "/poaching";
  const PoachingActivitiesScreen({super.key});

  @override
  State<PoachingActivitiesScreen> createState() =>
      _PoachingActivitiesScreenState();
}

class _PoachingActivitiesScreenState extends State<PoachingActivitiesScreen> {
  bool isLoading = false;
  List data = [];
  final GlobalKey<ExpansionTileCardState> cardA = GlobalKey();
  Future getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrl/api/v1/cc-event');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            // print(res);
            data = res["data"];
            //employeeDataSource = EmployeeDataSource(employeeData: data);
            isLoading = false;
          });

          return 'success';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);

            isLoading = false;
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);

        isLoading = false;
      });
      return 'fail';
    }
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
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        )
      ],
    ).show();
  }

  verificationMessage(String hint, String message, {int? id}) {
    return Alert(
      context: context,
      type: hint == "info" ? AlertType.info : AlertType.success,
      title: "",
      desc: message,
      buttons: [
        DialogButton(
          color: kPrimaryColor,
          radius: const BorderRadius.all(Radius.circular(10)),
          onPressed: () async {
            Navigator.pop(context);

            await getApprovalRejectStatus("approve", 0);
          },
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          color: Colors.red,
          radius: const BorderRadius.all(Radius.circular(10)),
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

  Future getApprovalRejectStatus(String operation, int id) async {
    try {
      setState(() {
        isLoading = true;
      });
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = operation == "approve"
          ? Uri.parse('$baseUrl/api/v1/approve-event')
          : Uri.parse('$baseUrl/api/v1/exp_appr_req/reject');

      final response = operation == "approve"
          ? await http.get(url, headers: headers)
          : await http.post(url,
              headers: headers,
              body: {"id": id.toString(), "reject_comment": "comment"});
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            if (res["data"].toString() == "Events Already Approved") {
              message("error", "Events Already Approved");
            }

            if (res["success"]) {
              message("success", "The Events Is Approved Successfully");
            }
            isLoading = false;
          });
          break;

        case 201:
          setState(() {
            isLoading = false;
          });
          operation == "approve"
              ? message("success", "Successfully Approved")
              : message("success", "Successfully Rejected");
          return 'success';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            // //print(res);

            isLoading = false;

            message("error", "Something Went Wrong");
          });

          break;
      }
    } catch (e) {
      setState(() {
        //  //print(e);

        isLoading = false;
      });
      message("error", "Something Went Wrong");
      return 'fail';
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget ticketDetailsWidget(String firstTitle, String firstDesc,
      String secondTitle, String secondDesc) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  firstTitle,
                  style: const TextStyle(color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Text(
                    firstDesc,
                    style: const TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  secondTitle,
                  style: const TextStyle(color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Text(
                    secondDesc,
                    style: const TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //employees = getEmployeeData();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poaching Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () {
                  verificationMessage(
                      "info", "Are You Sure You Want To Approve");
                },
                child: const Text("Approve")),
          )
        ],
      ),
      body: ListView(
        children: [
          data.isEmpty
              ? SizedBox(
                  height: getProportionateScreenHeight(300),
                  child: const Center(
                    child: CupertinoActivityIndicator(
                      animating: true,
                    ),
                  ),
                )
              : Container(),
          for (var i = 0; i < data.length; i++)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Container(
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
                child: ExpansionTileCard(
                  // key: cardA,
                  expandedTextColor: kPrimaryColor,
                  initialElevation: 10,
                  elevation: 10,
                  leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                      )),
                  title: const Text('Event'),
                  subtitle: Text(
                    data[i]["name"].toString(),
                    style: const TextStyle(color: Colors.black54),
                  ),
                  children: <Widget>[
                    const Divider(
                      thickness: 1.0,
                      height: 1.0,
                    ),

                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          //  mainAxisAlignment: MainAxisAlignment.start,
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var j = 0;
                                j < data[i]["poach_aggregate"].length;
                                j++)
                              ticketDetailsWidget(
                                "Zone",
                                data[i]["poach_aggregate"][j]["zone"]
                                    .toString(),
                                "Quantity",
                                data[i]["poach_aggregate"][j]["no_of_events"]
                                    .toString(),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Divider(
                                color: Colors.grey[400],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(20),
                    ),
                    // ButtonBar(
                    //   alignment: MainAxisAlignment.spaceAround,
                    //   buttonHeight: 52.0,
                    //   buttonMinWidth: 90.0,
                    //   children: <Widget>[
                    //     TextButton(
                    //       style: flatButtonStyle,
                    //       onPressed: () {
                    //         cardB.currentState?.expand();
                    //       },
                    //       child: Column(
                    //         children: const <Widget>[
                    //           Icon(Icons.arrow_downward),
                    //           Padding(
                    //             padding: EdgeInsets.symmetric(vertical: 2.0),
                    //           ),
                    //           Text('Open'),
                    //         ],
                    //       ),
                    //     ),
                    //     TextButton(
                    //       style: flatButtonStyle,
                    //       onPressed: () {
                    //         cardB.currentState?.collapse();
                    //       },
                    //       child: Column(
                    //         children: const <Widget>[
                    //           Icon(Icons.arrow_upward),
                    //           Padding(
                    //             padding: EdgeInsets.symmetric(vertical: 2.0),
                    //           ),
                    //           Text('Close'),
                    //         ],
                    //       ),
                    //     ),
                    //     TextButton(
                    //       style: flatButtonStyle,
                    //       onPressed: () {
                    //         cardB.currentState?.toggleExpansion();
                    //       },
                    //       child: Column(
                    //         children: const <Widget>[
                    //           Icon(Icons.swap_vert),
                    //           Padding(
                    //             padding: EdgeInsets.symmetric(vertical: 2.0),
                    //           ),
                    //           Text('Toggle'),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
