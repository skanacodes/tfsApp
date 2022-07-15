// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class VehicleScreen extends StatefulWidget {
  final String id;
  const VehicleScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen>
    with TickerProviderStateMixin {
  bool isLoading = false;
  String? ageGroup;
  final _formKey = GlobalKey<FormState>();
  String? noTourist;
  String? comment;
  String? noOfVehicle;
  String? regtypeval;
  String? vehiclecapVal;

  String? country;
  final List<Tab> tabs = <Tab>[
    const Tab(text: "Vehicles"),
    const Tab(text: "Add Vehicle Detail(s)"),
  ];

  List<String> regType = [
    'Local',
    'Foreign',
  ];

  List<String> vehicleCapacity = [
    'Up to 2000Kg',
    '2001 - 7000Kg',
    '7001Kg and above'
  ];
  late AnimationController loadingController;

  TabController? _tabController;
  List Data = [];
  List data1 = [];

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  Future getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/safari_vehicles/${widget.id}');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      // //print(response.statusCode);
      // //print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////print(res);
            Data = res["data"];
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

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
    loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });

    getData();
  }

  @override
  Widget build(BuildContext context) {
    ////print(_tabController!.index.toString());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Vehicle Details',
          style: TextStyle(
              fontSize: 10.sp, fontFamily: "Ubuntu", color: Colors.white),
        ),
        bottom: TabBar(
          isScrollable: true,
          unselectedLabelColor: Colors.white,
          labelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: const BubbleTabIndicator(
            indicatorHeight: 25.0,
            indicatorColor: Colors.blue,
            tabBarIndicatorSize: TabBarIndicatorSize.tab,
            // Other flags
            // indicatorRadius: 1,
            // insets: EdgeInsets.all(1),
            // padding: EdgeInsets.all(10)
          ),
          tabs: tabs,
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((Tab tab) {
          return SingleChildScrollView(
              child: tab.text == "Vehicles" ? listMember() : membersForm());
        }).toList(),
      ),
    );
  }

  Future deleteData(id) async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/safari_vehicles/destroy/$id');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      // //print(response.statusCode);
      // //print(response.body);
      switch (response.statusCode) {
        case 200:
          res = json.decode(response.body);
          if (res["success"]) {
            setState(() {
              refreshScreen();
              ////print(res);
            });
          }

          return 'success';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////print(res);
          });

          break;
      }
    } catch (e) {
      return 'fail';
    }
  }

  messages(String hint, String message, {int? index, bool? isdelMessage}) {
    return Alert(
      context: context,
      type: hint == "info" ? AlertType.info : AlertType.success,
      title: "Information",
      desc: message,
      buttons: [
        DialogButton(
          onPressed: () async {
            Navigator.pop(context);
            await deleteData(index);
          },
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        DialogButton(
          color: Colors.red,
          onPressed: () async {
            Navigator.pop(context);
          },
          width: 120,
          child: const Text(
            "Cancel",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).show();
  }

  updateTask(dataUpdate) {
    return Alert(
        context: context,
        title: "Update",
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Divider(
                thickness: 1.0,
                height: 1.0,
                color: Colors.black26,
              ),
              SizedBox(
                height: getProportionateScreenHeight(5),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: DropdownButtonFormField<String>(
                  itemHeight: 50,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(
                          color: Colors.cyan,
                        ),
                      ),
                      fillColor: const Color(0xfff3f3f4),
                      filled: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                      labelText: "Weight Category",
                      border: InputBorder.none),
                  isExpanded: true,

                  value: vehiclecapVal,
                  //elevation: 5,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Ubuntu'),
                  iconEnabledColor: Colors.black,
                  items: vehicleCapacity
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xfff3f3f4),
                          border: Border(
                            bottom: BorderSide(width: 1, color: kPrimaryColor),
                          ),
                        ),
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return "This Field is required";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    vehiclecapVal = value;

                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: DropdownButtonFormField<String>(
                  itemHeight: 50,
                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(
                          color: Colors.cyan,
                        ),
                      ),
                      fillColor: const Color(0xfff3f3f4),
                      filled: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                      labelText: "Reg. Type",
                      border: InputBorder.none),
                  isExpanded: true,

                  value: regtypeval,
                  //elevation: 5,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Ubuntu'),
                  iconEnabledColor: Colors.black,
                  items: regType.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xfff3f3f4),
                          border: Border(
                            bottom: BorderSide(width: 1, color: kPrimaryColor),
                          ),
                        ),
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return "This Field is required";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    regtypeval = value;

                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: TextFormField(
                  initialValue: dataUpdate["no_of_vehicles"].toString(),
                  keyboardType: TextInputType.number,
                  key: const Key("name"),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                      ),
                    ),
                    fillColor: const Color(0xfff3f3f4),
                    filled: true,
                    labelText: "No Of vehicles",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "This Field Is Required";
                    return null;
                  },
                  onSaved: (value) {
                    noOfVehicle = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: TextFormField(
                  initialValue: dataUpdate["no_of_days"].toString(),
                  keyboardType: TextInputType.number,
                  key: const Key("name"),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                      ),
                    ),
                    fillColor: const Color(0xfff3f3f4),
                    filled: true,
                    labelText: "No Of Days",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "This Field Is Required";
                    return null;
                  },
                  onSaved: (value) {
                    noTourist = value!;
                  },
                ),
              ),
              const Divider(
                thickness: 1.0,
                height: 1.0,
                color: Colors.cyan,
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(context);
                await UpdateTasks(dataUpdate["id"]);
                // cardB.currentState?.expand();

              }
            },
            child: const Text(
              "Update",
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

  Future UpdateTasks(id) async {
    try {
      // //print(id);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/safari_vehicles/update');
      // //print(url);
      // //print(visitorTypes);
      final response = await http.post(
        url,
        headers: headers,
        body: {
          "id": id.toString(),
          "safari_id": widget.id,
          "weight_cat": vehiclecapVal,
          "reg_type": regtypeval,
          "no_of_vehicles": noOfVehicle,
          "no_of_days": noTourist
        },
      );
      var res;

      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////print(res);
          });
          if (res["success"]) {
            messages("success", "Successfully Updated");
            refreshScreen();
          } else {
            messages("error", "Something Went Wrong");
          }

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////print(res);

            isLoading = false;
          });
          messages("error", "Something Went Wrong");

          break;
      }
    } catch (e) {
      setState(() {
        //print(e);

        isLoading = false;
      });
      messages("error", "Something Went Wrong");
    }
  }

  listMember() {
    return SizedBox(
      height: getProportionateScreenHeight(650),
      child: isLoading
          ? SpinKitFadingCircle(
              color: kPrimaryColor,
              size: 35.0.sp,
            )
          : Data.isEmpty
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
              : ListView.builder(
                  itemCount: Data.length,
                  //shrinkWrap: true,
                  //scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(10),
                      vertical: getProportionateScreenHeight(10)),
                  itemBuilder: (context, index) {
                    return InkWell(
                      // onTap: () => Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => ApprovalDetails(
                      //               data: [Data[index]],
                      //             ))),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                        color: index.isEven
                                                            ? kPrimaryColor
                                                            : Colors.green[200],
                                                        thickness: 5,
                                                      )
                                                    ],
                                                  ))),
                                        )),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Weight Category: ${Data[index]["weight_cat"]}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                "Reg Type: ${Data[index]["reg_type"]}",
                                                style: TextStyle(
                                                    color: Colors.grey[500])),
                                          ]),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () async {
                                          ////print(Data[index]);
                                          await updateTask(Data[index]);
                                        },
                                        child: CircleAvatar(
                                          radius: 14.sp,
                                          backgroundColor: Colors.grey,
                                          child: Icon(
                                            Icons.edit,
                                            size: 15.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () async {
                                          messages("info",
                                              "Are You Sure You Want To Delete This Item",
                                              index: Data[index]["id"],
                                              isdelMessage: true);
                                        },
                                        child: CircleAvatar(
                                          radius: 14.sp,
                                          backgroundColor: Colors.red,
                                          child: Icon(
                                            Icons.delete,
                                            size: 15.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
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
    );
  }

  Future createTourMember() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/safari_vehicles');

      final response = await http.post(url,
          body: {
            "safari_id": widget.id,
            "weight_cat": vehiclecapVal,
            "reg_type": regtypeval,
            "no_of_vehicles": noOfVehicle,
            "no_of_days": noTourist
          },
          headers: headers);
      var res;
      //final sharedP prefs=await
      //////print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////print(res);
          });
          if (res["success"]) {
            messages("success", "Successfully Registered");
            refreshScreen();
          } else {
            messages("error", "Something Went Wrong");
          }

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////print(res);

            isLoading = false;
          });
          messages("error", "Something Went Wrong");

          break;
      }
    } catch (e) {
      setState(() {
        ////print(e);

        isLoading = false;
      });
      messages("error", "Something Went Wrong");
    }
  }

  refreshScreen() async {
    await getData();
  }

  membersForm() {
    return Form(
      key: _formKey,
      child: Card(
          elevation: 10,
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
                  child: DropdownButtonFormField<String>(
                    itemHeight: 50,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(
                            color: Colors.cyan,
                          ),
                        ),
                        fillColor: const Color(0xfff3f3f4),
                        filled: true,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(30, 10, 15, 10),
                        labelText: "Weight Category",
                        border: InputBorder.none),
                    isExpanded: true,

                    value: vehiclecapVal,
                    //elevation: 5,
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'Ubuntu'),
                    iconEnabledColor: Colors.black,
                    items: vehicleCapacity
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xfff3f3f4),
                            border: Border(
                              bottom:
                                  BorderSide(width: 1, color: kPrimaryColor),
                            ),
                          ),
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return "This Field is required";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      vehiclecapVal = value;

                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
                  child: DropdownButtonFormField<String>(
                    itemHeight: 50,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(
                            color: Colors.cyan,
                          ),
                        ),
                        fillColor: const Color(0xfff3f3f4),
                        filled: true,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(30, 10, 15, 10),
                        labelText: "Tent Type",
                        border: InputBorder.none),
                    isExpanded: true,

                    value: regtypeval,
                    //elevation: 5,
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'Ubuntu'),
                    iconEnabledColor: Colors.black,
                    items:
                        regType.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xfff3f3f4),
                            border: Border(
                              bottom:
                                  BorderSide(width: 1, color: kPrimaryColor),
                            ),
                          ),
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return "This Field is required";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      regtypeval = value;

                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  key: const Key("name"),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                      ),
                    ),
                    fillColor: const Color(0xfff3f3f4),
                    filled: true,
                    labelText: "No Of vehicles",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "This Field Is Required";
                    return null;
                  },
                  onSaved: (value) {
                    noOfVehicle = value!;
                  },
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  key: const Key("name"),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                      ),
                    ),
                    fillColor: const Color(0xfff3f3f4),
                    filled: true,
                    labelText: "No Of Days",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "This Field Is Required";
                    return null;
                  },
                  onSaved: (value) {
                    noTourist = value!;
                  },
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              _submitButton(),
              SizedBox(
                height: getProportionateScreenHeight(20),
              ),
            ],
          )),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          setState(() {
            isLoading = true;
          });

          await createTourMember();

          setState(() {
            regtypeval = null;
            vehiclecapVal = null;

            isLoading = false;
          });
          _formKey.currentState!.reset();
        }
      },
      child: isLoading
          ? const SpinKitCircle(
              color: kPrimaryColor,
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                //width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.shade200,
                          offset: const Offset(2, 4),
                          blurRadius: 5,
                          spreadRadius: 2)
                    ],
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [kPrimaryColor, Colors.green[100]!])),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
    );
  }
}
