// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class ImageScreen extends StatefulWidget {
  static String routeName = "/imagescreen";
  final int index;
  final String checkpointname;
  const ImageScreen({required this.index, required this.checkpointname});
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Image',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: kPrimaryColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: getProportionateScreenHeight(20),
              ),
              Text('Image Taken At ${widget.checkpointname} Checkpoint'),
              SizedBox(
                height: getProportionateScreenHeight(20),
              ),
              Center(
                child: SizedBox(
                  height: getProportionateScreenHeight(400),
                  child: Hero(
                      tag: "avatar-1",
                      child: SvgPicture.asset(
                        'assets/icons/addpic.svg',
                        fit: BoxFit.contain,
                      )),
                ),
              ),
            ],
          ),
        ));
  }
}
