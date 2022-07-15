// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tfsappv1/screens/charts/charts_screen.dart';
import 'package:tfsappv1/screens/dashboard/card_item.dart';

class CardList extends StatefulWidget {
  const CardList({Key? key}) : super(key: key);

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  List dataFremis = [];
  List dataExport = [];
  List dataDealers = [];
  List dataSeed = [];
  List cardDatas = [];

  void getStatsFremis() async {
    setState(() {});
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('http://41.59.82.189:5555/api/v1/transitpass/all');

      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
     // print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            dataFremis = res["data"]["tp_by_prod"];
            var dt = {
              "name": "Transit Pass",
              "total": res["data"]["total_tp"].toString(),
              "totalrevenue": res["data"]["total_tp_revenue"].toString(),
              "ratio": 70,
              "color": Colors.orange
            };
            cardDatas.add(dt);
            // print(dataFremis);
            // print(dt);
            // print(cardDatas);
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
          });

          break;
      }
    } catch (e) {
      setState(() {});
    }
  }

  void getStatDealer() async {
    setState(() {});
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('http://41.59.82.189:5555/api/v1/dealers/all');

      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
     // print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            dataDealers = res["data"]["revenue_by_cat"];
            var dt = {
              "name": "Dealers",
              "total": res["data"]["total"].toString(),
              "totalrevenue": res["data"]["revenue"].toString(),
              "ratio": 30,
              "color": Colors.purple
            };
            cardDatas.add(dt);
          });
          break;

        default:
          setState(() {
            res = json.decode(response.body);
          });

          break;
      }
    } catch (e) {
      setState(() {});
    }
  }

  void getStatSeed() async {
    setState(() {});
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('http://41.59.82.189:5555/api/v1/seed/all');

      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
     // print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            dataSeed = res["data"]["seed"]["revenue_by_specie"];

            var dt = {
              "name": "Seed",
              "total": res["data"]["seed"]["total"].toString(),
              "totalrevenue": res["data"]["seed"]["revenue"].toString(),
              "ratio": 50,
              "color": Colors.red
            };
            cardDatas.add(dt);
          });
          break;

        default:
          setState(() {
            res = json.decode(response.body);
          });

          break;
      }
    } catch (e) {
      setState(() {});
    }
  }

  getStatsExport() async {
    setState(() {});
    try {
      // var tokens = await SharedPreferences.getInstance()
      //     .then((prefs) => prefs.getString('token'));
      // var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse('http://41.59.82.189:5555/api/v1/exports/all');

      final response = await http.get(
        url,
      );
      var res;
      //final sharedP prefs=await
     // print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            dataExport = res["data"]["export"]["revenue_by_country"];
            var dt = {
              "name": "Export",
              "total": res["data"]["export"]["total"].toString(),
              "totalrevenue": res["data"]["export"]["revenue"].toString(),
              "ratio": 70,
              "color": Colors.pink
            };
            cardDatas.add(dt);
          });

          break;

        default:
          setState(() {
            res = json.decode(response.body);
          });

          break;
      }
    } catch (e) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getStatsFremis();
    getStatDealer();
    getStatsExport();
    getStatSeed();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: cardDatas.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: (() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChartsScreen(
                            data: dataFremis,
                          )));
            }),
            child: CardItem(
              logo: cardDatas[index]["name"].toString(),
              number: cardDatas[index]["total"].toString(),
              holder: cardDatas[index]["totalrevenue"].toString(),
              type: cardDatas[index]["name"].toString(),
              ratio: cardDatas[index]["ratio"],
              color: cardDatas[index]["color"],
            ),
          );
        },
      ),
    );
  }
}
