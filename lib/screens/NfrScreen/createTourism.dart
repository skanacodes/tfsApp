// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, prefer_typing_uninitialized_variables, duplicate_ignore

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class CreateTourism extends StatefulWidget {
  static String routeName = "/createTourismscreen";
  const CreateTourism({Key? key}) : super(key: key);

  @override
  State<CreateTourism> createState() => _CreateTourismState();
}

class _CreateTourismState extends State<CreateTourism> {
  bool isLoading = false;
  String? isGroupVal;
  String? groupname;
  String? leadername;
  String? phoneNo;
  String? noOfTourist;
  String? desc;
  List<String> isGroup = [
    'Yes',
    'No',
  ];

  final _formKey = GlobalKey<FormState>();

  //DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String formattedDate1 = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    //print(picked);
    setState(() {
      formattedDate = DateFormat('yyyy-MM-dd').format(picked!);
    });
    return picked;
  }

  Future<DateTime?> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    //print(picked);
    setState(() {
      formattedDate1 = DateFormat('yyyy-MM-dd').format(picked!);
    });
    return picked;
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
            text: ' Regi',
            style: GoogleFonts.portLligatSans(
              //  textStyle: Theme.of(context).textTheme.bodyText1,
              fontSize: 15.0.sp,
              fontWeight: FontWeight.w700,
              color: kPrimaryColor,
            ),
            children: [
              TextSpan(
                text: 'ster',
                style: TextStyle(
                  color: Colors.green[400],
                  fontSize: 15.0.sp,
                ),
              ),
              TextSpan(
                text: ' Safari',
                style: TextStyle(
                  color: Colors.green[200],
                  fontSize: 15.0.sp,
                ),
              ),
            ]),
      ),
    );
  }

  Future addSafari() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {
        "Authorization": "Bearer ${tokens!}",
        "Accept": "application/json",
        "content-type": "application/json",
      };
      var url = Uri.parse('$baseUrlTest/api/v1/safari_info/store');

      final response = await http.post(url,
          body: json.encode({
            "is_group": isGroupVal.toString(),
            "group_name": groupname,
            "leader_name": leadername,
            "phone_no": phoneNo.toString(),
            "no_of_tourist": noOfTourist.toString(),
            "safari_start_date": formattedDate.toString(),
            "safari_end_date": formattedDate1.toString(),
            "description": desc.toString()
          }),
          headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            //print(res);
          });
          if (res["success"]) {
            messages("success", "Successfully Registered");
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
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
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
          onPressed: () {
            if (type == 'success') {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          setState(() {
            isLoading = true;
          });
          //print(isGroupVal);
          //print(groupname);
          //print(phoneNo);
          //print(noOfTourist);
          //print(formattedDate);
          //print(formattedDate1);
          //print(desc);
          await addSafari();
          setState(() {
            isLoading = false;
          });
          _formKey.currentState!.reset();
        }
      },
      child: isLoading
          ? const SpinKitCircle(
              color: kPrimaryColor,
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 15),
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
    );
  }

  @override
  void initState() {
    // getDetails();

    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)!.settings.arguments as GradingArguments;

    // //print(args.personId);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          ' ',
          style: TextStyle(
              fontFamily: 'Ubuntu', color: Colors.black, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: getProportionateScreenHeight(700),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: getProportionateScreenHeight(110),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: getProportionateScreenHeight(60),
                          decoration: const BoxDecoration(
                            // borderRadius: BorderRadius.only(
                            //     bottomLeft: Radius.circular(100),
                            //     bottomRight: Radius.circular(100)),
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
                                  trailing: const Icon(
                                      Icons.document_scanner_rounded),
                                  leading: const CircleAvatar(
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
                  // Adding the form here
                  forms()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  forms() {
    ////print(deviceInfo["imeiSim2"].toString());
    return
        // Adding the form here
        Form(
      key: _formKey,
      child: Expanded(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
              child: Card(
                elevation: 10,
                shadowColor: kPrimaryColor,
                child: Column(
                  children: <Widget>[
                    SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 10, left: 10),
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
                              labelText: "Is Group ?",
                              border: InputBorder.none),
                          isExpanded: true,

                          // value: isGroupVal,
                          //elevation: 5,
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'Ubuntu'),
                          iconEnabledColor: Colors.black,
                          items: isGroup
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem(
                              value: value,
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
                            setState(() {
                              value == "Yes"
                                  ? isGroupVal = "1"
                                  : isGroupVal = "0";
                              FocusScope.of(context).requestFocus(FocusNode());
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    isGroupVal == "1"
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 5, right: 10, left: 10),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
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
                                labelText: "Group Name",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(30, 10, 15, 10),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "This Field Is Required";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                groupname = value;
                              },
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                                top: 5, right: 10, left: 10),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
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
                                labelText: "Leader Name",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(30, 10, 15, 10),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "This Field Is Required";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                leadername = value;
                              },
                            ),
                          ),
                    SizedBox(
                      height: getProportionateScreenHeight(5),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 5, right: 10, left: 10),
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
                          labelText: "Phone Number",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(30, 10, 15, 10),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "This Field Is Required";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          phoneNo = value;
                        },
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(5),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 5, right: 10, left: 10),
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
                          labelText: "Number of Tourist",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(30, 10, 15, 10),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "This Field Is Required";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          noOfTourist = value;
                        },
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(5),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 5, right: 16, left: 16),
                      child: Card(
                        elevation: 5,
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            child: Icon(Icons.calendar_today),
                          ),
                          onTap: () {
                            _selectDate(context);
                          },
                          title: Text(
                            'Start Date: $formattedDate',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16, left: 16),
                      child: Card(
                        elevation: 5,
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            child: Icon(Icons.calendar_today),
                          ),
                          onTap: () {
                            _selectDate1(context);
                          },
                          title: Text(
                            'End Date: $formattedDate1',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 10, left: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        key: const Key("name"),
                        maxLines: 4,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.cyan,
                            ),
                          ),
                          fillColor: const Color(0xfff3f3f4),
                          filled: true,
                          labelText: "Description",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(30, 10, 15, 10),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "This Field Is Required";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          desc = value;
                        },
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _submitButton(),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(30),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
