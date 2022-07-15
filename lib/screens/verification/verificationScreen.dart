// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:tfsappv1/screens/verification/scanQr.dart';
import 'package:tfsappv1/services/constants.dart';

class VerificationScreen extends StatefulWidget {
  static String routeName = "/verification";

  const VerificationScreen({Key? key}) : super(key: key);
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    // final String arguments = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
        backgroundColor: const Color(0xFFF6FBFC),
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            'Verification Of TP',
            style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
          ),
        ),
        body: const SingleChildScrollView(
            child: ScanQr(
          role: '',
        )));
  }
}
