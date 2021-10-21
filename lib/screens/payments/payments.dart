import 'package:flutter/material.dart';
import 'package:tfsappv1/screens/payments/paymentwidget.dart';
import 'package:tfsappv1/services/constants.dart';

class Payments extends StatelessWidget {
  static String routeName = "/payment";
  const Payments({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' Payment',
          style: TextStyle(color: Colors.black, fontFamily: 'ubuntu'),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(child: PaymentWidget()),
    );
  }
}
