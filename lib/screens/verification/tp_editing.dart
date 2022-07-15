// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class TPEditing extends StatefulWidget {
  static String routeName = "/tpEditing";
  const TPEditing({Key? key}) : super(key: key);

  @override
  State<TPEditing> createState() => _TPEditingState();
}

class _TPEditingState extends State<TPEditing> {
  bool isLoading = false;
  // ignore: non_constant_identifier_names
  List Data = [];
  Future getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/tp_edit');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            // //print(res);
            Data = res["data"];
            //print(res);
            isLoading = false;
          });

          return 'success';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);

            isLoading = false;
          });

          break;
      }
    } catch (e) {
      setState(() {
        //print(e);

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

  Future getApprovalRejectStatus(String operation, int id) async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = operation == "approve"
          ? Uri.parse('$baseUrlTest/api/v1/tp_edit/authorize/$id')
          : Uri.parse('$baseUrlTest/api/v1/tp_edit/reject/$id');

      final response = operation == "approve"
          ? await http.get(url, headers: headers)
          : await http
              .post(url, headers: headers, body: {"reject_comment": ""});
      var res;
      //final sharedP prefs=await
      //print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);

            //print(res);
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
            //print(res);

            isLoading = false;

            message("error", "Something Went Wrong");
          });

          break;
      }
    } catch (e) {
      setState(() {
        //print(e);

        isLoading = false;
      });
      message("error", "Something Went Wrong");
      return 'fail';
    }
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          ' Change Request' " (" + Data.length.toString() + ")",
          style: const TextStyle(
              color: Colors.black, fontFamily: 'ubuntu', fontSize: 17),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: SizedBox(
        width: double.infinity,
        // height: getRelativeHeight(0.09),
        child: isLoading
            ? const Center(
                child: SpinKitCircle(
                  color: kPrimaryColor,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(650),
                      child: ListView.builder(
                        itemCount: Data.length,
                        //shrinkWrap: true,
                        //scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(10),
                            vertical: getProportionateScreenHeight(10)),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 15),
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
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(children: [
                                        SizedBox(
                                            width: 50,
                                            height: 40,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: IntrinsicHeight(
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
                                            )),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "TP Number: ${Data[index]["tp_number"]}",
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    "Reason: ${Data[index]["reasons"]}",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[500])),
                                              ]),
                                        )
                                      ]),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          //job.isMyFav = !job.isMyFav;
                                        });
                                      },
                                      child: AnimatedContainer(
                                          height: 35,
                                          padding: const EdgeInsets.all(5),
                                          duration:
                                              const Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color:
                                                      Colors.yellow.shade100)),
                                          child: Center(
                                              child:
                                                  popBar(Data[index]["id"]))),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 15),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.grey.shade200),
                                        child: Text(
                                          "Requested By: " +
                                              Data[index]["requested_by"],
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 15),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.grey.shade200),
                                        child: Text(
                                          "Station: " + Data[index]["station"],
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  popBar(int id) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: PopupMenuButton(
        tooltip: 'Menu',
        offset: const Offset(20, 40),
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () async {
              await getApprovalRejectStatus("approve", id);
            },
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    "Approve",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              await getApprovalRejectStatus("reject", id);
            },
            child: Row(
              children: [
                Icon(
                  Icons.not_interested_outlined,
                  color: Colors.red,
                  size: getProportionateScreenHeight(22),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    "Reject",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        child: const Icon(
          Icons.more_vert,
          size: 28.0,
          color: Colors.black,
        ),
      ),
    );
  }
}
