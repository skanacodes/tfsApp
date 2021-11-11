import 'package:tfsappv1/screens/ExportImport/InspectionForm.dart';
import 'package:tfsappv1/screens/ExportImport/grading.dart';
import 'package:tfsappv1/screens/ExportImport/permitList.dart';
import 'package:tfsappv1/screens/ExportImport/sealScreen.dart';
import 'package:tfsappv1/screens/POSmanagement/posRegistration.dart';
import 'package:tfsappv1/screens/dashboard/dashboardScreen.dart';
import 'package:tfsappv1/screens/login/login.dart';
import 'package:tfsappv1/screens/otp/otp.dart';
import 'package:tfsappv1/screens/payments/billForm.dart';
import 'package:tfsappv1/screens/payments/paymentList.dart';
import 'package:tfsappv1/screens/payments/payments.dart';
import 'package:tfsappv1/screens/payments/servicesBills.dart';

import 'package:tfsappv1/screens/splash/splashscreen.dart';
import 'package:flutter/widgets.dart';
import 'package:tfsappv1/screens/verification/verificationScreen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  DashboardScreen.routeName: (context) => DashboardScreen(),
  BillForm.routeName: (context) => BillForm(),
  ServiceBills.routeName: (context) => ServiceBills(),
  Payments.routeName: (context) => Payments(),
  PaymentList.routeName: (context) => PaymentList(),
  PermittList.routeName: (context) => PermittList(),
  VerificationScreen.routeName: (context) => VerificationScreen(),
  Grading.routeName: (context) => Grading(),
  InspectionForm.routeName: (context) => InspectionForm(),
  SealScreen.routeName: (context) => SealScreen(''),
  PosReg.routeName: (context) => PosReg(),
  Otp.routeName: (context) => Otp()
};
