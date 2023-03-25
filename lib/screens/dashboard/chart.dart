// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:http/http.dart' as http;
import 'package:tfsappv1/services/size_config.dart';

class Chart extends StatefulWidget {
  const Chart({Key? key}) : super(key: key);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  bool isLoading = false;
  var data;
  List dataHeight = [];
  Future getDataInv() async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      // ////////////(printtokens);
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrl/api/inv_stats');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            data = res['data'];
            dataHeight = res['data']['highest_dbh'];
            isLoading = false;
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
            ////////////(printres);
            isLoading = false;
          });

          break;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ////////////(printe);
      });
    }
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getDataInv();
  }

  @override
  Widget build(BuildContext context) {
    // print(data);
    return dataHeight.isEmpty
        ? CupertinoActivityIndicator(
            radius: 10.sp,
            animating: true,
          )
        : Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
              children: [
                const Text(
                  "DBH against Height Line Graph",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 1300),
                    child: LineChart(
                      mainData(),
                      swapAnimationDuration: const Duration(milliseconds: 800),
                      swapAnimationCurve: Curves.linear,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: getProportionateScreenHeight(100),
                        //width: getProportionateScreenWidth(160),
                        child: Card(
                          elevation: 10,
                          child: Column(
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child:
                                      Image.asset("assets/images/volume.jpg")),
                              const Text(
                                "Total Volume ",
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(data["total_volume"] + " (cbm)")
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: getProportionateScreenHeight(100),
                        // width: getProportionateScreenWidth(160),
                        child: Card(
                          elevation: 10,
                          child: Column(
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: Image.asset("assets/images/map.png")),
                              const Text(
                                "Total Area ",
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(data["total_area"] + " (Ha)")
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: getProportionateScreenHeight(100),
                        // width: getProportionateScreenWidth(160),
                        child: Card(
                          elevation: 10,
                          child: Column(
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: Image.asset("assets/images/tree.png")),
                              const Text(
                                "Living Tree",
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(data["living_trees"])
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: getProportionateScreenHeight(100),
                        // width: getProportionateScreenWidth(160),
                        child: Card(
                          elevation: 10,
                          child: Column(
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: Image.asset(
                                      "assets/images/dead-tree.png")),
                              const Text(
                                "Dead Tree",
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(data["dead_trees"])
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: getProportionateScreenHeight(100),
                        // width: getProportionateScreenWidth(160),
                        child: Card(
                          elevation: 10,
                          child: Column(
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: Image.asset("assets/images/tree.png")),
                              const Text(
                                "Survival Rate For Young Trees(Age Below 3 Years)",
                                style: TextStyle(color: Colors.black),
                              ),
                              Text("${data["survival"]}%")
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  List<Color> gradientColors = [kGradientColorOne, kGradientColorTwo];

  LineChartData mainData() {
    return LineChartData(
      backgroundColor: Colors.grey[200],
      borderData: FlBorderData(
        show: false,
      ),
      gridData: FlGridData(
          show: true,
          horizontalInterval: 1.6,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              dashArray: const [3, 3],
              color: kGradientColorOne.withOpacity(0.2),
              strokeWidth: 2,
            );
          },
          drawVerticalLine: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
              color: kTextColor, fontWeight: FontWeight.bold, fontSize: 10),
          getTitles: (value) {
            switch (value.toInt()) {
              case 10:
                return '10(m)';
              case 20:
                return '20(m)';
              case 30:
                return '30(m)';
              case 40:
                return '40(m)';
              case 50:
                return '50(m)';
              case 60:
                return '60(m)';
            }
            return '';
          },
          margin: 5,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 30:
                return '30';
              case 60:
                return '60';
              case 90:
                return '90';
              case 120:
                return '120';
            }
            return '';
          },
          reservedSize: 25,
          margin: 12,
        ),
      ),
      minX: 0,
      maxX: 60,
      minY: 0,
      maxY: 120,
      lineBarsData: [
        LineChartBarData(
          spots: dataHeight
              .map((point) => FlSpot(
                  double.parse(point["height"]), double.parse(point["dbh"])))
              .toList(),
          isCurved: true,
          colors: gradientColors,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradientFrom: const Offset(0, 0),
            gradientTo: const Offset(0, 1),
            colors: [
              kGradientColorOne,
              kGradientColorTwo.withOpacity(0.2),
              kGradientColorTwo.withOpacity(0.1),
            ],
          ),
        ),
      ],
    );
  }
}
