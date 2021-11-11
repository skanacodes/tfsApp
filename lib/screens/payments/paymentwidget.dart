import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tfsappv1/services/constants.dart';
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
  bool isLoading = false;
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

  @override
  void initState() {
    // this.getData();

    super.initState();
  }

  DateTime now = DateTime.now();
  String formattedDate =
      DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ReceiptScreenArguments;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            // height: isNotFpund
            //     ? getProportionateScreenHeight(100)
            //     : getProportionateScreenHeight(300),
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: kPrimaryColor,
                      ),
                      SizedBox(
                        width: getProportionateScreenWidth(10),
                      ),
                      Text(
                        'RECEIPT',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Container(
                        width: getProportionateScreenWidth(80),
                        height: getProportionateScreenHeight(50),
                        decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(5)),
                        child: Center(
                          child: InkWell(
                            onTap: () async {
                              await prints(args);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.print_outlined),
                                Text(
                                  'Print',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: kPrimaryColor,
                  height: getProportionateScreenHeight(10),
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(
                    child: Container(
                        height: getProportionateScreenHeight(200),
                        width: getProportionateScreenWidth(200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          // border: Border.all(
                          //     color: Colors.cyan,
                          //     style: BorderStyle.solid,
                          //     width: 1)
                        ),
                        child: Image.asset('assets/images/logo.png')),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      Text(
                          '--------------------------------------------------'),
                      Text(
                        'TFSApp',
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Tanzania Forest Services Agency',
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                          '--------------------------------------------------'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Client Name: ')),
                      Expanded(
                        child: Text(args.payerName.toString(),
                            style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Receipt No: ')),
                      Expanded(
                        child: Text(args.receiptNo.toString(),
                            style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Control No: ')),
                      Expanded(
                        child: Text(args.controlNumber.toString(),
                            style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Description: ')),
                      Expanded(
                        child: Text(args.desc.toString(),
                            style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Paid Fee: ')),
                      Expanded(
                        child: Text(args.amount.toString(),
                            style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Issuer: ')),
                      Expanded(
                        child: Text(args.issuer.toString(),
                            style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Date: ')),
                      Expanded(
                        child: Text(formattedDate.toString(),
                            style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          '-----------------------------------------------------------',
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QrImage(
                        data: args.receiptNo.toString(),
                        version: QrVersions.auto,
                        size: 120,
                        gapless: false,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Genuine Receipt for the cash Received',
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  prints(ReceiptScreenArguments args) async {
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
                        style:
                            pw.TextStyle(fontSize: 20, color: PdfColors.black)),
                    pw.Text('TFSApp',
                        style: pw.TextStyle(
                            fontSize: 25, font: ttf, color: PdfColors.black)),
                    pw.Text('Tanzania Forest Services Agency',
                        style: pw.TextStyle(
                            fontSize: 20, font: ttf, color: PdfColors.black)),
                    pw.Text(
                        '-----------------------------------------------------------',
                        style:
                            pw.TextStyle(fontSize: 20, color: PdfColors.black)),
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
                      child: pw.Text('Client Name: ',
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
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Expanded(flex: 1, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Receipt No:',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(args.receiptNo.toString(),
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
                      child: pw.Text('Description:',
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
                height: 150,
                width: 150,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.BarcodeWidget(
                      data: args.receiptNo.toString(),
                      barcode: pw.Barcode.qrCode(),
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
   
  }
}
