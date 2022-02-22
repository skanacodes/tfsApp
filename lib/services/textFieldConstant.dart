import 'package:flutter/material.dart';

class TextFieldConstant extends StatelessWidget {
  final TextEditingController? textName;
  final String? hintText;
  final String? suffixIcons;
  final String? textValue;
  final bool enabled;
  TextFieldConstant(
      {required this.textName,
      this.hintText,
      this.suffixIcons,
      this.textValue,
      required this.enabled});

  @override
  Widget build(BuildContext context) {
    return enabled
        ? Padding(
            padding: const EdgeInsets.only(top: 10, right: 16, left: 16),
            child: Container(
              child: TextFormField(
                controller: textName,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                    ),
                  ),
                  fillColor: Color(0xfff3f3f4),
                  filled: true,
                  labelText: hintText,
                  border: InputBorder.none,
                  isDense: true,
                  enabled: enabled == true ? true : false,
                  contentPadding: EdgeInsets.fromLTRB(30, 10, 15, 10),
                ),
                validator: (value) {
                  if (value == '') return "This Field Is Required";
                  return null;
                },
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 10, right: 16, left: 16),
            child: Container(
              child: TextFormField(
                // controller: textName,
                initialValue: textValue,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                    ),
                  ),
                  fillColor: Color(0xfff3f3f4),
                  filled: true,
                  labelText: hintText,
                  labelStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                  isDense: true,
                  enabled: false,
                  contentPadding: EdgeInsets.fromLTRB(30, 10, 15, 10),
                ),
              ),
            ),
          );
  }
}
