import 'package:tfsappv1/screens/ExportImport/InspectionForm.dart';
import 'package:tfsappv1/screens/ExportImport/grading.dart';
import 'package:tfsappv1/screens/ExportImport/permitList.dart';
import 'package:tfsappv1/screens/ExportImport/sealScreen.dart';
import 'package:tfsappv1/screens/Inventory/forestInventoryScreen.dart';
import 'package:tfsappv1/screens/NfrScreen/createTourism.dart';
import 'package:tfsappv1/screens/NfrScreen/generateQr.dart';
import 'package:tfsappv1/screens/NfrScreen/nfrScreen.dart';
import 'package:tfsappv1/screens/NfrScreen/toursList.dart';
import 'package:tfsappv1/screens/POSmanagement/posRegistration.dart';
import 'package:tfsappv1/screens/dashboard/dashboardScreen.dart';
import 'package:tfsappv1/screens/illegalproduct/illegal_product_screen.dart';
import 'package:tfsappv1/screens/login/login.dart';
import 'package:tfsappv1/screens/otp/otp.dart';
import 'package:tfsappv1/screens/payments/billForm.dart';
import 'package:tfsappv1/screens/payments/billManagement.dart';
import 'package:tfsappv1/screens/payments/billsDashboard.dart';
import 'package:tfsappv1/screens/payments/expiredBillsList.dart';
import 'package:tfsappv1/screens/payments/paymentList.dart';
import 'package:tfsappv1/screens/payments/payments.dart';
import 'package:tfsappv1/screens/payments/servicesBills.dart';
import 'package:tfsappv1/screens/payments/systemsList.dart';

import 'package:tfsappv1/screens/splash/splashscreen.dart';
import 'package:flutter/widgets.dart';
import 'package:tfsappv1/screens/updates/updates.dart';
import 'package:tfsappv1/screens/verification/expectedTpHistory.dart';
import 'package:tfsappv1/screens/verification/extensionApprovalWidget.dart';
import 'package:tfsappv1/screens/verification/extension_approvalscreen.dart';
import 'package:tfsappv1/screens/verification/tpTimeline.dart';
import 'package:tfsappv1/screens/verification/tp_editing.dart';
import 'package:tfsappv1/screens/verification/verificationScreen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  DashboardScreen.routeName: (context) => const DashboardScreen(),
  BillForm.routeName: (context) => const BillForm(),
  ServiceBills.routeName: (context) => const ServiceBills(),
  Payments.routeName: (context) => const Payments(),
  PaymentList.routeName: (context) => const PaymentList(''),
  PermittList.routeName: (context) => PermittList(),
  VerificationScreen.routeName: (context) => const VerificationScreen(),
  Grading.routeName: (context) => const Grading(),
  InspectionForm.routeName: (context) => const InspectionForm(),
  ExpiredBills.routeName: (context) => const ExpiredBills(''),
  SealScreen.routeName: (context) => const SealScreen(''),

  BillsDashBoard.routeName: (context) => const BillsDashBoard(''),
  PosReg.routeName: (context) => const PosReg(),
  Otp.routeName: (context) => const Otp(),
  UpdateApp.routeName: (context) => const UpdateApp(),
  BillManagement.routeName: (context) => const BillManagement(""),
  ForestInventoryScreen.routeName: (context) => const ForestInventoryScreen(),
  ListSystems.routeName: (context) => const ListSystems(),
  IllegalProductScreen.routeName: (context) => const IllegalProductScreen(),
  NFRScreen.routeName: (context) => const NFRScreen(),
  CreateTourism.routeName: (context) => const CreateTourism(),
  TPtimeline.routeName: ((context) => const TPtimeline()),
  GenerateQrCode.routeName: (context) => const GenerateQrCode(
        id: "",
      ),
  VisitorsList.routeName: ((context) => const VisitorsList()),
  ExpectedTP.routeName: ((context) => const ExpectedTP()),
  TPEditing.routeName: ((context) => const TPEditing()),
  ExtensionApproval.routeName: ((context) => const ExtensionApproval()),
  ExyensionApprovalWidget.routeName:(context) => const ExyensionApprovalWidget()
};
