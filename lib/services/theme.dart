import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'constants.dart';

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Port Lligat Slab',
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
    color: kPrimaryColor,
    textTheme:
        const TextTheme(titleMedium: TextStyle(fontFamily: "Port Lligat Slab")),
    elevation: 0,
    systemOverlayStyle:
        const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 12.sp, fontFamily: "Port Lligat Slab"),
    toolbarTextStyle: TextStyle(
        color: Colors.white, fontSize: 12.sp, fontFamily: "Port Lligat Slab"),
  );
}
