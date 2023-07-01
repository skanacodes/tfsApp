// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tab_container/tab_container.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/screens/dataTourism/dataTourism.dart';
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
  var dataTourism = [];
  List dataHeight = [];
  List<_ChartData> datachart = [];
  late TooltipBehavior _tooltip;
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
            print("::::::::::::::::::::::::");
            data = res['data'];
            dataHeight = res['data']['highest_dbh'];
            dataTourism = res['data']['tourism'];
            print(dataTourism.length);
            for (var i = 0; i < dataTourism.length; i++) {
              print(dataTourism[i]["station"]);
              print(dataTourism[i]["total_tourist"]);
              datachart.add(_ChartData(dataTourism[i]["station"],
                  double.parse(dataTourism[i]["total_tourist"].toString())));
              print(datachart);
            }
            print(datachart);
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
        print(e);
        ////////////(printe);
      });
    }
  }

  @override
  void initState() {
    // datachart = [
    //   _ChartData('David', 25),
    //   _ChartData('Steve', 38),
    //   _ChartData('Jack', 34),
    //   _ChartData('Others', 52)
    // ];
    _tooltip = TooltipBehavior(enable: true);
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
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: getProportionateScreenHeight(650),
                  child: TabContainer(
                    // selectedTextStyle: const TextStyle(color: Colors.white),
                    // unselectedTextStyle: const TextStyle(color: Colors.black),
                    color: Colors.grey[300],
                    tabs: const [
                      'Tourism Stats',
                      'Inventory Stats',
                    ],
                    children: [
                      Card(
                        elevation: 10,
                        child: Column(
                          children: [
                            SfCircularChart(
                                tooltipBehavior: _tooltip,
                                annotations: <CircularChartAnnotation>[
                                  CircularChartAnnotation(
                                      // radius: '60%',
                                      height:
                                          (getProportionateScreenHeight(100))
                                              .toString(),
                                      width: (getProportionateScreenHeight(100))
                                          .toString(),
                                      widget: Container(
                                          child: PhysicalModel(
                                              child: Container(),
                                              shape: BoxShape.circle,
                                              elevation: 20,
                                              shadowColor: Colors.black,
                                              color: const Color.fromRGBO(
                                                  230, 230, 230, 1)))),
                                  CircularChartAnnotation(
                                      //radius: "50",
                                      height:
                                          (getProportionateScreenHeight(100))
                                              .toString(),
                                      width: (getProportionateScreenHeight(100))
                                          .toString(),
                                      widget: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Container(
                                              child: Text(
                                                  'No. of Tourist per Month',
                                                  style: TextStyle(
                                                      color:
                                                          const Color.fromRGBO(
                                                              0, 0, 0, 0.5),
                                                      fontSize: 10.sp))),
                                        ),
                                      ))
                                ],
                                palette: const [
                                  kPrimaryColor,
                                  Color.fromARGB(255, 191, 237, 215),
                                  Color.fromARGB(255, 57, 58, 164),
                                  Color.fromARGB(255, 27, 152, 152),
                                  Color.fromARGB(255, 160, 39, 130),
                                  Color.fromARGB(255, 195, 53, 53),
                                  Color.fromARGB(255, 57, 127, 164),
                                  Color.fromARGB(255, 113, 153, 27),
                                  Color.fromARGB(255, 220, 231, 18),
                                  Color.fromARGB(255, 74, 29, 122),
                                  Color.fromARGB(255, 228, 193, 136),
                                  Color.fromARGB(255, 81, 57, 17),
                                  Color.fromARGB(255, 90, 149, 112),
                                  Color.fromARGB(255, 220, 116, 184),
                                  Color.fromARGB(255, 245, 90, 13),
                                ],
                                series: <CircularSeries<_ChartData, String>>[
                                  DoughnutSeries<_ChartData, String>(
                                      dataSource: datachart,
                                      // Radius of doughnut's inner circle
                                      innerRadius: '50%',
                                      animationDuration: 3000,
                                      explode: true,
                                      explodeIndex: 20,
                                      xValueMapper: (_ChartData data, _) =>
                                          data.x,
                                      yValueMapper: (_ChartData data, _) =>
                                          data.y,
                                      dataLabelMapper: (_ChartData data, _) =>
                                          data.x,
                                      dataLabelSettings:
                                          const DataLabelSettings(
                                              isVisible: true,
                                              textStyle: TextStyle(
                                                  fontFamily:
                                                      "Port Lligat Slab"),
                                              // Avoid labels intersection
                                              labelIntersectAction:
                                                  LabelIntersectAction.shift,
                                              labelPosition:
                                                  ChartDataLabelPosition.inside,
                                              connectorLineSettings:
                                                  ConnectorLineSettings(
                                                      type: ConnectorType.curve,
                                                      length: '25%')),
                                      name: 'No of Tourist / Month')
                                ]),
                            const SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return DataTourism(
                                      data: dataTourism,
                                    );
                                  }));
                                },
                                child: Card(
                                  elevation: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        const Card(
                                          elevation: 15,
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child:
                                                Text("More of Tourism Details"),
                                          ),
                                        ),
                                        const Card(
                                          elevation: 15,
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(".............."),
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              getProportionateScreenHeight(40),
                                          width:
                                              getProportionateScreenWidth(40),
                                          child: Card(
                                            elevation: 10,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.asset(
                                                  "assets/images/forward.png"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 1, right: 1, top: 10),
                        child: Card(
                          elevation: 10,
                          child: Column(
                            children: [
                              const Text(
                                "DBH against Height Line Graph",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              Card(
                                elevation: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: getProportionateScreenHeight(200),
                                    width: double.infinity,
                                    child: FadeInUp(
                                      duration:
                                          const Duration(milliseconds: 1300),
                                      child: LineChart(
                                        mainData(),
                                        swapAnimationDuration:
                                            const Duration(milliseconds: 800),
                                        swapAnimationCurve: Curves.linear,
                                      ),
                                    ),
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
                                                backgroundColor:
                                                    Colors.grey[200],
                                                child: Image.asset(
                                                    "assets/images/volume.jpg")),
                                            const Text(
                                              "Total Volume ",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            Text(
                                                data["total_volume"] + " (cbm)")
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
                                                backgroundColor:
                                                    Colors.grey[200],
                                                child: Image.asset(
                                                    "assets/images/map.png")),
                                            const Text(
                                              "Total Area ",
                                              style: TextStyle(
                                                  color: Colors.black),
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
                                                backgroundColor:
                                                    Colors.grey[200],
                                                child: Image.asset(
                                                    "assets/images/tree.png")),
                                            const Text(
                                              "Living Tree",
                                              style: TextStyle(
                                                  color: Colors.black),
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
                                                backgroundColor:
                                                    Colors.grey[200],
                                                child: Image.asset(
                                                    "assets/images/dead-tree.png")),
                                            const Text(
                                              "Dead Tree",
                                              style: TextStyle(
                                                  color: Colors.black),
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
                                                backgroundColor:
                                                    Colors.grey[200],
                                                child: Image.asset(
                                                    "assets/images/tree.png")),
                                            const Text(
                                              "Survival Rate For Young Trees(Age Below 3 Years)",
                                              style: TextStyle(
                                                  color: Colors.black),
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
                        ),
                      )
                    ],
                  ),
                ),
              ),
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

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
