// ignore_for_file: avoid_print, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/countrymodal.dart';
import 'package:tfsappv1/services/size_config.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen>
    with TickerProviderStateMixin {
  bool isLoading = false;
  String? ageGroup;
  final _formKey = GlobalKey<FormState>();
  String? noTourist;
  String? noDays;
  String? comment;
  String? tourCat;
  final _countryTextController = TextEditingController();
  String? country;
  final List<Tab> tabs = <Tab>[
    const Tab(text: "Members List"),
    const Tab(text: "Add Member(s)"),
  ];
  List<String> touristCategory = ['East African', 'Resident', 'Non Resident'];
  late AnimationController loadingController;

  TabController? _tabController;
  List Data = [];
  List data1 = [];
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

  Future deleteData(id) async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/safari_member/destroy/$id');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      // print(response.statusCode);
      // print(response.body);
      switch (response.statusCode) {
        case 200:
          res = json.decode(response.body);
          if (res["success"]) {
            setState(() {
              refreshScreen();
              //print(res);
            });
          }

          return 'success';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);
          });

          break;
      }
    } catch (e) {
      return 'fail';
    }
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
                      labelText: "Country Type",
                      border: InputBorder.none),
                  isExpanded: true,

                  value: tourCat,
                  //elevation: 5,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Ubuntu'),
                  iconEnabledColor: Colors.black,
                  items: touristCategory
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
                    tourCat = value;

                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: SafeArea(
                  child: data1.isEmpty
                      ? SpinKitFadingCircle(
                          color: kPrimaryColor,
                          size: 35.0.sp,
                        )
                      : DropdownButtonFormField(
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
                              labelText: "Select Age Group",
                              border: InputBorder.none),
                          isExpanded: true,
                          isDense: true,
                          validator: (value) =>
                              value == null ? "This Field is Required" : null,
                          items: data1.map((item) {
                            return DropdownMenuItem(
                              value: item['id'].toString(),
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xfff3f3f4),
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: kPrimaryColor),
                                  ),
                                ),
                                child: Text(
                                  item['name'].toString(),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            setState(() {
                              ageGroup = newVal.toString();
                              //print(ageGroup);
                            });
                          },
                          value: ageGroup,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: DropdownSearch<CountryModal>(
                  // showSelectedItem: true,
                  showSearchBox: true,
                  validator: (v) => v == null ? "This Field Is required" : null,
                  popupTitle: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      'List Of Country',
                    )),
                  ),
                  searchFieldProps: TextFieldProps(
                    controller: _countryTextController,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.cyan,
                          ),
                        ),
                        fillColor: const Color(0xfff3f3f4),
                        filled: true,
                        labelText: "Search",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(30, 10, 15, 10),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          color: Colors.red,
                          onPressed: () {
                            _countryTextController.clear();
                          },
                        )),
                  ),
                  mode: Mode.BOTTOM_SHEET,
                  popupElevation: 20,

                  dropdownSearchDecoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(
                          color: Colors.cyan,
                        ),
                      ),
                      fillColor: const Color(0xfff3f3f4),
                      filled: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(30, 5, 10, 5),
                      hintText: "Select Country",
                      border: InputBorder.none),
                  compareFn: (i, s) => i!.isEqual(s),

                  onFind: (filter) => getDataCountry(
                    filter,
                  ),

                  onChanged: (data) {
                    setState(() {
                      country = data!.name;
                    });
                  },

                  popupItemBuilder: _customPopupItemBuilderCountry,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: TextFormField(
                  initialValue: dataUpdate["no_of_tourist"].toString(),
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
                    labelText: "No. Of Tourist",
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
                    labelText: "No. Of Days",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "This Field Is Required";
                    return null;
                  },
                  onSaved: (value) {
                    noDays = value!;
                  },
                ),
              ),
              const SizedBox(
                height: 10,
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
      // print(id);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/safari_member/update');
      // print(url);
      // print(visitorTypes);
      final response = await http.post(
        url,
        headers: headers,
        body: {
          "id": id.toString(),
          "safari_id": widget.id,
          "country_group": tourCat,
          "age_group_id": ageGroup,
          "country_name": country,
          "no_of_tourist": noTourist,
          "no_of_days": noDays,
        },
      );
      var res;

      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
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
            //print(res);

            isLoading = false;
          });
          messages("error", "Something Went Wrong");

          break;
      }
    } catch (e) {
      setState(() {
        print(e);

        isLoading = false;
      });
      messages("error", "Something Went Wrong");
    }
  }

  Future getAgeGroups() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrlTest/api/v1/age_group');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      //print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            data1 = res['data'];
            //print(res);
          });
          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            //print(res);
          });
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            //print(res);
          });
          break;
      }
    } on SocketException {
      setState(() {
        //print(res);
      });
    }
  }

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
      var url = Uri.parse('$baseUrlTest/api/v1/safari_member/${widget.id}');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
            Data = res["data"];

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
    getAgeGroups();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    //print(_tabController!.index.toString());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Safari Members Details',
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
              child: tab.text == "Members List" ? listMember() : membersForm());
        }).toList(),
      ),
    );
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
                                            const Text("Age Group: Defined",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                "No Of Tourist: ${Data[index]["no_of_tourist"]}",
                                                style: TextStyle(
                                                    color: Colors.grey[500])),
                                          ]),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () async {
                                          //print(Data[index]);
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
      var url = Uri.parse('$baseUrlTest/api/v1/safari_member');
      //print(widget.id);
      final response = await http.post(url,
          body: {
            "safari_id": widget.id,
            "country_group": tourCat,
            "age_group_id": ageGroup,
            "country_name": country,
            "no_of_tourist": noTourist,
            "no_of_days": noDays
          },
          headers: headers);
      var res;
      //final sharedP prefs=await
      ////print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
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
            //print(res);

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
                        labelText: "Country Type",
                        border: InputBorder.none),
                    isExpanded: true,

                    value: tourCat,
                    //elevation: 5,
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'Ubuntu'),
                    iconEnabledColor: Colors.black,
                    items: touristCategory
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
                      tourCat = value;

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
                child: SafeArea(
                  child: data1.isEmpty
                      ? SpinKitFadingCircle(
                          color: kPrimaryColor,
                          size: 35.0.sp,
                        )
                      : DropdownButtonFormField(
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
                              labelText: "Select Age Group",
                              border: InputBorder.none),
                          isExpanded: true,
                          isDense: true,
                          validator: (value) =>
                              value == null ? "This Field is Required" : null,
                          items: data1.map((item) {
                            return DropdownMenuItem(
                              value: item['id'].toString(),
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xfff3f3f4),
                                  border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: kPrimaryColor),
                                  ),
                                ),
                                child: Text(
                                  item['name'].toString(),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            setState(() {
                              ageGroup = newVal.toString();
                              //print(ageGroup);
                            });
                          },
                          value: ageGroup,
                        ),
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
                child: DropdownSearch<CountryModal>(
                  // showSelectedItem: true,
                  showSearchBox: true,
                  validator: (v) => v == null ? "This Field Is required" : null,
                  popupTitle: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      'List Of Country',
                    )),
                  ),
                  searchFieldProps: TextFieldProps(
                    controller: _countryTextController,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.cyan,
                          ),
                        ),
                        fillColor: const Color(0xfff3f3f4),
                        filled: true,
                        labelText: "Search",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(30, 10, 15, 10),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          color: Colors.red,
                          onPressed: () {
                            _countryTextController.clear();
                          },
                        )),
                  ),
                  mode: Mode.BOTTOM_SHEET,
                  popupElevation: 20,

                  dropdownSearchDecoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(
                          color: Colors.cyan,
                        ),
                      ),
                      fillColor: const Color(0xfff3f3f4),
                      filled: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(30, 5, 10, 5),
                      hintText: "Select Country",
                      border: InputBorder.none),
                  compareFn: (i, s) => i!.isEqual(s),

                  onFind: (filter) => getDataCountry(
                    filter,
                  ),

                  onChanged: (data) {
                    setState(() {
                      country = data!.name;
                    });
                  },

                  popupItemBuilder: _customPopupItemBuilderCountry,
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
                    labelText: "No. Of Tourist",
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
                    labelText: "No. Of Days",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "This Field Is Required";
                    return null;
                  },
                  onSaved: (value) {
                    noDays = value!;
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
            tourCat = null;
            ageGroup = null;
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

  Future<List<CountryModal>> getDataCountry(filter) async {
    var url;
    // var headers = {"Authorization": "Bearer " + widget.token};
    url = "$baseUrlTest/api/v1/countries";
    var response = await Dio().get(
      url,
      queryParameters: {"filter": filter},
    );

    final data = response.data;
    //print(data);
    //print(data['countries']);
    if (data != null) {
      setState(() {
        // datas = data[];
      });
      return CountryModal.fromJsonList(data['countries']);
    }

    return [];
  }

  Widget _customPopupItemBuilderCountry(
      BuildContext context, CountryModal item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: kPrimaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: Card(
        elevation: 5,
        child: ListTile(
          selected: isSelected,
          title: Text(item.name),
          subtitle: Text("Country Code: ${item.id}"),
          tileColor: const Color(0xfff3f3f4),
          leading: IntrinsicHeight(
              child: SizedBox(
                  height: double.maxFinite,
                  width: getProportionateScreenHeight(50),
                  child: Row(
                    children: [
                      VerticalDivider(
                        color: Colors.green[200],
                        thickness: 5,
                      )
                    ],
                  ))),
        ),
      ),
    );
  }
}
