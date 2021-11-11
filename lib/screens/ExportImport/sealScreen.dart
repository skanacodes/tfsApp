import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:sizer/sizer.dart';

class SealScreen extends StatefulWidget {
  static String routeName = "/Seal";
  final objectData;
  SealScreen(this.objectData);

  @override
  _SealScreenState createState() => _SealScreenState();
}

class _SealScreenState extends State<SealScreen> {
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardB = new GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardC = new GlobalKey();
  bool isLoading = false;
  Widget _title() {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
          text: 'Export',
          style: GoogleFonts.portLligatSans(
            //  textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 15.0.sp,
            fontWeight: FontWeight.w700,
            color: kPrimaryColor,
          ),
          children: [
            TextSpan(
              text: ' Permit ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0.sp,
              ),
            ),
            TextSpan(
              text: ' Details',
              style: TextStyle(
                color: Colors.green[200],
                fontSize: 15.0.sp,
              ),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    //var arguments = ModalRoute.of(context)!.settings.arguments;
    print(widget.objectData);
    // print(arguments!['exporter_name']);
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Text(
            'Export Permit Sealing',
            style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: getProportionateScreenHeight(130),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: getProportionateScreenHeight(90),
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.only(
                        //     bottomLeft: Radius.circular(150),
                        //     bottomRight: Radius.circular(150)),
                        color: kPrimaryColor,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Card(
                          elevation: 20,
                          child: ListTile(
                              tileColor: Colors.white,
                              title: _title(),
                              trailing: Icon(
                                Icons.data_saver_off,
                                color: Colors.cyan,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.pink,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ExpansionTileCard(
                  key: cardA,
                  expandedTextColor: Colors.black,
                  shadowColor: kPrimaryColor,
                  duration: Duration(milliseconds: 500),
                  animateTrailing: true,
                  baseColor: Color(0xfff3f3f4),
                  elevation: 10,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.zero,
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.data_usage_rounded,
                        color: kPrimaryColor,
                      )),
                  title: Text('Export Permit Informations'),
                  children: <Widget>[
                    Divider(
                      thickness: 1.0,
                      height: 1.0,
                      color: Colors.cyan,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.person_pin,
                              color: Colors.purple,
                            )),
                        Expanded(flex: 3, child: Text('Exporter Name: ')),
                        Expanded(
                            flex: 4,
                            child: Text(
                                widget.objectData['exporter_name'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.format_list_numbered,
                              color: Colors.pink,
                            )),
                        Expanded(flex: 3, child: Text('Certificate Number : ')),
                        Expanded(
                            flex: 4,
                            child: Text(
                                widget.objectData['certificate_no'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.pin_drop,
                              color: Colors.amber,
                            )),
                        Expanded(flex: 3, child: Text('Export-Code : ')),
                        Expanded(
                            flex: 4,
                            child: Text(widget.objectData['code'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.location_city_rounded,
                              color: kPrimaryColor,
                            )),
                        Expanded(flex: 3, child: Text('Postal Address: ')),
                        Expanded(
                            flex: 4,
                            child: Text(
                                widget.objectData['postal_address'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.call_end_outlined,
                              color: Colors.brown,
                            )),
                        Expanded(flex: 3, child: Text('Phone Number : ')),
                        Expanded(
                            flex: 4,
                            child:
                                Text(widget.objectData['phone_no'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.traffic,
                              color: Colors.indigoAccent,
                            )),
                        Expanded(flex: 3, child: Text('Destination Owner : ')),
                        Expanded(
                            flex: 4,
                            child: Text(widget.objectData['destination_owner']
                                .toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.nature_outlined,
                              color: Colors.green,
                            )),
                        Expanded(flex: 3, child: Text('Country : ')),
                        Expanded(
                            flex: 4,
                            child:
                                Text(widget.objectData['country'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.ac_unit,
                              color: Colors.blueAccent,
                            )),
                        Expanded(flex: 3, child: Text('Origin SawMill : ')),
                        Expanded(
                            flex: 4,
                            child: Text(
                                widget.objectData['origin_sawmill'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.line_weight_rounded,
                              color: Colors.deepOrangeAccent,
                            )),
                        Expanded(flex: 3, child: Text('Number Of Pieces : ')),
                        Expanded(
                            flex: 4,
                            child: Text(
                                widget.objectData['no_of_pieces'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.vertical_align_center_outlined,
                              color: Colors.black,
                            )),
                        Expanded(flex: 3, child: Text('Valid Days : ')),
                        Expanded(
                            flex: 4,
                            child: Text(
                                widget.objectData['valid_days'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.published_with_changes_outlined,
                              color: Colors.grey,
                            )),
                        Expanded(flex: 3, child: Text('Place Of Issue : ')),
                        Expanded(
                            flex: 4,
                            child: Text(
                                widget.objectData['place_of_issue'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.calendar_today,
                              color: Colors.cyan,
                            )),
                        Expanded(flex: 3, child: Text('Issue Date : ')),
                        Expanded(
                            flex: 4,
                            child: Text(
                                widget.objectData['date_of_issue'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.receipt,
                              color: Colors.grey,
                            )),
                        Expanded(flex: 3, child: Text('Receipt Number: ')),
                        Expanded(
                            flex: 4,
                            child: Text(
                                widget.objectData['receipt_no'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.red,
                            )),
                        Expanded(flex: 3, child: Text('Receipt Date: ')),
                        Expanded(
                            flex: 4,
                            child: Text(
                                widget.objectData['receipt_date'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.payment,
                              color: Colors.green,
                            )),
                        Expanded(flex: 3, child: Text('Amount Paid: ')),
                        Expanded(
                            flex: 4,
                            child: Text(
                                widget.objectData['amount_paid'].toString()))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.file_copy,
                              color: Colors.brown,
                            )),
                        Expanded(flex: 3, child: Text('Remarks: ')),
                        Expanded(
                            flex: 4,
                            child:
                                Text(widget.objectData['remarks'].toString()))
                      ],
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceAround,
                      buttonHeight: 52.0,
                      buttonMinWidth: 90.0,
                      children: <Widget>[
                        TextButton(
                          style: flatButtonStyle,
                          onPressed: () {
                            cardA.currentState?.collapse();
                          },
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.arrow_upward),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Text('Close'),
                            ],
                          ),
                        ),
                        TextButton(
                          style: flatButtonStyle,
                          onPressed: () {
                            cardA.currentState?.collapse();
                            cardB.currentState?.toggleExpansion();
                          },
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.swap_vert),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Text('Toggle Previous CheckPoint'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ExpansionTileCard(
                  key: cardC,
                  duration: Duration(milliseconds: 500),
                  animateTrailing: true,
                  baseColor: Color(0xfff3f3f4),
                  expandedTextColor: Colors.black,
                  elevation: 10,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.zero,
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),

                  leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.star_purple500_outlined,
                        color: kPrimaryColor,
                      )),
                  title: Text('Products'),
                  // subtitle: Text(''),
                  children: <Widget>[
                    Divider(
                      thickness: 1.0,
                      height: 1.0,
                      color: Colors.cyan,
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Icon(
                                  Icons.ac_unit,
                                  color: kPrimaryColor,
                                )),
                            Expanded(flex: 3, child: Text('Product Name : ')),
                            Expanded(
                                flex: 4,
                                child: Text(widget
                                            .objectData['product_category']
                                            .toString() ==
                                        'null'
                                    ? ''
                                    : widget.objectData['product_category']
                                        .toString())),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Icon(
                                  Icons.format_list_numbered_rtl_rounded,
                                  color: Colors.cyan,
                                )),
                            Expanded(flex: 3, child: Text('Quantity : ')),
                            Expanded(
                                flex: 4,
                                child: Text(widget.objectData['quantity']
                                            .toString() ==
                                        'null'
                                    ? ''
                                    : widget.objectData['quantity'].toString() +
                                        " " +
                                        widget.objectData['unit'].toString()))
                          ],
                        ),
                        Divider(
                          color: Colors.purple,
                          endIndent: 20,
                        )
                      ],
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceAround,
                      buttonHeight: 52.0,
                      buttonMinWidth: 90.0,
                      children: <Widget>[
                        TextButton(
                          style: flatButtonStyle,
                          onPressed: () {
                            cardC.currentState?.collapse();
                          },
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.arrow_upward),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Text('Close'),
                            ],
                          ),
                        ),
                        TextButton(
                          style: flatButtonStyle,
                          onPressed: () {
                            cardA.currentState?.toggleExpansion();
                          },
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.swap_vert),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Text('Toggle'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _submitButton(),
              )
            ],
          ),
        ));
  }

  message(String desc, String type) {
    return Alert(
      context: context,
      type: type == 'error' ? AlertType.warning : AlertType.info,
      title: "Information",
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          width: 120,
        )
      ],
    ).show();
  }

  Future seal() async {
    var tokens = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));
    print(tokens);
    try {
      var headers = {"Authorization": "Bearer " + tokens!};
      var url =
          Uri.parse('https://mis.tfs.go.tz/fremis/api/v1/export/seal/151');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print('dfsjjdsfsd');
      //final sharedP prefs=await
      res = json.decode(response.body);
      print(res);

      switch (res['message']) {
        case 'Successfully Sealed':
          setState(() {
            res = json.decode(response.body);

            message("Successfully Sealed", "success");

            print(res);
          });
          break;
        case 'Error!, This Export Permit is Already Sealed':
          setState(() {
            res = json.decode(response.body);

            message("This Permit Has Already Been Sealed", "error");

            print(res);
          });
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            message("An Error While Sealing", "error");
            print(res);
          });
          break;
      }
    } on SocketException {
      setState(() {
        var res = 'Server Error';
        message("An Error While Sealing", "error");
        print(res);
      });
    }
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        setState(() {
          isLoading = true;
        });
        await seal();
        setState(() {
          isLoading = false;
        });
      },
      child: isLoading
          ? SpinKitCircle(
              color: kPrimaryColor,
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [kPrimaryColor, Colors.green[200]!])),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
    );
  }
}
