import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfsappv1/services/size_config.dart';

textField(
  String? hint,
  String textType,
) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, right: 16, left: 16),
    child: TextFormField(
      keyboardType: TextInputType.number,
      key: const Key("No"),
      onSaved: (val) => hint = val!,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.cyan,
          ),
        ),
        fillColor: const Color(0xfff3f3f4),
        filled: true,
        labelText: "No. Of Pieces",
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
      ),
      validator: (value) {
        if (value == '') return "This Field Is Required";
        return null;
      },
    ),
  );
}

const kPrimaryColor = Color(0xFF0C9869);
const kPrimaryLightColor = Color(0xFF960000);
// const kPrimaryGradientColor = LinearGradient(
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
//   colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
// );
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);
Color kLinearOne = const Color(0xffffb507);
Color kLinearTwo = const Color(0xfffb2a02);
Color kPercentUp = const Color(0xff00fbd3);
Color kPercentDown = const Color(0xffff8484);
Color kGradientColorOne = const Color.fromARGB(255, 249, 241, 16);
Color kGradientColorTwo = const Color.fromARGB(255, 4, 127, 41);

const kAnimationDuration = Duration(milliseconds: 200);
// var baseUrl = "https://mis.tfs.go.tz/fremis";
// var baseUrlTest = "https://mis.tfs.go.tz/fremis";
// var baseUrlSeed = "https://mis.tfs.go.tz/seed-mis";
// var baseUrlPMIS = "https://mis.tfs.go.tz/pmis";
// var baseUrlHoneyTraceability = "https://mis.tfs.go.tz/honey-traceability";
var baseUrl = "http://41.59.227.103:8083";

//var baseUrl = "http://41.59.82.189:8080/fremis-test";
var baseUrlTest = "http://41.59.227.103:8083";
var baseUrlSeed = "http://41.59.227.103:8081";
var baseUrlPMIS = "https://mis.tfs.go.tz/pmis";
//var baseUrlHoneyTraceability = "http://41.59.228.113/honey-traceability";
var baseUrlHoneyTraceability = "http://41.59.82.189:8080/honey-traceability";
String filepathImages = "assets/images/";
String filepathIcons = "assets/icons/";
final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);
final formatNumber = NumberFormat("#,##0.00", "en_US");
const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: const BorderSide(color: Colors.cyan),
  );
}

TextStyle kSFUI16 = const TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: kTextColor,
);

TextStyle kName = const TextStyle(
  fontSize: 27,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

TextStyle kBalance = const TextStyle(
  fontSize: 37,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

TextStyle kPercent = const TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w500,
);

TextStyle kSectionTitle = const TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

TextStyle kCardNumber = const TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kTextColor,
);

TextStyle kCardHolder = const TextStyle(
  // fontFamily: 'Inter',
  fontSize: 9,
  fontWeight: FontWeight.w400,
  color: Colors.white30,
);

TextStyle kCardName = const TextStyle(
//  fontFamily: 'Inter',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kTextColor,
);

TextStyle kInfo = const TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w500,
  color: kTextColor,
);
