// ignore_for_file: file_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/screens/ApprovalPermit/ApprovalDetails.dart';
import 'package:tfsappv1/screens/ApprovalPermit/AprovalTimeline.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class ExpectedApprovals extends StatefulWidget {
  static String routeName = "/approvalTimeline";
  const ExpectedApprovals({Key? key}) : super(key: key);

  @override
  State<ExpectedApprovals> createState() => _ExpectedApprovalsState();
}

class _ExpectedApprovalsState extends State<ExpectedApprovals> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? comment;
  List timeLine = [];
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
      var url = Uri.parse('$baseUrl/api/v1/exp_appr_req/fw');

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
            Data = res["data"];
            // for (var i = 0; i < Data.length; i++) {
            //   timeLine.add()
            // }
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

  Future getApprovalRejectStatus(String operation, int id) async {
    try {
      setState(() {
        isLoading = true;
      });
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = operation == "approve"
          ? Uri.parse('$baseUrl/api/v1/tp_extend/authorize/$id')
          : Uri.parse('$baseUrl/api/v1/xp_appr_req/reject');

      final response = operation == "approve"
          ? await http.get(url, headers: headers)
          : await http.post(
              url,
              headers: headers,
              body: {"reject_comment": comment, "id": id},
            );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);

            print(res);
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
            print(res);

            isLoading = false;

            message("error", "Something Went Wrong");
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);

        isLoading = false;
      });
      message("error", "Something Went Wrong");
      return 'fail';
    }
  }

  Future comments(int id) {
    return Alert(
        context: context,
        title: "Remarks/Comment",
        content: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: TextFormField(
                  maxLines: 5,
                  keyboardType: TextInputType.text,
                  key: const Key(""),
                  onSaved: (val) => comment = val!,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                      ),
                    ),
                    fillColor: const Color(0xfff3f3f4),
                    filled: true,
                    labelText: "Rejection Comment",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  // onChanged: (val) {
                  //   setState(() {});
                  // },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "This Field Is Required";
                    }
                    if (value.length < 15) {
                      return "Reason Unsatisfactory";
                    }
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
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // print(comment);
                // print(id);
                Navigator.of(context).pop();
                await getApprovalRejectStatus("reject", id);
              }
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
          'Approval Request(s) Timeline' " (${Data.length})",
          style: TextStyle(
              color: Colors.white, fontFamily: 'ubuntu', fontSize: 11.sp),
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
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ApprovalTimeline(
                                            data: [
                                              Data[index]["review_time"]
                                                          .toString() ==
                                                      "null"
                                                  ? ""
                                                  : DateTime.now()
                                                              .difference(DateTime
                                                                  .parse(Data[index]
                                                                          [
                                                                          "review_time"]
                                                                      .toString()))
                                                              .inDays
                                                              .toString() ==
                                                          "0"
                                                      ? Data[index]
                                                              ["review_time"]
                                                          .toString()
                                                      : "${DateTime.now().difference(DateTime.parse(Data[index]["review_time"].toString())).inDays} day(s) ago",
                                              Data[index]["assessment_time"]
                                                          .toString() ==
                                                      "null"
                                                  ? ""
                                                  : DateTime.now()
                                                              .difference(DateTime
                                                                  .parse(Data[index]
                                                                          [
                                                                          "assessment_time"]
                                                                      .toString()))
                                                              .inDays
                                                              .toString() ==
                                                          "0"
                                                      ? Data[index][
                                                              "assessment_time"]
                                                          .toString()
                                                      : "${DateTime.now().difference(DateTime.parse(Data[index]["assessment_time"].toString())).inDays} day(s) ago",
                                              Data[index]["zm_time"]
                                                          .toString() ==
                                                      "null"
                                                  ? ""
                                                  : DateTime.now()
                                                              .difference(DateTime
                                                                  .parse(Data[index]
                                                                          [
                                                                          "zm_time"]
                                                                      .toString()))
                                                              .inDays
                                                              .toString() ==
                                                          "0"
                                                      ? Data[index]["zm_time"]
                                                          .toString()
                                                      : "${DateTime.now().difference(DateTime.parse(Data[index]["zm_time"].toString())).inDays} day(s) ago",
                                              Data[index]["submission_time"]
                                                          .toString() ==
                                                      "null"
                                                  ? ""
                                                  : DateTime.now()
                                                              .difference(DateTime
                                                                  .parse(Data[index]
                                                                          [
                                                                          "submission_time"]
                                                                      .toString()))
                                                              .inDays
                                                              .toString() ==
                                                          "0"
                                                      ? Data[index][
                                                              "submission_time"]
                                                          .toString()
                                                      : "${DateTime.now().difference(DateTime.parse(Data[index]["submission_time"].toString())).inDays} day(s) ago",
                                            ],
                                          )));
                            },
                            child: Container(
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
                                        flex: 5,
                                        child: Row(children: [
                                          SizedBox(
                                              width: 20,
                                              height: 40,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: IntrinsicHeight(
                                                    child: SizedBox(
                                                        height:
                                                            double.maxFinite,
                                                        width:
                                                            getProportionateScreenHeight(
                                                                50),
                                                        child: Row(
                                                          children: [
                                                            VerticalDivider(
                                                              color: index
                                                                      .isEven
                                                                  ? kPrimaryColor
                                                                  : Colors.green[
                                                                      200],
                                                              thickness: 5,
                                                            )
                                                          ],
                                                        ))),
                                              )),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            flex: 4,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      "Client Name: ${Data[index]["client_name"]}",
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                      "Address: ${Data[index]["postal_address"]}",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey[500])),
                                                  Text(
                                                      Data[index]["submission_time"]
                                                                  .toString() ==
                                                              "null"
                                                          ? ""
                                                          : "DFC Submission Time: ${DateTime.now().difference(DateTime.parse(Data[index]["submission_time"].toString())).inDays} day(s) ago",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey[500])),
                                                  Text(
                                                      Data[index]["zm_time"]
                                                                  .toString() ==
                                                              "null"
                                                          ? ""
                                                          : "Zonal Review Time: ${DateTime.now().difference(DateTime.parse(Data[index]["zm_time"].toString())).inDays} day(s) ago",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey[500])),
                                                  Text(
                                                      Data[index]["assessment_time"]
                                                                  .toString() ==
                                                              "null"
                                                          ? ""
                                                          : "Licensing Assessment Time: ${DateTime.now().difference(DateTime.parse(Data[index]["assessment_time"].toString())).inDays} day(s) ago",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey[500])),
                                                  Text(
                                                      Data[index]["review_time"]  
                                                                  .toString() ==
                                                              "null"
                                                          ? ""
                                                          : "DMRU Review Time:  ${DateTime.now().difference(DateTime.parse(Data[index]["review_time"].toString())).inDays} day(s) ago",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey[500])),
                                                ]),
                                          )
                                        ]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
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

  verificationMessage(String hint, String message, int id) {
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
            setState(() {
              isLoading = true;
            });

            await getApprovalRejectStatus("approve", id);

            setState(() {
              isLoading = false;
            });
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
              Navigator.pop(context);
              // message("sdfvdsf", "dsf");
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
