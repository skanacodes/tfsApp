// ignore_for_file: unused_field, avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class IllegalProductScreen extends StatefulWidget {
  static String routeName = "/illigalProductBills";
  const IllegalProductScreen({Key? key}) : super(key: key);

  @override
  _IllegalProductScreenState createState() => _IllegalProductScreenState();
}

class _IllegalProductScreenState extends State<IllegalProductScreen> {
  TextEditingController? _vesselNoController;
  TextEditingController? _productTypeController;
  TextEditingController? _locationController;
  TextEditingController? _offenceDetailsController;
  TextEditingController? _typeOfIntervetionByController;
  TextEditingController? _remarksController;

  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  int currentStep = 0;
  bool complete = false;

  int _radioValue = 0;
  int _radioValue1 = 0;
  bool isStepOneComplete = false;
  bool isStepTwoComplete = false;
  bool isStepThreeComplete = false;
  bool showPermitType = false;
  String? type;
  int upperBound = 6; // upperBound MUST BE total number of icons minus 1.
  List<String> vehicleInvolved = ['Yes', 'No'];
  bool isVehicle = false;
  String? vehicleStatus;

  _biuldTextField(variable, String? label, String? keybordType) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 16, left: 16),
      child: TextFormField(
        controller: variable,
        keyboardType:
            keybordType == "text" ? TextInputType.text : TextInputType.number,
        key: Key(label!),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Colors.cyan,
            ),
          ),
          fillColor: const Color(0xfff3f3f4),
          filled: true,
          labelText: label,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
        ),
        validator: (value) {
          if (value!.isEmpty) return "This Field Is Required";
          return null;
        },
      ),
    );
  }

  next() {
    print(currentStep);
    if (currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          isStepOneComplete = true;
        });
        _formKey.currentState!.save();
        currentStep + 1 != stepp().length
            ? goTo(currentStep + 1)
            : setState(() => complete = true);
      } else {
        setState(() {
          isStepOneComplete = false;
        });
      }
    } else if (currentStep == 1) {
      setState(() {
        isStepTwoComplete = true;
      });
      currentStep + 1 != stepp().length
          ? goTo(currentStep + 1)
          : setState(() => complete = true);
    } else {
      setState(() {
        isStepThreeComplete = true;
      });
      currentStep + 1 != stepp().length
          ? goTo(currentStep + 1)
          : setState(() => complete = true);
    }
  }

  void _handleRadioValueChange(var value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
          setState(() {
            showPermitType = true;
          });
          break;
        case 1:
          setState(() {
            showPermitType = false;
            _handleRadioValueChange1(0);
          });
          break;
      }
    });
  }

  void _handleRadioValueChange1(var value) {
    setState(() {
      _radioValue1 = value;

      switch (_radioValue1) {
        case 0:
          setState(() {
            showPermitType = true;
          });
          break;
        case 1:
          setState(() {
            showPermitType = false;
          });
          break;
      }
    });
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  final List<DropdownMenuItem<String>> _permitType = [
    const DropdownMenuItem(
      value: "Export",
      child: Text("Export"),
    ),
    const DropdownMenuItem(
      value: "Import",
      child: Text("Import"),
    ),
    const DropdownMenuItem(
      value: "Internal Market",
      child: Text("Internal Market"),
    ),
  ];
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
                  SafeArea(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
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
                            labelText: "Is Transportation Vessel Involved?",
                            border: InputBorder.none),
                        isExpanded: true,

                        value: vehicleStatus,
                        //elevation: 5,
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'Ubuntu'),
                        iconEnabledColor: Colors.black,
                        items: vehicleInvolved
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
                            FocusScope.of(context)
                                .requestFocus(FocusNode());
                            vehicleStatus = value!;
                            vehicleStatus == "Yes"
                                ? isVehicle = true
                                : isVehicle = false;
                            // print(typeSeed);
                          });
                        },
                      ),
                    ),
                  ),
                  vehicleStatus == "Yes"
                      ? _biuldTextField(
                          _vesselNoController, "Vessel No", "text")
                      : Container(),
                  vehicleStatus == "Yes"
                      ? _biuldTextField(
                          _productTypeController, "Product Type", "text")
                      : Container(),
                  vehicleStatus == "Yes"
                      ? SizedBox(
                          height: getProportionateScreenHeight(10),
                        )
                      : Container(),
                  vehicleStatus == "Yes"
                      ? _biuldTextField(_locationController, "Location", "text")
                      : Container(),
                  vehicleStatus == "Yes"
                      ? SizedBox(
                          height: getProportionateScreenHeight(10),
                        )
                      : Container(),
                  vehicleStatus == "Yes"
                      ? _biuldTextField(
                          _offenceDetailsController, "Offence Details", "text")
                      : Container(),
                  SizedBox(
                    height: getProportionateScreenHeight(10),
                  ),
                  vehicleStatus == "No"
                      ? _biuldTextField(_typeOfIntervetionByController,
                          "Type Of Intervation", "text")
                      : Container(),
                  vehicleStatus == "No"
                      ? SizedBox(
                          height: getProportionateScreenHeight(10),
                        )
                      : Container(),
                  vehicleStatus == "No"
                      ? _biuldTextField(_remarksController, "Remarks", "text")
                      : Container(),
                  SizedBox(
                    height: getProportionateScreenHeight(10),
                  ),
                ],
              )),
        ),
      ),
      Step(
        isActive: isStepTwoComplete ? true : false,
        state: isStepTwoComplete ? StepState.complete : StepState.indexed,
        title: const Text('Payment'),
        content: Card(
          child: Column(
            children: <Widget>[
              _biuldTextField(_vesselNoController, "Vessel No", "text"),
              _biuldTextField(_vesselNoController, "Vessel No", "text"),
              _biuldTextField(_vesselNoController, "Vessel No", "text"),
              SizedBox(
                height: getProportionateScreenHeight(10),
              )
            ],
          ),
        ),
      ),
      Step(
        isActive: isStepThreeComplete ? true : false,
        state: isStepThreeComplete ? StepState.complete : StepState.indexed,
        title: const Text('Inspection'),
        subtitle: type == 'Export'
            ? const Text('Export')
            : type == 'Import'
                ? const Text('Import')
                : type == 'Import'
                    ? const Text('Internal Market')
                    : const Text(''),
        content: vehicleStatus == "Yes"
            ? _biuldTextField(_vesselNoController, "Vessel No", "text")
            : Container(),
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
  void initState() {
    // ignore: todo
    // TODO: implement initState
    _handleRadioValueChange(0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: switchStepType,
          child: const Icon(Icons.list),
        ),
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            'Offences Management',
            style: TextStyle(
                fontFamily: 'Ubuntu', color: Colors.black, fontSize: 15),
          ),
        ),
        body: Column(children: <Widget>[
          Expanded(
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
}



  /// Returns the next button.
