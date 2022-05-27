// ignore_for_file: file_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class ApprovalDetails extends StatefulWidget {
  static String routeName = "/ApprovalDetails";
  final List? data;
  const ApprovalDetails({Key? key, this.data}) : super(key: key);

  @override
  State<ApprovalDetails> createState() => _ApprovalDetailsState();
}

class _ApprovalDetailsState extends State<ApprovalDetails> {
  final GlobalKey<ExpansionTileCardState> cardA = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardB = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardC = GlobalKey();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? comment;

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
                await getApprovalRejectStatus("reject", id);
                Navigator.pop(context);
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

  Future getApprovalRejectStatus(String operation, int id) async {
    try {
      setState(() {
        isLoading = true;
      });
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = operation == "approve"
          ? Uri.parse(
              'https://mis.tfs.go.tz/fremis-test/api/v1/exp_appr_req/approve/$id')
          : Uri.parse(
              'https://mis.tfs.go.tz/fremis-test/api/v1/xp_appr_req/reject/$id');

      final response = operation == "approve"
          ? await http.get(url, headers: headers)
          : await http.post(url,
              headers: headers,
              body: {"id": id.toString(), "reject_comment": comment});
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print("bhjbn");
      switch (response.statusCode) {
        case 201:
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

  message(String hint, String message) {
    return Alert(
      context: context,
      type: hint == "error" ? AlertType.error : AlertType.success,
      title: "Information",
      desc: message,
      buttons: [
        DialogButton(
          child: const Text(
            "Ok",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );
    // print(widget.data.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Approval Details",
          style: TextStyle(
              color: Colors.black, fontFamily: 'ubuntu', fontSize: 17),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                key: cardA,
                expandedTextColor: kPrimaryColor,
                initialElevation: 10,
                elevation: 10,
                leading: CircleAvatar(
                    backgroundColor: Colors.grey[400],
                    child: const Icon(
                      Icons.all_out_outlined,
                      color: Colors.pink,
                    )),
                title: const Text('Allocation'),
                subtitle: const Text('Client Allocations Details'),
                children: <Widget>[
                  const Divider(
                    thickness: 1.0,
                    height: 1.0,
                  ),

                  widget.data![0]["allocations"].isEmpty
                      ? const Center(
                          child: Text("No Data Found"),
                        )
                      : Container(),
                  for (var i = 0;
                      i < widget.data![0]["allocations"].length;
                      i++)
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(
                                    flex: 4, child: Text("Product Name: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["allocations"][i]
                                          ["product_name"]
                                      .toString()),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(
                                    flex: 4, child: Text("Certificate No: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["allocations"][i]
                                          ["cert_no"]
                                      .toString()),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(
                                    flex: 4, child: Text("Quantity: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["allocations"][i]
                                          ["quantity"]
                                      .toString()),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(
                                    flex: 4,
                                    child: Text("Quantity Consumed: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["allocations"][i]
                                          ["quantity_consumed"]
                                      .toString()),
                                ),
                              ],
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
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                key: cardB,
                expandedTextColor: kPrimaryColor,
                initialElevation: 10,
                elevation: 10,
                leading: CircleAvatar(
                    backgroundColor: Colors.grey[400],
                    child:
                        const Icon(Icons.production_quantity_limits_outlined)),
                title: const Text('Products'),
                subtitle: const Text('Client Product Details'),
                children: <Widget>[
                  const Divider(
                    thickness: 1.0,
                    height: 1.0,
                  ),
                  widget.data![0]["exp_products"].isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text("No Data Found"),
                          ),
                        )
                      : Container(),
                  for (var i = 0;
                      i < widget.data![0]["exp_products"].length;
                      i++)
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(
                                    flex: 4, child: Text("Product Name: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["exp_products"][i]
                                          ["product_name"]
                                      .toString()),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(
                                    flex: 4, child: Text("Quantity: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["exp_products"][i]
                                              ["quantity"]
                                          .toString() +
                                      " " +
                                      widget.data![0]["exp_products"][i]["unit"]
                                          .toString()),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(
                                    flex: 4,
                                    child: Text("Destination Country: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["exp_products"][i]
                                          ["destination_country"]
                                      .toString()),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(
                                    flex: 4, child: Text("Length: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["exp_products"][i]
                                          ["length"]
                                      .toString()),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(flex: 4, child: Text("Width: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["exp_products"][i]
                                          ["width"]
                                      .toString()),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(
                                    flex: 4, child: Text("Thickness: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["exp_products"][i]
                                          ["thickness"]
                                      .toString()),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(
                                    flex: 4, child: Text("Scientific Name: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["exp_products"][i]
                                          ["scientific_name"]
                                      .toString()),
                                ),
                              ],
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
                ],
              ),
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                key: cardC,
                expandedTextColor: kPrimaryColor,
                initialElevation: 10,
                elevation: 10,
                leading: CircleAvatar(
                    backgroundColor: Colors.grey[400],
                    child: const Icon(
                      Icons.event_available_outlined,
                      color: Colors.purple,
                    )),
                title: const Text('Attachments'),
                subtitle: const Text('List Of Attachments'),
                children: <Widget>[
                  const Divider(
                    thickness: 1.0,
                    height: 1.0,
                  ),
                  widget.data![0]["exp_attachments"].isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text("No Data Found"),
                          ),
                        )
                      : Container(),
                  for (var i = 0;
                      i < widget.data![0]["exp_attachments"].length;
                      i++)
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Expanded(flex: 4, child: Text("Name: ")),
                                Expanded(
                                  flex: 4,
                                  child: Text(widget.data![0]["exp_attachments"]
                                          [i]["name"]
                                      .toString()),
                                ),
                              ],
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
                ],
              ),
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    getApprovalRejectStatus("approve", widget.data![0]["id"]);
                  },
                  child: const Text("Accept")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    textStyle: const TextStyle(fontWeight: FontWeight.normal)),
                onPressed: () {
                  comments(widget.data![0]["id"]);
                },
                child: const Text("Decline"),
              )
            ],
          )
        ],
      ),
    );
  }
}
