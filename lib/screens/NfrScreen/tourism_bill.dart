// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class TourismBillScreen extends StatefulWidget {
  final String id;
  const TourismBillScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<TourismBillScreen> createState() => _TourismBillScreenState();
}

class _TourismBillScreenState extends State<TourismBillScreen> {
  bool isLoading = false;
  String? comment;
  List data = [];
  // ignore: non_constant_identifier_names

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

  Future refreshScreen() async {
    await getdata();
  }

  Future createBill(String operation, String id) async {
    try {
      setState(() {
        isLoading = true;
      });
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));

      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = operation == "create"
          ? Uri.parse('$baseUrlTest/api/v1/safari_info/bill-create/$id')
          : Uri.parse('$baseUrlTest/api/v1/safari_info/bill-post/$id');

      final response = operation == "create"
          ? await http.get(url, headers: headers)
          : await http.get(
              url,
              headers: headers,
            );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            print(res);
            isLoading = false;
          });
          if (res["success"]) {
            // print(res);
            operation == "create"
                ? message("success", "Bill Successfully Created!")
                : message("success", "Successfully Posted");
            // print("sbdhfsdf");
            Future.delayed(const Duration(milliseconds: 1000), () {
              setState(() {
                refreshScreen();
              });
            });
          } else {
            message("error", res["message"].toString());
          }

          return 'success';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////print(res);

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

  Future getdata() async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print(tokens);
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url =
          Uri.parse('$baseUrlTest/api/v1/safari_info/bill-view/${widget.id}');
      print(widget.id);
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            data = [res["data"]];
            ////print(res);
            isLoading = false;
          });

          return 'success';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////print(res);

            isLoading = false;
          });

          break;
      }
    } catch (e) {
      setState(() {
        ////print(e);

        isLoading = false;
      });
      return 'fail';
    }
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.id);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Preview Bill",
          style: TextStyle(
              color: Colors.black, fontFamily: 'ubuntu', fontSize: 17),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
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
                          itemCount: data.length,
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
                                      color: Colors.grey[200]!.withOpacity(0.2),
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
                                            flex: 6,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  data[index]["item"][
                                                                  "leader_name"]
                                                              .toString() !=
                                                          "null"
                                                      ? Text(
                                                          "Leader Name: ${data[index]["item"]["leader_name"]}",
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))
                                                      : Text(
                                                          "Group Name: ${data[index]["item"]["group_name"]}",
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                      "No Of Tourist: ${data[index]["item"]["no_of_tourist"]}",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey[500]!)),
                                                ]),
                                          )
                                        ]),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey[400],
                                  ),
                                  data[index]["bill"].toString() == "null"
                                      ? Container()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 15),
                                                child: const Text(
                                                  "Control No: ",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 15),
                                                child: Text(
                                                  data[index]["bill"][
                                                                  "control_number"]
                                                              .toString() ==
                                                          "null"
                                                      ? ""
                                                      : data[index]["bill"]
                                                              ["control_number"]
                                                          .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  data[index]["bill"].toString() == "null"
                                      ? Container()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 15),
                                                child: const Text(
                                                  "Receipt No: ",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 15),
                                                child: Text(
                                                  data[index]["item"][
                                                                  "receipt_number"]
                                                              .toString() ==
                                                          "null"
                                                      ? ""
                                                      : data[index]["item"]
                                                              ["receipt_number"]
                                                          .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  data[index]["bill"].toString() == "null"
                                      ? Container()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 15),
                                                child: const Text(
                                                  "Receipt Date: ",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 15),
                                                child: Text(
                                                  data[index]["item"][
                                                                  "receipt_date"]
                                                              .toString() ==
                                                          "null"
                                                      ? ""
                                                      : data[index]["item"]
                                                              ["receipt_date"]
                                                          .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  data[index]["bill"].toString() == "null"
                                      ? Container()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 15),
                                                child: const Text(
                                                  "Service: ",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 15),
                                                child: Text(
                                                  data[index]["bill"][
                                                                  "product_name"]
                                                              .toString() ==
                                                          "null"
                                                      ? ""
                                                      : data[index]["bill"]
                                                              ["product_name"]
                                                          .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  data[index]["bill"].toString() == "null"
                                      ? Container()
                                      : Divider(
                                          color: Colors.grey[400],
                                        ),
                                  data[index]["bill"].toString() == "null"
                                      ? Container()
                                      : const Text(
                                          "Bills Items",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                  data[index]["bill"].toString() == "null"
                                      ? Container()
                                      : Divider(
                                          color: Colors.grey[400],
                                        ),
                                  for (int j = 0;
                                      j < data[index]["bill_items"].length;
                                      j++)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 15),
                                            child: Text(
                                              "${j + 1}",
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 15),
                                            child: Text(
                                              data[index]["bill_items"][j]
                                                      ["product_name"]
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 15),
                                            child: Text(
                                              "${data[index]["bill_items"][j]["amount"]} ${data[index]["bill_items"][j]["currency"]}",
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  data[index]["bill"].toString() == "null"
                                      ? Container()
                                      : Divider(
                                          color: Colors.grey[600],
                                        ),
                                  data[index]["bill"].toString() == "null"
                                      ? Container()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 15),
                                                child: const Text(
                                                  "Total Amount: ",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: "Ubuntu"),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 15),
                                                child: Text(
                                                  data[index]["bill"][
                                                                  "bill_amount"]
                                                              .toString() ==
                                                          "null"
                                                      ? ""
                                                      : "${formatNumber.format(double.parse(data[index]["bill"]["bill_amount"]))} ${data[index]["bill"]["currency"]}",
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  Divider(
                                    color: Colors.grey[600],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      data[index]["bill"].toString() != "null"
                                          ? Container()
                                          : Expanded(
                                              flex: 3,
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.green,
                                                  ),
                                                  onPressed: () {
                                                    verificationMessage(
                                                        "info",
                                                        "Are You Sure You Want to Create Bill",
                                                        widget.id.toString());
                                                  },
                                                  child: const Text(
                                                    "Create Bill",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ))),
                                      SizedBox(
                                        width: getProportionateScreenWidth(10),
                                      ),
                                      SizedBox(
                                        height:
                                            getProportionateScreenHeight(10),
                                      ),
                                      data[index]["bill"].toString() == "null"
                                          ? Container()
                                          : Expanded(
                                              flex: 3,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: kPrimaryColor,
                                                ),
                                                onPressed: () {
                                                  verificationMessage(
                                                      "info",
                                                      "Are You Sure You Want to Generate Control No",
                                                      data[index]["bill"]["id"]
                                                          .toString());
                                                },
                                                child: const Text(
                                                  "Generate Control No",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              )),
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
      ),
    );
  }

  verificationMessage(String hint, String message, String id) {
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

            message == "Are You Sure You Want to Generate Control No"
                ? await createBill("generate", id)
                : await createBill("create", id);

            setState(() {
              isLoading = false;
            });
          },
          width: 120,
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 10.sp),
          ),
        ),
        DialogButton(
          color: Colors.red,
          radius: const BorderRadius.all(Radius.circular(10)),
          onPressed: () async {
            Navigator.pop(context);
          },
          width: 120,
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 10.sp),
          ),
        )
      ],
    ).show();
  }
}
