// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, prefer_typing_uninitialized_variables, duplicate_ignore

import 'dart:convert';
import 'dart:io';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/countrymodal.dart';
import 'package:tfsappv1/services/modal/districtCountry.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:http/http.dart' as http;

class CreateTourism extends StatefulWidget {
  static String routeName = "/createTourismscreen";
  const CreateTourism({Key? key}) : super(key: key);

  @override
  State<CreateTourism> createState() => _CreateTourismState();
}

class _CreateTourismState extends State<CreateTourism> {
  String? phoneNo;
  String? mname;
  String? fname;
  String? lname;
  String? purpose;
  String? email;
  int? days;
  String? idNo;

  final _countryTextController = TextEditingController();
  final _DistrictTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  bool isLoading = false;
  List<String> touristCategory = [
    'East African Citizen',
    'Residents',
    'Non Residents'
  ];
  List<String> isGroup = [
    'Yes',
    'No',
  ];
  String? identity;
  String? genderVal;
  String? purposeVal;
  String? district;
  List<String> idType = [
    'Nida',
    'Passport',
    'Driving License',
  ];
  List<String> gender = [
    'Male',
    'Female',
  ];

  List<String> pupose = [
    'Leisure',
    'Research',
  ];
  bool isCitizen = false;
  bool isGroups = false;
  String? country;
  bool isSaving = false;
  List data = [];
  List data1 = [];
  String? tourCat;
  String? isGroupVal;
  String? isGroupTypeVal;
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2022),
        initialDatePickerMode: DatePickerMode.year,
        firstDate: DateTime(1920),
        lastDate: DateTime(2022),
        fieldLabelText: "Select BirthDate");
    //print(picked);
    setState(() {
      picked == null
          ? formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now())
          : formattedDate = DateFormat('yyyy-MM-dd').format(picked);
    });
    return picked;
  }

  Future getGroups() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrlTest/api/v1/tr/groups');

      final response = await http.get(url, headers: headers);
      // ignore: prefer_typing_uninitialized_variables
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            data = res['groups'];
            print(res);
          });
          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        print(res);
      });
    }
  }

  Future getPurpose() async {
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('$baseUrlTest/api/v1/tr/purpose');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            data1 = res['purposes'];
            print(res);
          });
          break;

        case 401:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          break;
        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        print(res);
      });
    }
  }

  Future<String> createTour() async {
    try {
      // print(username);
      // print(password);
      var stationId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getInt('station_id'));
      var url = Uri.parse('$baseUrlTest/api/v1/tourism/store');
      print(stationId);
      print(tourCat);
      print(country);
      print(genderVal);
      print(idNo);
      print(purposeVal);
      //print(isGroupTypeVal);
      // print(isGroupVal);
      // print(_fnameNoController!.text);

      final response = await http.post(
        url,
        body: {
          "station_id": stationId.toString(),
          "tourist_cat": tourCat,
          "country": country ?? "null",
          "gender": genderVal,
          "purpose_id": purpose,
          "is_group": isGroupVal,
          "group_type_id": isGroupTypeVal ?? "null",
          "first_name": fname,
          "days_spent": days.toString(),
          "district_id": district ?? "null",
          "phone_number": phoneNo,
          "email": email,
          "birth_date": formattedDate,
          "id_type": identity,
          "id_no": idNo,
          "middle_name": mname,
          "last_name": lname
        },
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
          });
          messages("success", "Successfully Registered");

          return 'success';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);

            isLoading = false;
          });
          messages("error", "Something Went Wrong");
          return 'fail';
          // ignore: dead_code
          break;
      }
    } catch (e) {
      setState(() {
        print(e);

        isLoading = false;
      });
      messages("error", "Something Went Wrong");

      return 'fail';
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
          child: const Text(
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

  @override
  void initState() {
    getGroups();
    getPurpose();
    // ignore: todo
    // TODO: implemdent initState
    super.initState();
  }

  int currentStep = 0;
  bool complete = false;

  bool isStepOneComplete = false;
  bool isStepTwoComplete = false;
  bool isStepThreeComplete = false;
  bool showPermitType = false;
  String? type;
  int upperBound = 6; // upperBound MUST BE total number of icons minus 1.
  List<String> vehicleInvolved = ['Yes', 'No'];
  bool isVehicle = false;
  String? vehicleStatus;

  next() async {
    print(currentStep);
    if (currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        setState(() {
          isStepOneComplete = true;
        });

        currentStep + 1 != stepp().length
            ? goTo(currentStep + 1)
            : setState(() => complete = true);
      } else {
        setState(() {
          isStepOneComplete = false;
        });
      }
    } else if (currentStep == 1) {
      if (_formKey1.currentState!.validate()) {
        _formKey1.currentState!.save();
        setState(() {
          isStepTwoComplete = true;
        });
        currentStep + 1 != stepp().length
            ? goTo(currentStep + 1)
            : setState(() => complete = true);
      }
    } else {
      if (_formKey2.currentState!.validate()) {
        _formKey2.currentState!.save();
        setState(() {
          isStepThreeComplete = true;
          isSaving = true;
        });
        await createTour();
        setState(() {
          isSaving = false;
        });

        currentStep + 1 != stepp().length
            ? goTo(currentStep + 1)
            : setState(() => complete = true);
      }
    }
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  stepp() {
    return [
      Step(
        title: const Text('Details'),
        isActive: isStepOneComplete ? true : false,
        state: isStepOneComplete ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKey,
          child: Card(
              elevation: 10,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
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
                        labelText: "First Name",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return "This Field Is Required";
                        return null;
                      },
                      onSaved: (value) {
                        fname = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
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
                        labelText: "Middle Name",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return "This Field Is Required";
                        return null;
                      },
                      onSaved: (value) {
                        mname = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
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
                        labelText: "Last Name",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return "This Field Is Required";
                        return null;
                      },
                      onSaved: (value) {
                        lname = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
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
                        contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return "This Field Is Required";
                        return null;
                      },
                      onSaved: (value) {
                        phoneNo = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
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
                        labelText: "Email",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return "This Field Is Required";
                        return null;
                      },
                      onSaved: (value) {
                        email = value;
                      },
                    ),
                  ),
                  SafeArea(
                    child: Padding(
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
                            contentPadding:
                                const EdgeInsets.fromLTRB(30, 10, 15, 10),
                            labelText: "Select Gender",
                            border: InputBorder.none),
                        isExpanded: true,

                        value: genderVal,
                        //elevation: 5,
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'Ubuntu'),
                        iconEnabledColor: Colors.black,
                        items: gender
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
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
                            value: value,
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return "This Field is required";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          genderVal = value;
                          setState(() {
                            FocusScope.of(context)
                                .requestFocus(FocusNode());
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                    child: Card(
                      elevation: 1,
                      child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.calendar_today),
                    ),
                    onTap: () {
                      _selectDate(context);
                    },
                    title: Text(
                      'BirthDate Date: $formattedDate',
                      style: const TextStyle(color: Colors.black54),
                    ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
      Step(
        isActive: isStepTwoComplete ? true : false,
        state: isStepTwoComplete ? StepState.complete : StepState.indexed,
        title: const Text('Nationality'),
        content: Card(
          child: Form(
            key: _formKey1,
            child: Column(
              children: <Widget>[
                SafeArea(
                  child: Padding(
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
                          labelText: "  ID Type",
                          border: InputBorder.none),
                      isExpanded: true,

                      value: identity,
                      //elevation: 5,
                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'Ubuntu'),
                      iconEnabledColor: Colors.black,
                      items: idType
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(
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
                          value: value,
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return "This Field is required";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        identity = value;
                        setState(() {
                          FocusScope.of(context)
                              .requestFocus(FocusNode());
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
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
                      labelText: "ID Number",
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "This Field Is Required";
                      return null;
                    },
                    onSaved: (value) {
                      idNo = value;
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
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
                          labelText: "Tourist Category",
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
                          value: value,
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
                tourCat == "East African Citizen" || tourCat == "Non Residents"
                    ? Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 5, left: 5),
                        child: DropdownSearch<CountryModal>(
                          // showSelectedItem: true,
                          showSearchBox: true,
                          validator: (v) =>
                              v == null ? "This Field Is required" : null,
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
                      )
                    : Container(),
                tourCat == "East African Citizen" &&
                        country == "Tanzania, United Republic of"
                    ? Padding(
                        padding:
                            const EdgeInsets.only(top: 5, right: 5, left: 5),
                        child: DropdownSearch<DistrictModal>(
                          // showSelectedItem: true,
                          showSearchBox: true,
                          validator: (v) =>
                              v == null ? "This Field Is required" : null,
                          popupTitle: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child: Text(
                              'List Of Districts',
                            )),
                          ),
                          searchFieldProps: TextFieldProps(
                            controller: _DistrictTextController,
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
                                    _DistrictTextController.clear();
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
                              hintText: "Select District",
                              border: InputBorder.none),
                          compareFn: (i, s) => i!.isEqual(s),

                          onFind: (filter) => getDataDistrict(
                            filter,
                          ),

                          onChanged: (data) {
                            setState(() {
                              district = data!.id;
                            });
                          },

                          popupItemBuilder: _customPopupItemBuilderDistrict,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
      Step(
        isActive: isStepThreeComplete ? true : false,
        state: isStepThreeComplete ? StepState.complete : StepState.indexed,
        title: const Text('Others'),
        content: Form(
          key: _formKey2,
          child: Column(
            children: [
              SafeArea(
                child: Padding(
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
                        labelText: "Is Group",
                        border: InputBorder.none),
                    isExpanded: true,

                    // value: isGroupVal,
                    //elevation: 5,
                    style:
                        const TextStyle(color: Colors.white, fontFamily: 'Ubuntu'),
                    iconEnabledColor: Colors.black,
                    items:
                        isGroup.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(
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
                        value: value,
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
                        value == "Yes" ? isGroupVal = "1" : isGroupVal = "0";
                        FocusScope.of(context).requestFocus(FocusNode());
                      });
                    },
                  ),
                ),
              ),
              isGroupVal == "1"
                  ? Padding(
                      padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                      child: SafeArea(
                        child: data.isEmpty
                            ? SpinKitFadingCircle(
                                color: kPrimaryColor,
                                size: 35.0.sp,
                              )
                            : DropdownButtonFormField(
                              itemHeight: 50,
                              decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  fillColor: const Color(0xfff3f3f4),
                                  filled: true,
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(30, 10, 15, 10),
                                  labelText: "Group Type",
                                  border: InputBorder.none),
                              isExpanded: true,
                              isDense: true,
                              validator: (value) => value == null
                                  ? "This Field is Required"
                                  : null,
                              items: data.map((item) {
                                return DropdownMenuItem(
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
                                  value: item['id'].toString(),
                                );
                              }).toList(),
                              onChanged: (newVal) {
                                setState(() {
                                  isGroupTypeVal = newVal.toString();
                                  print(isGroupTypeVal);
                                });
                              },
                              value: isGroupTypeVal,
                            ),
                      ),
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: TextFormField(
                  maxLength: 3,
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
                    days = int.parse(value!);
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
                            labelText: "Purpose",
                            border: InputBorder.none),
                        isExpanded: true,
                        isDense: true,
                        validator: (value) =>
                            value == null ? "This Field is Required" : null,
                        items: data1.map((item) {
                          return DropdownMenuItem(
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
                            value: item['id'].toString(),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          setState(() {
                            purpose = newVal.toString();
                            // print(isGroupTypeVal);
                          });
                        },
                        value: purpose,
                      ),
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  StepperType stepperType = StepperType.horizontal;

  switchStepType() {
    setState(() => stepperType == StepperType.horizontal
        ? stepperType = StepperType.vertical
        : stepperType = StepperType.horizontal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.list),
          onPressed: switchStepType,
        ),
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            'Create Tourism',
            style: TextStyle(
                fontFamily: 'Ubuntu', color: Colors.white, fontSize: 15),
          ),
        ),
        body: Column(children: <Widget>[
          isSaving
              ? Center(
                  child: SpinKitFadingCircle(
                    color: kPrimaryColor,
                    size: 35.0.sp,
                  ),
                )
              : Expanded(
                  child: Stepper(
                    steps: stepp(),
                    type: stepperType,
                    currentStep: currentStep,
                    onStepContinue: next,
                    onStepTapped: (step) => goTo(step),
                    onStepCancel: cancel,
                  ),
                ),
        ]));
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
          subtitle: Text("Country Code: " + item.id),
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

  Widget _customPopupItemBuilderDistrict(
      BuildContext context, DistrictModal item, bool isSelected) {
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
          //subtitle: Text("Unit Price: " + item.id),
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

  Future<List<CountryModal>> getDataCountry(filter) async {
    var url;
    // var headers = {"Authorization": "Bearer " + widget.token};
    url = "$baseUrlTest/api/v1/countries";
    var response = await Dio().get(
      url,
      queryParameters: {"filter": filter},
    );

    final data = response.data;
    print(data);
    print(data['countries']);
    if (data != null) {
      setState(() {
        // datas = data[];
      });
      return CountryModal.fromJsonList(data['countries']);
    }

    return [];
  }

  Future<List<DistrictModal>> getDataDistrict(filter) async {
    var url;
    // var headers = {"Authorization": "Bearer " + widget.token};
    url = "$baseUrlTest/api/v1/districts";
    var response = await Dio().get(
      url,
      queryParameters: {"filter": filter},
    );
    // print(response.data);
    final data = response.data;
    // print(data['districts']);
    if (data != null) {
      return DistrictModal.fromJsonList(data['districts']);
    }

    return [];
  }
}
