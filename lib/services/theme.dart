import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Ubuntu',
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    inputDecorationTheme: inputDecorationTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

InputDecorationTheme inputDecorationTheme() {
  // OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  //   // borderRadius: BorderRadius.circular(10),
  //   // borderSide: BorderSide(color: kTextColor),
  //   gapPadding: 10,
  // );
  return const InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    // enabledBorder: outlineInputBorder,
    // focusedBorder: outlineInputBorder,
    // border: outlineInputBorder,
  );
}

TextTheme textTheme() {
  return const TextTheme(
    bodyText1: TextStyle(color: kTextColor),
    bodyText2: TextStyle(color: kTextColor),
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: Colors.white,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    toolbarTextStyle: const TextTheme(
      headline6: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    ).bodyText2,
    titleTextStyle: const TextTheme(
      headline6: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    ).headline6,
  );
}
