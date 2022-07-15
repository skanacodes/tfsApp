// ignore_for_file: file_names, prefer_typing_uninitialized_variables, avoid_print, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tfsappv1/screens/payments/billForm.dart';

import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/modal/arguments.dart';

import 'package:tfsappv1/services/size_config.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

class ServiceBills extends StatefulWidget {
  static String routeName = "/services";
  const ServiceBills({Key? key}) : super(key: key);

  @override
  _ServiceBillsState createState() => _ServiceBillsState();
}

class _ServiceBillsState extends State<ServiceBills> {
  String? type;
  List data = [];
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
      var url = Uri.parse('http://41.59.227.103:5013/api/Setup/GetTarrifs');
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
            data = res;
            isLoading = false;
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

  @override
  void initState() {
    getData();
    // ignore: todo
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' Generate Bill',
          style: TextStyle(color: Colors.black, fontFamily: 'ubuntu'),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: isLoading
                  ? const SpinKitCircle(
                      color: kPrimaryColor,
                    )
                  : Container(
                      height: getProportionateScreenHeight(700),
                      color: Colors.white,
                      child: AnimationLimiter(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 1375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Card(
                                    elevation: 10,
                                    shadowColor: Colors.grey,
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, BillForm.routeName,
                                            arguments: ScreenArguments(
                                                data[index]["gfs_code"]
                                                    .toString(),
                                                data[index]["description"]
                                                    .toString(),
                                                data[index]["unit_price"]
                                                    .toString()));
                                      },
                                      trailing: const Icon(
                                        Icons.arrow_right,
                                        color: Colors.cyan,
                                      ),
                                      leading: CircleAvatar(
                                          backgroundColor: kPrimaryColor,
                                          child: Text('${index + 1}')),
                                      title: Text(
                                          "Descriptions: ${data[index]["description"]}"),
                                      subtitle: Text(
                                          'Unit Price: ${data[index]["unit_price"]}'),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
