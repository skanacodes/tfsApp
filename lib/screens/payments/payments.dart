import 'package:flutter/material.dart';
import 'package:tfsappv1/screens/payments/paymentwidget.dart';
import 'package:tfsappv1/services/constants.dart';

class Payments extends StatelessWidget {
  static String routeName = "/payment";
  const Payments({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        title: const Text(
          ' Bill/Receipt',
          style: TextStyle(
              color: Colors.black, fontFamily: 'ubuntu', fontSize: 17),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: const SingleChildScrollView(child: PaymentWidget()),
    );
  }
}
