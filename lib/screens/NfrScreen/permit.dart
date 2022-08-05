// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class PermittScreen extends StatefulWidget {
  final String id;
  const PermittScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<PermittScreen> createState() => _PermittScreenState();
}

class _PermittScreenState extends State<PermittScreen> {
  String? brand;
  String? station;
  List data = [];
  List activities = [];
  bool isLoading = false;
  Future getdata() async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      //print(tokens);
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/entrance_permit/${widget.id}');
      //print(widget.id);
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
            activities = res["data"]["activities"];
            isLoading = false;
          });

          return 'success';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //////print(res);

            isLoading = false;
          });

          break;
      }
    } catch (e) {
      setState(() {
        //////print(e);

        isLoading = false;
      });
      return 'fail';
    }
  }

  getBrand() async {
    brand = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('brand'));
    station = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('StationName'));
  }

  static const platform = MethodChannel(
    'samples.flutter.dev/printing',
  );
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getBrand();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' Entrance Permit',
          style: TextStyle(
              color: Colors.white, fontFamily: 'ubuntu', fontSize: 12.sp),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          // height: getRelativeHeight(0.09),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: isLoading
                ? const Center(
                    child: SpinKitCircle(
                      color: kPrimaryColor,
                    ),
                  )
                : data.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: SizedBox(
                            // height: getProportionateScreenHeight(60),
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                trailing: Icon(Icons.donut_large_outlined),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.hourglass_empty_outlined,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                title: Text(
                                  "No Data Found",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                // subtitle: Text(""),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: getProportionateScreenHeight(10),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey[400]!.withOpacity(0.2),
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
                                                      height: double.maxFinite,
                                                      width:
                                                          getProportionateScreenHeight(
                                                              50),
                                                      child: Row(
                                                        children: [
                                                          VerticalDivider(
                                                            color: Colors
                                                                .green[200],
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
                                                Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.green,
                                                          width: 1,
                                                          style: BorderStyle
                                                              .solid),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        "Entry Form Preview",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    "Entry Form Permit For Persons,Animals Or Vehicles Into Forest Reserve",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[500]!)),
                                              ]),
                                        )
                                      ]),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey[600],
                                ),
                                ticketDetailsWidget(
                                    "Granted To",
                                    data[0]["client"].toString(),
                                    "Forest Reserve",
                                    data[0]["reserve"].toString()),
                                SizedBox(
                                    height: getProportionateScreenHeight(10)),
                                ticketDetailsWidget(
                                    "Entry Point",
                                    data[0]["entry_point"].toString(),
                                    "District",
                                    data[0]["entry_point"].toString()),
                                SizedBox(
                                    height: getProportionateScreenHeight(10)),
                                ticketDetailsWidget(
                                    "Fee Payed",
                                    data[0]["fee"].toString(),
                                    "Receipt No",
                                    data[0]["receipt_no"].toString()),
                                SizedBox(
                                    height: getProportionateScreenHeight(10)),
                                ticketDetailsWidget(
                                    "Station",
                                    station.toString(),
                                    "Valid Days",
                                    data[0]["valid_days"].toString()),
                                SizedBox(
                                    height: getProportionateScreenHeight(10)),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const <Widget>[
                                            Text(
                                              "Activities",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 1.0),
                                              child: Text(
                                                "Kayaking,Climbing Mountain, and Horse Riding",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: getProportionateScreenHeight(20)),
                                Divider(
                                  color: Colors.grey[600],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: kPrimaryColor,
                                      ),
                                      onPressed: () {
                                        printPermit();
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: const [
                                          Icon(Icons.print_outlined),
                                          Text("Print Entrance Permit"),
                                        ],
                                      )),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  printPermit() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Starting Printer"),
        ),
      );
      // print(qrList);
      final String result = await platform.invokeMethod('getBatteryLevel', {
        "activity": "QrCode",
        "activities": activities,
        "brand": brand,
        "client_name": data[0]["client"].toString(),
        "reserve": data[0]["reserve"].toString(),
        "entry_point": data[0]["entry_point"].toString(),
        "fee": data[0]["fee"].toString(),
        "receipt_no": data[0]["receipt_no"].toString(),
        "valid_days": data[0]["valid_days"].toString(),
      });
      if (result == "Successfully Printed") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
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
}
