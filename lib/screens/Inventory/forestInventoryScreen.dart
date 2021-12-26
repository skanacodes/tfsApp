import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:item_selector/item_selector.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/services/size_config.dart';

class ForestInventoryScreen extends StatefulWidget {
  static String routeName = "/forestInventory";
  ForestInventoryScreen({Key? key}) : super(key: key);

  @override
  _ForestInventoryScreenState createState() => _ForestInventoryScreenState();
}

class _ForestInventoryScreenState extends State<ForestInventoryScreen> {
  var dBHCount;
  bool isSelected = false;
  int? gridIndex;
  String dbhnumber = "";
  String dbhQn = "";
  List gridNumbers = [];
  String? values;
  int count = 0;
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

  @override
  void initState() {
    super.initState();

    this.initiateDBH();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    print(dbhCountList);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Text(
            'Mensuration',
            style: TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
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
                      decoration: BoxDecoration(color: kPrimaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Card(
                          elevation: 10,
                          child: ListTile(
                            leading: CircleAvatar(
                              foregroundColor: kPrimaryColor,
                              backgroundColor: Colors.black12,
                              child: Icon(Icons.nature_outlined),
                            ),
                            title: Text("Total trees Counted:  $count"),
                            subtitle: Text("DBH $dbhnumber : count $dbhQn"),
                            trailing: Column(
                              children: [
                                Text("undo"),
                                Icon(
                                  Icons.undo_sharp,
                                  color: Colors.pink,
                                ),
                              ],
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
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 1),
                        child: AnimationLimiter(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    AnimationConfiguration.toStaggeredList(
                                  duration: const Duration(milliseconds: 1375),
                                  childAnimationBuilder: (widget) =>
                                      SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: widget,
                                    ),
                                  ),
                                  children: <Widget>[
                                    Container(
                                      height: getProportionateScreenHeight(550),
                                      color: Colors.transparent,
                                      child: ItemSelectionController(
                                        selectionMode: ItemSelectionMode.single,
                                        child: GridView(
                                          padding: EdgeInsets.all(5),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3),
                                          children:
                                              List.generate(10, (int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  if (mounted)
                                                    setState(() {
                                                      gridIndex = index;
                                                      isSelected = true;
                                                      (index + 1).toString() ==
                                                              "10"
                                                          ? values = "0"
                                                          : values = (index + 1)
                                                              .toString();
                                                      isSelected = true;
                                                      print(gridIndex);
                                                      print(values);
                                                      gridNumbers.add(values);
                                                      if (gridNumbers.length ==
                                                          2) {
                                                        print(gridNumbers);

                                                        var numbq = gridNumbers[
                                                                    0]
                                                                .toString() +
                                                            gridNumbers[1]
                                                                .toString();
                                                        if (int.parse(numbq) >=
                                                                11 &&
                                                            int.parse(numbq) <=
                                                                65) {
                                                          print("am");
                                                          int i =
                                                              int.parse(numbq) -
                                                                  11;
                                                          print(i);
                                                          dbhCountList[i]
                                                              ["count"]++;
                                                          count++;
                                                          dbhnumber = numbq;
                                                          dbhQn =
                                                              dbhCountList[i]
                                                                      ["count"]
                                                                  .toString();
                                                          print(
                                                              dbhCountList[i]);
                                                        }

                                                        print(numbq);
                                                        gridNumbers = [];
                                                      }
                                                    });
                                                  await Future.delayed(
                                                      Duration(seconds: 30));
                                                  if (mounted)
                                                    setState(() {
                                                      isSelected = false;
                                                    });
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: isSelected &&
                                                                gridIndex ==
                                                                    index
                                                            ? Colors.green
                                                            : Color(0xfff3f3f4),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              offset:
                                                                  Offset.zero,
                                                              blurRadius: 5)
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        2.0),
                                                                child: Badge(
                                                                    badgeColor:
                                                                        kPrimaryColor,
                                                                    animationType:
                                                                        BadgeAnimationType
                                                                            .scale,
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            5,
                                                                        vertical:
                                                                            1),
                                                                    badgeContent:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              1.0),
                                                                      child:
                                                                          Icon(
                                                                        isSelected &&
                                                                                gridIndex == index
                                                                            ? Icons.verified_user
                                                                            : Icons.panorama_fish_eye_outlined,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        CircleAvatar(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .grey,
                                                                      child: Text((index + 1).toString() ==
                                                                              "10"
                                                                          ? "0"
                                                                          : (index + 1)
                                                                              .toString()),
                                                                    ))),
                                                          ],
                                                        ),
                                                        Text(
                                                          isSelected &&
                                                                  gridIndex ==
                                                                      index
                                                              ? "Selected"
                                                              : "Unselected",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                              fontSize: 5.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    )),
                                              ),
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
}
