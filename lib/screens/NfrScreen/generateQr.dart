// ignore_for_file: file_names, prefer_typing_uninitialized_variables, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:item_selector/item_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/deletefile.dart';
import 'package:tfsappv1/services/mail.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GenerateQrCode extends StatefulWidget {
  static String routeName = "/GenerateQrscreen";
  final String id;
  const GenerateQrCode({Key? key, required this.id}) : super(key: key);

  @override
  State<GenerateQrCode> createState() => _GenerateQrCodeState();
}

class _GenerateQrCodeState extends State<GenerateQrCode> {
  var dBHCount;
  List data = [];
  List dataItems = [];
  List clientName = [];
  String? brand;
  bool isSelected = false;
  int? gridIndex;
  static const platform = MethodChannel(
    'samples.flutter.dev/printing',
  );
  String dbhnumber = "";
  String dbhQn = "";
  List gridNumbers = [];
  String? values;
  int count = 0;
  bool isLoading = false;
  List dbhCountList = [];
  initiateDBH() async {
    List.generate(55, (index) {
      setState(() {
        dBHCount = {"dbh": index + 11, "count": 0};
        print(dBHCount.toString());
        dbhCountList.add(dBHCount);
        print(dbhCountList);
      });
      print(dbhCountList.length);
      // return ;
    });
  }

  Future toQrImageData(List? index, List? names, {int? itemIndex}) async {
    try {
      List qrList = [];
      String qr;
      for (var i = 0; i < index!.length; i++) {
        final image = await QrPainter(
          data: itemIndex == null
              ? dataItems[i].toString()
              : dataItems[itemIndex].toString(),
          version: QrVersions.auto,
          color: Colors.black,
          emptyColor: Colors.white,
          gapless: false,
        ).toImage(200);
        final a = await image.toByteData(format: ImageByteFormat.png);
        qr = base64Encode(a!.buffer.asUint8List());
        // print(qr);
        qrList.add(qr);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Starting Printer"),
        ),
      );
      // print(qrList);
      final String result = await platform.invokeMethod('getBatteryLevel', {
        "activity": "QrCode",
        "qrList": qrList,
        "brand": brand,
        "client_name": itemIndex == null ? clientName : [clientName[itemIndex]]
      });
      if (result == "Successfully Printed") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
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
      var url = Uri.parse('$baseUrlTest/api/v1/group/members/${widget.id}');
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
            data = res['members'];
            isLoading = false;
            for (var i = 0; i < data.length; i++) {
              dataItems.add(data[i]["id"]);
              clientName.add("${data[i]["first_name"]} ${data[i]["middle_name"]} ${data[i]["last_name"]}");
            }
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            isLoading = false;
            messages('Ohps! Something Went Wrong', 'error');
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print(e);
        messages('Server Or Connectivity Error', 'error');
      });
    }
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
          onPressed: () {
            if (type == 'success') {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
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
    super.initState();
    getData();
    getBrand();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            'QR Codes For Group',
            style: TextStyle(
                color: Colors.black, fontFamily: 'Ubuntu', fontSize: 17),
          ),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
              height: height,
              child: Column(children: <Widget>[
                Stack(
                  children: [
                    Container(
                      height: getProportionateScreenHeight(60),
                      color: Colors.white,
                      // decoration: BoxDecoration(color: Colors.white),
                    ),
                    Container(
                      height: getProportionateScreenHeight(40),
                      decoration: const BoxDecoration(color: kPrimaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Card(
                          elevation: 10,
                          child: ListTile(
                            leading: const CircleAvatar(
                              foregroundColor: kPrimaryColor,
                              backgroundColor: Colors.black12,
                              child: Icon(Icons.qr_code_outlined),
                            ),
                            // title: Text("Total trees Counted:  $count"),
                            // subtitle: Text("DBH $dbhnumber : count $dbhQn"),
                            trailing: InkWell(
                              onTap: (() {
                                toQrImageData(dataItems, clientName);
                              }),
                              child: Column(
                                children: const [
                                  Text("Print"),
                                  Icon(
                                    Icons.print_outlined,
                                    color: Colors.purple,
                                  ),
                                ],
                              ),
                            ),
                            tileColor: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                // _divider(),
                isLoading
                    ? const SpinKitCircle(
                        color: kPrimaryColor,
                      )
                    : data.isEmpty
                        ? Center(
                            child: SizedBox(
                              height: getProportionateScreenHeight(400),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Card(
                                    elevation: 10,
                                    child: ListTile(
                                      title: Text("No Data Found"),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                            Icons.hourglass_empty_outlined),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                                color: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                child: AnimationLimiter(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: AnimationConfiguration
                                            .toStaggeredList(
                                          duration: const Duration(
                                              milliseconds: 1375),
                                          childAnimationBuilder: (widget) =>
                                              SlideAnimation(
                                            horizontalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: widget,
                                            ),
                                          ),
                                          children: <Widget>[
                                            Container(
                                              height:
                                                  getProportionateScreenHeight(
                                                      550),
                                              color: Colors.transparent,
                                              child: ItemSelectionController(
                                                selectionMode:
                                                    ItemSelectionMode.single,
                                                child: GridView(
                                                  padding: const EdgeInsets.all(5),
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 2),
                                                  children: List.generate(
                                                      data.length, (int index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Container(
                                                          decoration: BoxDecoration(
                                                              color: isSelected &&
                                                                      gridIndex ==
                                                                          index
                                                                  ? Colors.green
                                                                  : const Color(
                                                                      0xfff3f3f4),
                                                              boxShadow: const [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .grey,
                                                                    offset: Offset
                                                                        .zero,
                                                                    blurRadius:
                                                                        5)
                                                              ],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Container(
                                                            height:
                                                                getProportionateScreenHeight(
                                                                    00),
                                                            color: Colors.white,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 6,
                                                                        child:
                                                                            Center(
                                                                          child: Text("${data[index]["first_name"]} ${data[index]["middle_name"]} ${data[index]["last_name"]}"),
                                                                        ),
                                                                      ),
                                                                      popBar(
                                                                          data[
                                                                              index],
                                                                          index)
                                                                    ],
                                                                  ),
                                                                  QrImage(
                                                                    size: 100,
                                                                    data: data[index]
                                                                            [
                                                                            "id"]
                                                                        .toString(),
                                                                    eyeStyle: const QrEyeStyle(
                                                                        eyeShape:
                                                                            QrEyeShape
                                                                                .square,
                                                                        color: Colors
                                                                            .cyan),
                                                                    version:
                                                                        QrVersions
                                                                            .auto,
                                                                    gapless:
                                                                        false,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )),
                                                    );
                                                  }),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )))))
              ])),
        ));
  }

  createPDF(data) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sending Email To ${data["email"]}"),
      ),
    );
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    final doc = pw.Document();

    final image = await imageFromAssetBundle('assets/images/logo.png');
    final ttf =
        await fontFromAssetBundle('assets/fonts/ubuntu/Ubuntu-Light.ttf');

    const double inch = 72.0;
    doc.addPage(pw.Page(
        pageFormat: const PdfPageFormat(7 * inch, double.infinity, marginLeft: 5),
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
                    pw.Expanded(flex: 5, child: pw.SizedBox(width: 10)),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Entrace Ticket',
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(flex: 5, child: pw.SizedBox(width: 2)),
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
                      flex: 3,
                      child: pw.Text("Name: ",
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(data["first_name"],
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(data["middle_name"],
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(data["last_name"],
                          style: pw.TextStyle(
                              fontSize: 20, font: ttf, color: PdfColors.black)),
                    ),
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
              pw.Divider(thickness: 1, color: PdfColors.black),
              pw.Container(
                height: 250,
                width: 250,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.BarcodeWidget(
                      data: data["id"].toString(),
                      barcode: pw.Barcode.qrCode(),
                      textStyle: pw.TextStyle(fontItalic: ttf),
                      color: PdfColors.black),
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
      String? dirPath = dir?.path;
      final String paths = '$dirPath/${data["email"] + formattedDate}.pdf';
      final File file = File(paths);
      var x = await file.writeAsBytes(await doc.save());
      print(x);
      print(paths);
      Future.delayed(const Duration(milliseconds: 500), () async {
        var emailRes =
            await MailSending().sendMails(paths, data["email"].toString());
        if (emailRes == "Email Sent Successfull") {
          if (!mounted) return;
          setState(() {
            //  isReceiptGenerated = true;
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

  popBar(data, index) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(right: 1.0),
        child: PopupMenuButton(
          tooltip: 'Menu',
          offset: const Offset(20, 40),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () async {
                toQrImageData([
                  data["id"]
                ], [
                  "${data["first_name"]} ${data["middle_name"]} ${data["last_name"]}"
                ], itemIndex: index);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.print,
                    color: kPrimaryColor,
                    size: getProportionateScreenHeight(22),
                  ),
                  const Padding(
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
                createPDF(data);
                // setState(() {});
              },
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: kPrimaryColor,
                    size: getProportionateScreenHeight(22),
                  ),
                  const Padding(
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
          ],
          child: const Icon(
            Icons.more_vert,
            size: 28.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
