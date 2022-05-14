// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tfsappv1/services/size_config.dart';

class TPApproval extends StatefulWidget {
  const TPApproval({Key? key}) : super(key: key);

  @override
  State<TPApproval> createState() => _TPApprovalState();
}

class _TPApprovalState extends State<TPApproval> {
  String result = "";

  List billData = [];
  String? desc;
  double? unitAmount;
  String? gfcCode;
  bool isVerify = false;

  bool isLoading = false;
  bool isCustomerSelected = false;
  bool isCustomerRegistered = false;
  String? customerName;
  String? email;
  String? customerId;
  List<int> stationIds = [];

  bool isNewCustomer = false;
  int quantity = 1;

  String? fullname;
  String? mobileNumber;

  List<int> quantities = [];


  


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

  List? beeProduct;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: forms(),
    );
  }

  forms() {
    return SingleChildScrollView(
        child: Column(children: [
      Container(
        height: getProportionateScreenHeight(800),
      ),
    ]));
  }
}
