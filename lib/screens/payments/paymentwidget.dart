import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/deletefile.dart';
import 'package:tfsappv1/services/mail.dart';
import 'package:tfsappv1/services/modal/receiptArguments.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentWidget extends StatefulWidget {
  PaymentWidget({Key? key}) : super(key: key);

  @override
  _PaymentWidgetState createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  var data;
  var brand;
  String? billId;
  bool isLoading = false;
  bool isItems = false;
  bool isEmail = false;
  bool isSms = false;
  bool isPrinting = false;
  bool isReceiptGenerated = false;
  var printingFont = 17.0;
  static const platform = MethodChannel(
    'samples.flutter.dev/printing',
  );
  List dataItems = [];
  Uint8List? _imageFile;
  Uint8List? _imageFile1;
  String? payerMail;
  final _formKey = GlobalKey<FormState>();
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  ScreenshotController screenshotController1 = ScreenshotController();
  Future updatePrinterStatus(controlNumber) async {
    setState(() {
      isLoading = true;
    });
    try {
      String email = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('email').toString());
      //       String id = await SharedPreferences.getInstance()
      // .then((prefs) => prefs.getInt('email').toString());

      print(email);
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url =
          Uri.parse('http://mis.tfs.go.tz/fremis-test/api/v1/print_status');
      print(billId);
      // var url =
      //     Uri.parse('http://mis.tfs.go.tz/e-auction/api/v1/Bill/PrintReceipt');
      final response = await http
          .post(url, body: {"control_number":controlNumber});
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            data = res['message'].toString();
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);

            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  Future itemsReceipt(bill_Id, system) async {
    setState(() {
      isLoading = true;
      billId = bill_Id;
    });
    try {
      // String stationId = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getInt('station_id').toString());

      //print(stationId);
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // var headers = {"Authorization": "Bearer " + tokens!};
      print(bill_Id);
      print(system);
      var url = system == "E-Auction"
          ? Uri.parse(
              'https://mis.tfs.go.tz/e-auction/api/Bill/GetPriceDistribution/$bill_Id')
          : Uri.parse('$baseUrlTest/api/v1/bill-items/$bill_Id');
      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isItems = true;
            dataItems = res['data'];
          });

          break;

        default:
          setState(() {
            isItems = true;
            res = json.decode(response.body);
            print(res);

            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        isItems = true;
        messages('Server Or Connectivity Error', 'error');
      });
    }
  }

  transform() {
    return SizedBox(
      height: 100,
      child: Transform(
        child: const Text(
          "87438823",
          style: TextStyle(color: Colors.black45, fontSize: 20),
        ),
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()..rotateZ(20 * 3.1420927 / 180),
      ),
    );
  }

  Future<void> _getPrinter(
      {String? name,
      String? controlNo,
      String? receiptNo,
      String? amount,
      String? issuer,
      String? paymentDate,
      String? description,
      String? plotname,
      String? station,
      List? items}) async {
    setState(() {
      isPrinting = true;
    });
    List desc = [];
    List amounts = [];

    for (var i = 0; i < dataItems.length; i++) {
      desc.add(dataItems[i]["ItemDescr"]);
      print(dataItems[i]["BillItemAmt"]);
      print(dataItems[i]["BillItemAmt"].runtimeType);
      amounts.add(formatNumber.format(dataItems[i]["BillItemAmt"]));
    }
    print(desc);
    print(amounts);
    await screenshotController.capture().then((Uint8List? image) {
      //Capture Done
      setState(() {
        _imageFile = image!;
      });
    }).catchError((onError) {
      print(onError);
    });
    await screenshotController1.capture().then((Uint8List? image) {
      //Capture Done
      setState(() {
        _imageFile1 = image!;
      });
    }).catchError((onError) {
      print(onError);
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Starting Printer"),
        ),
      );
      // print(_imageFile1);
      final String result = await platform.invokeMethod('getBatteryLevel', {
        "imageData": base64Encode(_imageFile!),
        "brand": brand,
        "name": name,
        "controlNo": controlNo,
        "receiptNo": receiptNo,
        "amount": amount,
        "issuer": issuer,
        "paymentDate": paymentDate,
        "desc": description,
        "itemsAmount": amounts,
        "itemsDesc": desc,
        "qrcode": base64Encode(_imageFile1!),
        "plotname": plotname,
        "station": station,
        "activity": "printing"
      });

      print(result);
      if (result == "Successfully Printed") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$result"),
          ),
        );
        if (mounted)
          setState(() {
            isReceiptGenerated = true;
          });
        await updatePrinterStatus(controlNo);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$result"),
          ),
        );
      }
    } on PlatformException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
        ),
      );
    }

    setState(() {
      isPrinting = false;
    });
  }

  Future getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // print(tokens);
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('http://mis.tfs.go.tz/fremis-test/api/v1/paid-bills');
      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 201:
          setState(() {
            res = json.decode(response.body);
            print(res);
            data = res['data'];
            print(data[0].toString());
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  messages(
    String type,
    String desc,
  ) {
    return Alert(
      context: context,
      type: type == 'success' ? AlertType.success : AlertType.error,
      title: 'Information',
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            if (type == 'success') {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
          width: 120,
        )
      ],
    ).show();
  }

  getBrand() async {
    brand = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('brand'));
  }

  @override
  void initState() {
    // this.getData();
    this.getBrand();
    super.initState();
  }

  DateTime now = DateTime.now();
  String formattedDate =
      DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    setState(() {
      isPrinting = true;
    });
    final args =
        ModalRoute.of(context)!.settings.arguments as ReceiptScreenArguments;
    isItems
        ? null
        : args.billId == null
            ? null
            : itemsReceipt(args.billId, args.system);

    return Column(
      children: [
        isReceiptGenerated
            ? Container()
            : dataItems.isEmpty
                ? Container()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(13, 8, 13, 0),
                    child: Card(
                        elevation: 10,
                        child: Container(
                            width: double.infinity,
                            //  height: getProportionateScreenHeight(100),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.select_all,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  Expanded(
                                      flex: 6,
                                      child: Text(args.isBill
                                          ? "How Do You Want To Receive Bill"
                                          : "How Do You Want To Receive Receipt")),
                                  Expanded(
                                    flex: 1,
                                    child: popBar(args),
                                  )
                                ],
                              ),
                            ))),
                  ),
        isReceiptGenerated ? Container() : userMail(args),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            // height: isNotFpund
            //     ? getProportionateScreenHeight(100)
            //     : getPropoPartionateScreenHeight(300),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10,
                      color: Colors.grey,
                      spreadRadius: 3,
                      offset: Offset.zero)
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Container(
                color: Colors.white,
                child: Stack(children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      // Align(
                      //     alignment: Alignment.topCenter, child: transform()),
                      // Align(alignment: Alignment.center, child: transform()),
                      // Align(
                      //     alignment: Alignment.bottomCenter,
                      //     child: transform()),
                      // Align(
                      //     alignment: Alignment.bottomCenter,
                      //     child: transform()),
                    ],
                  ),
                  Column(
                    children: [
                      Screenshot(
                          controller: screenshotController,
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Center(
                                  child: Container(
                                      height: getProportionateScreenHeight(300),
                                      width: getProportionateScreenHeight(300),
                                      color: Colors.white,
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                      )),
                                )),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Text('---------------------------',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              ' Tanzania Forest Service Agency (TFS).',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text('---------------------------',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text('Client: ',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ))),
                            Expanded(
                              child: Text(args.payerName.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            )
                          ],
                        ),
                      ),
                      args.isBill
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text('Receipt No: ',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ))),
                                  Expanded(
                                    child: Text(args.receiptNo.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                        )),
                                  )
                                ],
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text('Control No: ',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ))),
                            Expanded(
                              child: Text(args.controlNumber.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text('Desc: ',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ))),
                            Expanded(
                              child: Text(args.desc.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            )
                          ],
                        ),
                      ),
                      args.plotname.toString() == "null"
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text('Plot Name: ',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ))),
                                  Expanded(
                                    child: Text(args.plotname.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                        )),
                                  )
                                ],
                              ),
                            ),
                      args.station.toString() == "null"
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text('Station: ',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ))),
                                  Expanded(
                                    child: Text(args.station!,
                                        style: TextStyle(
                                          color: Colors.black,
                                        )),
                                  )
                                ],
                              ),
                            ),
                      args.isBill
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text('Fee',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ))),
                                  Expanded(
                                    child:
                                        Text(formatNumber.format(args.amount),
                                            style: TextStyle(
                                              color: Colors.black,
                                            )),
                                  )
                                ],
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text('Issuer: ',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ))),
                            Expanded(
                              child: Text(args.issuer,
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text('Paid On: ',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ))),
                            Expanded(
                              child: Text(args.payedDate.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 6,
                                child: Text('Description ',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ))),
                            Expanded(
                              flex: 3,
                              child: Text('Amount',
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[400],
                      ),
                      for (var i = 0; i < dataItems.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Text(dataItems[i]['ItemDescr'],
                                      style: TextStyle(
                                        color: Colors.black,
                                      ))),
                              Expanded(
                                flex: 3,
                                child: Text(
                                    ": " +
                                        formatNumber.format(
                                            dataItems[i]['BillItemAmt']),
                                    style: TextStyle(
                                      color: Colors.black,
                                    )),
                              )
                            ],
                          ),
                        ),
                      Divider(
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 6,
                                child: Text('Total Amount: ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                              flex: 3,
                              child: Text(formatNumber.format(args.amount),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[400],
                      ),
                      Screenshot(
                          controller: screenshotController1,
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  QrImage(
                                    data: args.isBill
                                        ? args.controlNumber
                                        : args.receiptNo.toString(),
                                    version: QrVersions.auto,
                                    size: 200,
                                    gapless: false,
                                  ),
                                ],
                              ),
                            ),
                          )),
                      args.isBill
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'Genuine Receipt for cash Received',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ])),
          ),
        ),
      ],
    );
  }

  createPDF(ReceiptScreenArguments args, String userEmail) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sending Email To $userEmail"),
      ),
    );
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    final doc = pw.Document();

    final image = await imageFromAssetBundle('assets/images/logo.png');
    final ttf =
        await fontFromAssetBundle('assets/fonts/ubuntu/Ubuntu-Regular.ttf');

    const double inch = 72.0;
    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat(7 * inch, double.infinity, marginLeft: 5),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Divider(height: 2, thickness: 3, color: PdfColors.black),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Center(
                  child: pw.Container(
                    height: 230,
                    width: 230,
                    decoration: pw.BoxDecoration(
                      //color: Colors.white,
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Center(
                      child: pw.Image(image),
                    ),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5.0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                        '-----------------------------------------------------------',
                        style: pw.TextStyle(
                            fontSize: 20, color: PdfColors.black, font: ttf)),
                    pw.Text('TFSApp',
                        style: pw.TextStyle(
                            fontSize: 25, font: ttf, color: PdfColors.black)),
                    pw.Text('Tanzania Forest Services Agency',
                        style: pw.TextStyle(
                            fontSize: 20, font: ttf, color: PdfColors.black)),
                    pw.Text(
                        '-----------------------------------------------------------',
                        style: pw.TextStyle(
                            fontSize: 20, color: PdfColors.black, font: ttf)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Name: ',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(args.payerName.toString(),
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              args.isBill
                  ? pw.Container()
                  : pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text('Receipt No:',
                                style: pw.TextStyle(
                                    fontSize: 20,
                                    font: ttf,
                                    color: PdfColors.black)),
                          ),
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text(args.receiptNo.toString(),
                                style: pw.TextStyle(
                                    fontSize: 20,
                                    font: ttf,
                                    color: PdfColors.black)),
                          ),
                          pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                        ],
                      ),
                    ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Control No:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(args.controlNumber.toString(),
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Desc:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(args.desc.toString(),
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Paid Fee:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(args.amount.toString(),
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Issuer:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(args.issuer.toString(),
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Date:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(formattedDate,
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 2)),
                  ],
                ),
              ),
              pw.Divider(thickness: 3, color: PdfColors.black),
              pw.Container(
                height: 250,
                width: 250,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.BarcodeWidget(
                      data: args.receiptNo.toString(),
                      barcode: pw.Barcode.qrCode(),
                      textStyle: pw.TextStyle(fontItalic: ttf),
                      color: PdfColors.black),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Genuine Receipt for the cash Received',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(
                height: 250,
              )
            ],
          );
        }));

    try {
      final dir = await getExternalStorageDirectory();
      String dirPath = dir!.path;
      final String paths = '$dirPath/${userEmail + formattedDate}.pdf';
      final File file = await File(paths);
      var x = await file.writeAsBytes(await doc.save());
      print(x);
      print(paths);
      Future.delayed(const Duration(milliseconds: 500), () async {
        var emailRes = await MailSending().sendMails(paths, userEmail);
        if (emailRes == "Email Sent Successfull") {
          if (!mounted) return;
          setState(() {
            isReceiptGenerated = true;
          });

          var del = await FilesManupalation().deleteFile(File(paths));
          print(del);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(emailRes!),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(emailRes!),
            ),
          );
        }
      });
    } catch (e) {
      messages("error", e.toString());
    }
  }

  userMail(ReceiptScreenArguments args) {
    // print(args.);
    return isEmail || isSms
        ? Padding(
            padding: const EdgeInsets.fromLTRB(13, 8, 13, 0),
            child: Card(
              elevation: 10,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: getProportionateScreenHeight(20),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.disabled_by_default_outlined,
                              size: 13,
                              color: Colors.red,
                            ),
                            onPressed: () => setState(() {
                              isEmail = false;
                              isSms = false;
                            }),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                      child: Container(
                        child: TextFormField(
                          keyboardType: isEmail
                              ? TextInputType.text
                              : TextInputType.number,
                          key: Key(""),
                          onSaved: (val) => payerMail = val!,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Colors.cyan,
                              ),
                            ),
                            fillColor: Color(0xfff3f3f4),
                            filled: true,
                            labelText: isEmail
                                ? "Enter Client Email"
                                : "Enter Client Phone Number",
                            border: InputBorder.none,
                            suffixIcon: InkWell(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  isEmail
                                      ? await createPDF(args, payerMail!)
                                      : await sendSms(payerMail!, args);
                                  _formKey.currentState!.reset();
                                }
                              },
                              child: Icon(
                                Icons.send_outlined,
                                size: 25,
                                color: kPrimaryColor,
                              ),
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(30, 10, 20, 10),
                          ),

                          // onChanged: (val) {
                          //   setState(() {});
                          // },
                          validator: (value) {
                            if (value!.isEmpty) return "This Field Is Required";
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    )
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  popBar(ReceiptScreenArguments args) {
    return Padding(
      padding: EdgeInsets.only(right: 10.0),
      child: PopupMenuButton(
        tooltip: 'Menu',
        child: Icon(
          Icons.more_vert,
          size: 28.0,
          color: Colors.black,
        ),
        offset: Offset(20, 40),
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () async {
              await _getPrinter(
                  amount: formatNumber.format(args.amount),
                  controlNo: args.controlNumber.toString(),
                  issuer: args.issuer.toString(),
                  name: args.payerName.toString(),
                  paymentDate: args.payedDate.toString(),
                  receiptNo: args.receiptNo.toString(),
                  items: dataItems,
                  description: args.desc.toString(),
                  plotname: args.plotname.toString(),
                  station: args.station.toString());
            },
            child: Row(
              children: [
                Icon(
                  Icons.print,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    "Printing",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () {
              //print("mail");
              setState(() {
                isEmail = true;
                isSms = false;
                print(isEmail);
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    "Mail",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () {
              setState(() {
                isSms = true;
                isEmail = false;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: kPrimaryColor,
                  size: getProportionateScreenHeight(22),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    "Sms",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future sendSms(payerNumber, ReceiptScreenArguments args) async {
    try {
      var url = Uri.parse(
          'https://mis.tfs.go.tz/messaging/api/SMSMessaging/SendSMSCustom');

      final response = await http.post(url,
          body: jsonEncode(
            {
              "Message":
                  "Malipo yamepokelewa kwenda TFS\nAnkara: ${args.controlNumber}\nKiasi: ${args.amount}\nRisiti: ${args.receiptNo}\n${args.payedDate}\nKupitia: ${args.bankReceipt}",
              "Phones": [
                {"name": "$payerNumber"}
              ],
            },
          ),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
          });
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Sms Successfully Sent"),
            ),
          );
          await updatePrinterStatus(args.controlNumber);
          setState(() {
            isReceiptGenerated = true;
            Navigator.pop(context);
          });
          break;

        default:
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Something Went Wrong"),
              ),
            );
          });
          break;
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Server Or Connectivity Error"),
        ),
      );
    }
  }
}
