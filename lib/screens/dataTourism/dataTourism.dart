// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class DataTourism extends StatefulWidget {
  final List data;
  const DataTourism({super.key, required this.data});

  @override
  State<DataTourism> createState() => _DataTourismState();
}

class _DataTourismState extends State<DataTourism> {
  final value = NumberFormat("#,##0.00", "en_US");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Tourism Details"),
      ),
      body: ListView.builder(
          itemCount: widget.data.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: getProportionateScreenHeight(150),
                //width: getProportionateScreenWidth(300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  // boxShadow: const [
                  //   BoxShadow(
                  //     color: Colors.grey,
                  //     spreadRadius: 1,
                  //     blurRadius: 5,
                  //     offset: Offset(0, 5),
                  //   )
                  // ]
                ),
                child: Row(
                  children: [
                    index.isEven
                        ? Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              // height: getProportionateScreenHeight(140),
                              width: getProportionateScreenWidth(210),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 5),
                                    )
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Station:${widget.data[index]["station"]}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "No. Of Tourist: ${widget.data[index]["total_tourist"]}",
                                      style: const TextStyle(),
                                    ),
                                    Text(
                                      "Revenue(TZS): ${value.format(widget.data[index]["total_income_tz"])} TZS",
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    Text(
                                      "Revenue(USD): ${value.format(double.parse(widget.data[index]["total_income_usd"].toString()))} \$",
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    RatingBar.builder(
                                      glow: true,
                                      itemSize: 12.sp,
                                      initialRating: 4,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        print(rating);
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    const VerticalDivider(
                      color: kPrimaryColor,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: index.isEven
                          ? Image.asset(
                              "assets/images/nature.jpeg",
                              fit: BoxFit.cover,
                              height: getProportionateScreenHeight(150),
                              width: getProportionateScreenWidth(100),
                            )
                          : Image.asset(
                              "assets/images/west.jpg",
                              fit: BoxFit.cover,
                              height: getProportionateScreenHeight(150),
                              width: getProportionateScreenWidth(100),
                            ),
                    ),
                    const VerticalDivider(
                      color: kPrimaryColor,
                    ),
                    index.isEven
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              // height: getProportionateScreenHeight(140),
                              width: getProportionateScreenWidth(210),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 5),
                                    )
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Station:${widget.data[index]["station"]}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "No. Of Tourist: ${widget.data[index]["total_tourist"]}",
                                      style: const TextStyle(),
                                    ),
                                    Text(
                                      "Revenue(TZS): ${value.format(widget.data[index]["total_income_tz"])} TZS",
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    Text(
                                      "Revenue(USD): ${value.format(double.parse(widget.data[index]["total_income_usd"].toString()))} \$",
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    RatingBar.builder(
                                      itemSize: 12.sp,
                                      initialRating: 4.5,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        print(rating);
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
