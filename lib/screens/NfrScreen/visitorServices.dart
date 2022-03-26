// ignore_for_file: unused_field

import 'dart:convert';

import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class VisitorServices extends StatefulWidget {
  final List data;
  final String memberId;
  final String name;
  VisitorServices(
      {Key? key,
      required this.data,
      required this.name,
      required this.memberId})
      : super(key: key);

  @override
  State<VisitorServices> createState() => _VisitorServicesState();
}

class _VisitorServicesState extends State<VisitorServices> {
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();
  bool isLoading = false;
  List iconIndex = [];
  bool _switchValue = false;
  bool isSwitching = false;
  Future signInActivity(serviceId) async {
    setState(() {
      isLoading = true;
    });
    try {
      var url = Uri.parse('$baseUrlTest/api/v1/service/check_in');
      final response = await http.post(url,
          body: {"member_id": widget.memberId, "service_id": serviceId});
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          setState(() {
            res = json.decode(response.body);
            print(res);

            isLoading = false;
          });
          if (res["msg"] == "Service Successfully Checked In") {
            setState(() {
              isSwitching = true;
            });
          } else {
            messages(
              'error',
              'Tourist Already Checked In',
            );
          }

          break;

        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);

            isLoading = false;
          });
          if (res["msg"] == "Error! Tourist Already Checked In") {
            messages(
              'error',
              'Tourist Already Checked In',
            );
          }
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoading = false;
            messages(
              'error',
              'Ohps! Something Went Wrong',
            );
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print(e);
        messages(
          'error',
          'Server Or Connectivity Error',
        );
      });
    }
  }

  Future signOutActivity(serviceId) async {
    setState(() {
      isLoading = true;
    });
    try {
      var url = Uri.parse('$baseUrlTest/api/v1/service/check_out');
      final response = await http.post(url,
          body: {"member_id": widget.memberId, "service_id": serviceId});
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          setState(() {
            res = json.decode(response.body);
            print(res);

            isLoading = false;
          });
          if (res["msg"] == "Service Successfully Checked Out") {
            setState(() {
              isSwitching = true;
            });
          } else {
            messages(
              'error',
              'Error',
            );
          }

          break;

        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);

            isLoading = false;
          });
          if (res["msg"] == "Error! Tourist Already Checked Out") {
            messages('error', 'Tourist Already Checked Out');
          }
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoading = false;
            messages(
              'error',
              'Ohps! Something Went Wrong',
            );
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print(e);
        messages(
          'error',
          'Server Or Connectivity Error',
        );
      });
    }
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

  Widget _title() {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
          text: 'Client',
          style: GoogleFonts.portLligatSans(
            // textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: ' Services',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0.sp,
              ),
            ),
            TextSpan(
              text: ' Info',
              style: TextStyle(
                color: Colors.green[400],
                fontSize: 15.0.sp,
              ),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          '',
          style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Container(
                height: getProportionateScreenHeight(130),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: getProportionateScreenHeight(90),
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.only(
                        //     bottomLeft: Radius.circular(150),
                        //     bottomRight: Radius.circular(150)),
                        color: kPrimaryColor,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Card(
                          elevation: 20,
                          child: ListTile(
                              tileColor: Colors.white,
                              title: _title(),
                              trailing: Icon(
                                Icons.data_saver_off,
                                color: Colors.cyan,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.pink,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ExpansionTileCard(
                  key: cardA,
                  animateTrailing: true,
                  shadowColor: kPrimaryColor,
                  expandedTextColor: Colors.black,
                  duration: Duration(milliseconds: 500),
                  baseColor: Color(0xfff3f3f4),
                  elevation: 10,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.zero,
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),

                  leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.donut_large,
                        color: kPrimaryColor,
                      )),
                  title: Text('Services'),
                  // subtitle: Text(''),
                  children: <Widget>[
                    Divider(
                      thickness: 1.0,
                      height: 1.0,
                      color: Colors.cyan,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text(
                                'Client Name: ',
                                style: TextStyle(color: Colors.black),
                              )),
                          Expanded(
                              flex: 4,
                              child: Text(
                                widget.name,
                                style: TextStyle(color: Colors.black),
                              )),
                        ],
                      ),
                    ),
                    widget.data.isEmpty
                        ? Center(
                            child: Text('There Is No Services In This Package'),
                          )
                        : Container(),
                    for (var i = 0; i < widget.data.length; i++)
                      Column(
                        children: [
                          Divider(
                            color: Colors.grey,
                            endIndent: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Icon(
                                    Icons.sell_rounded,
                                    color: kPrimaryColor,
                                  )),
                              Expanded(
                                  flex: 3, child: Text('Service ${i + 1}: ')),
                              Expanded(
                                  flex: 4, child: Text(widget.data[i]["name"])),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Icon(
                                    Icons.star_outline_sharp,
                                    color: Colors.cyan,
                                  )),
                              Expanded(flex: 3, child: Text('Payment : ')),
                              Expanded(
                                  flex: 4,
                                  child: Text(
                                    "Paid",
                                    style: TextStyle(color: Colors.green),
                                  ))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Icon(
                                    Icons.donut_small_outlined,
                                    color: Colors.purple,
                                  )),
                              Expanded(flex: 3, child: Text('Status : ')),
                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: [
                                    widget.data[i]["is_check_in"].toString() ==
                                                "1" ||
                                            iconIndex.contains(i)
                                        ? Text("In")
                                        : Text("Out"),
                                    Center(
                                      child: CupertinoSwitch(
                                        activeColor: Colors.blue,
                                        value: widget.data[i]["is_check_in"]
                                                        .toString() ==
                                                    "1" ||
                                                iconIndex.contains(i)
                                            ? true
                                            : false,
                                        onChanged: (value) {
                                          value
                                              ? signInActivity(widget.data[i]
                                                      ["id"]
                                                  .toString())
                                              : signOutActivity(widget.data[i]
                                                      ["id"]
                                                  .toString());
                                          if (iconIndex.contains(i)) {
                                            value == true
                                                ? null
                                                : iconIndex.remove(i);
                                          } else {
                                            value ? iconIndex.add(i) : null;
                                          }

                                          setState(() {
                                            _switchValue = value;
                                          });
                                        },
                                      ),
                                    ),
                                    isLoading
                                        ? CupertinoActivityIndicator(
                                            animating: true,
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                              //  Expanded(flex: 2, child: Container())
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
