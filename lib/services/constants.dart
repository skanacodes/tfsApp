import 'package:flutter/material.dart';
import 'package:tfsappv1/services/size_config.dart';

textField(
  String? hint,
  String textType,
) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, right: 16, left: 16),
    child: Container(
      child: TextFormField(
        keyboardType: TextInputType.number,
        key: Key("No"),
        onSaved: (val) => hint = val!,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.cyan,
            ),
          ),
          fillColor: Color(0xfff3f3f4),
          filled: true,
          labelText: "No. Of Pieces",
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(30, 10, 15, 10),
        ),
        validator: (value) {
          if (value == '') return "This Field Is Required";
          return null;
        },
      ),
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

const kAnimationDuration = Duration(milliseconds: 200);
var baseUrl = "https://mis.tfs.go.tz/fremis";
final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

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
    borderSide: BorderSide(color: Colors.cyan),
  );
}
