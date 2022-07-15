import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartsScreen extends StatefulWidget {
  final List? data;
  static String routeName = "/charts";
  const ChartsScreen({Key? key, this.data}) : super(key: key);

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;

  populateData() {
    for (var i = 0; i < widget.data!.length; i++) {
      data.add(_ChartData(widget.data![i]["name"].toString(),
          double.parse(widget.data![i]["value"].toString())));
    }
  }

  @override
  void initState() {
    data = [];
    populateData();
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chart'),
        ),
        body: SfCartesianChart(
            primaryXAxis: CategoryAxis(),

            primaryYAxis:
                NumericAxis(minimum: 0, maximum: 100000, interval: 1000 ),
            tooltipBehavior: _tooltip,
            series: <ChartSeries<_ChartData, String>>[
              BarSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y,
                  name: 'Gold',
                  
                  color: const Color.fromRGBO(8, 142, 255, 1))
            ]));
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
