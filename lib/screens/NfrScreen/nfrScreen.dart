// ignore_for_file: file_names, prefer_typing_uninitialized_variables, avoid_print

import 'package:flutter/material.dart';

import 'package:tfsappv1/screens/NfrScreen/createTourism.dart';

import 'package:tfsappv1/screens/NfrScreen/toursList.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class NFRScreen extends StatefulWidget {
  static String routeName = "/NFRscreen";
  const NFRScreen({Key? key}) : super(key: key);

  @override
  State<NFRScreen> createState() => _NFRScreenState();
}

class _NFRScreenState extends State<NFRScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            '',
            style: TextStyle(
                fontFamily: 'Ubuntu', color: Colors.black, fontSize: 15),
          ),
        ),
        body: SizedBox(
            height: height,
            child: Column(children: <Widget>[
              Stack(
                children: [
                  Container(
                    height: getProportionateScreenHeight(70),
                    color: Colors.white,
                    // decoration: BoxDecoration(color: Colors.white),
                  ),
                  Container(
                    height: getProportionateScreenHeight(50),
                    decoration: const BoxDecoration(color: kPrimaryColor),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 5, 0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Card(
                        elevation: 10,
                        child: ListTile(
                          leading: CircleAvatar(
                            foregroundColor: kPrimaryColor,
                            backgroundColor: Colors.black12,
                            child: Icon(Icons.animation_outlined),
                          ),
                          title: Text("Tourism Tracking"),
                          // subtitle: Text(
                          //   _qrInfo!,
                          //   style: TextStyle(fontWeight: FontWeight.w400),
                          // ),
                          trailing: Icon(
                            Icons.library_books_outlined,
                            color: Colors.black,
                          ),
                          tileColor: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // _divider(),
              Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    height: getProportionateScreenHeight(500),
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ListView.builder(
                      itemCount: 2,
                      itemBuilder: ((context, i) {
                        return Card(
                          elevation: 10,
                          shadowColor: Colors.grey,
                          child: SizedBox(
                            child: ListTile(
                                onTap: () async {
                                  i == 0
                                      ? Navigator.pushNamed(
                                          context,
                                          CreateTourism.routeName,
                                        )
                                      : Navigator.pushNamed(
                                          context,
                                          VisitorsList.routeName,
                                        );
                                },
                                trailing: const Icon(
                                  Icons.arrow_right,
                                  color: Colors.black,
                                ),
                                leading: IntrinsicHeight(
                                    child: SizedBox(
                                        height: double.maxFinite,
                                        width: getProportionateScreenHeight(50),
                                        child: Row(
                                          children: [
                                            VerticalDivider(
                                              color: i.isEven
                                                  ? kPrimaryColor
                                                  : Colors.green[200],
                                              thickness: 5,
                                            )
                                          ],
                                        ))),
                                title: i == 0
                                    ? const Text("Create Safari")
                                    : const Text("List Of Safaris")),
                          ),
                        );
                      }),
                    ),
                  ))
            ])));
  }
}
