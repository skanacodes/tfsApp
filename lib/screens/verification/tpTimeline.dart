import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:timelines/timelines.dart';

class TPtimeline extends StatefulWidget {
  static String routeName = "/Timeline";
  final String? tpNumber;
  TPtimeline({Key? key, this.tpNumber}) : super(key: key);

  @override
  State<TPtimeline> createState() => _TPtimelineState();
}

class _TPtimelineState extends State<TPtimeline> {
  String? type;
  String? controlNo;
  List data = [];

  bool isLoading = false;

  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String pastMonth = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(Duration(days: 30)));
  String pastWeek = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(Duration(days: 7)));
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      print(widget.tpNumber);
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      var checkpoint = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('checkpointId'));
      var headers = {"Authorization": "Bearer " + tokens!};
      var url = Uri.parse(
          'https://mis.tfs.go.tz/fremis-test/api/v1/expected-tp/routes/${widget.tpNumber}/${checkpoint}');
      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);

            data = res['data'];

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
    _refreshController.refreshCompleted();
  }

  messages(
    String type,
    String desc,
  ) {
    return Alert(
      style: AlertStyle(descStyle: TextStyle(fontSize: 17)),
      context: context,
      type: type == 'success'
          ? AlertType.success
          : type == "info"
              ? AlertType.info
              : AlertType.error,
      // title: 'Information',
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            if (type == 'success') {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
          width: 120,
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
        backgroundColor: kPrimaryColor,
        title: Text(
          'TP Timeline ',
          style: TextStyle(color: Colors.white, fontFamily: "Ubuntu"),
        ),
      ),
      body: isLoading
          ? SpinKitCircle(
              color: kPrimaryColor,
            )
          : ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                final tpdata = data.reversed.toList();
                return Center(
                  child: Container(
                    width: 360.0,
                    child: Card(
                      margin: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: _OrderTitle(
                              checkpointInfo: tpdata[index]["checkpoint"]
                                  ["checkpoint_name"],
                              verTime: tpdata[index]["checkpoint"]
                                      ["verification_time"]
                                  .toString(),
                            ),
                          ),
                          Divider(height: 1.0),
                          _DeliveryProcesses(processes: tpdata),
                          Divider(height: 1.0),
                          tpdata[index]["checkpoint"] != null
                              ? Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: _OnTimeBar(
                                      driver: tpdata[index]["checkpoint"]
                                              ["verification_code"]
                                          .toString()),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _OrderTitle extends StatelessWidget {
  const _OrderTitle({
    Key? key,
    required this.checkpointInfo,
    required this.verTime,
  }) : super(key: key);

  final String checkpointInfo;
  final String verTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'TP Details: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Ubuntu"),
          ),
        ),
        Spacer(),
        // Expanded(
        //   child: Text(
        //     'TP',
        //     style: TextStyle(
        //       color: Color(0xffb6b2b2),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class _InnerTimeline extends StatelessWidget {
  const _InnerTimeline({
    required this.messages,
  });

  final List messages;

  @override
  Widget build(BuildContext context) {
    bool isEdgeIndex(int index) {
      return index == 0 || index == messages.length + 1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        elevation: 20,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FixedTimeline.tileBuilder(
            theme: TimelineTheme.of(context).copyWith(
              nodePosition: 0,
              connectorTheme: TimelineTheme.of(context).connectorTheme.copyWith(
                    thickness: 1.0,
                  ),
              indicatorTheme: TimelineTheme.of(context).indicatorTheme.copyWith(
                    size: 10.0,
                    position: 0.5,
                  ),
            ),
            builder: TimelineTileBuilder(
              indicatorBuilder: (_, index) => !isEdgeIndex(index)
                  ? Indicator.outlined(borderWidth: 1.0)
                  : null,
              startConnectorBuilder: (_, index) => Connector.solidLine(),
              endConnectorBuilder: (_, index) => Connector.dashedLine(),
              contentsBuilder: (_, index) {
                if (isEdgeIndex(index)) {
                  return null;
                }

                return Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(messages[index - 1].toString()),
                );
              },
              itemExtentBuilder: (_, index) => isEdgeIndex(index) ? 10.0 : 30.0,
              nodeItemOverlapBuilder: (_, index) =>
                  isEdgeIndex(index) ? true : null,
              itemCount: messages.length + 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryProcesses extends StatelessWidget {
  const _DeliveryProcesses({Key? key, required this.processes})
      : super(key: key);

  final List processes;
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 12.5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            color: Color(0xff989898),
            indicatorTheme: IndicatorThemeData(
              position: 0,
              size: 20.0,
            ),
            connectorTheme: ConnectorThemeData(
              thickness: 2.5,
            ),
          ),
          builder: TimelineTileBuilder.connected(
              connectionDirection: ConnectionDirection.after,
              itemCount: processes.length,
              contentsBuilder: (_, index) {
                //if (processes[index].isCompleted) return null;

                return Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        processes[index]["checkpoint"]["checkpoint_name"]
                                .toString() +
                            " Checkpoint",
                        style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Ubuntu"),
                      ),
                      _InnerTimeline(messages: [
                        processes[index]["checkpoint"]["verification_time"] !=
                                null
                            ? "Verification-Time: " +
                                processes[index]["checkpoint"]
                                        ["verification_time"]
                                    .toString()
                            : "",
                        processes[index]["checkpoint"]["verification_code"] !=
                                null
                            ? "Verification-Code: " +
                                processes[index]["checkpoint"]
                                        ["verification_code"]
                                    .toString()
                            : "",
                        processes[index]["checkpoint"]["remarks"] != null
                            ? "Status: " +
                                processes[index]["checkpoint"]["remarks"]
                                    .toString()
                            : "",
                        processes[index]["checkpoint"]["verified_by"] != null
                            ? "Verified By: " +
                                processes[index]["checkpoint"]["verified_by"]
                                    .toString()
                                    .toUpperCase()
                            : "",
                      ]),
                    ],
                  ),
                );
              },
              indicatorBuilder: (_, index) {
                if (processes[index]["checkpoint"]["remarks"].toString() ==
                    "Verified") {
                  return DotIndicator(
                    color: Color(0xff66c97f),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12.0,
                    ),
                  );
                }
                if (processes[index]["checkpoint"]["remarks"].toString() ==
                    "Compounded For Skipping Checkpoint") {
                  return DotIndicator(
                    color: Color.fromARGB(255, 223, 109, 16),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12.0,
                    ),
                  );
                }
                if (processes[index]["checkpoint"]["remarks"].toString() ==
                    "Scheduled") {
                  return DotIndicator(
                    color: Color.fromARGB(255, 180, 181, 182),
                    child: Icon(
                      Icons.pending_actions,
                      color: Colors.white,
                      size: 12.0,
                    ),
                  );
                }
                return null;
              },
              connectorBuilder: (_, index, ___) {
                // print(processes[0]["checkpoint"]["remarks"]);

                if (processes[index]["checkpoint"]["remarks"].toString() ==
                    "Verified") {
                  return SolidLineConnector(
                    color: Color(0xff66c97f),
                  );
                }
                if (processes[index]["checkpoint"]["remarks"].toString() ==
                    "Compounded For Skipping Checkpoint") {
                  return SolidLineConnector(
                    color: Color.fromARGB(255, 223, 109, 16),
                  );
                }
                if (processes[index]["checkpoint"]["remarks"].toString() ==
                    "Scheduled") {
                  return SolidLineConnector(
                    color: Color.fromARGB(255, 180, 181, 182),
                  );
                }
                return null;
              }),
        ),
      ),
    );
  }
}

class _OnTimeBar extends StatelessWidget {
  const _OnTimeBar({Key? key, required this.driver}) : super(key: key);

  final String driver;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MaterialButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Route!'),
              ),
            );
          },
          elevation: 0,
          shape: StadiumBorder(),
          color: Color(0xff66c97f),
          textColor: Colors.white,
          child: Text('Route Map Of TP'),
        ),
        Spacer(),
        Text(
          '',
          textAlign: TextAlign.center,
        ),
        SizedBox(width: 12.0),
        // Container(
        //   width: 40.0,
        //   height: 40.0,
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     image: DecorationImage(
        //       fit: BoxFit.fitWidth,
        //       image: NetworkImage(
        //         'https://i.pinimg.com/originals/08/45/81/084581e3155d339376bf1d0e17979dc6.jpg',
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
