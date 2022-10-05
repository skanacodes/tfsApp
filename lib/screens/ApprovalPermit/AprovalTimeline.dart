// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:timelines/timelines.dart';

class ApprovalTimeline extends StatefulWidget {
  final List data;
  const ApprovalTimeline({Key? key, required this.data}) : super(key: key);

  @override
  State<ApprovalTimeline> createState() => _ApprovalTimelineState();
}

class _ApprovalTimelineState extends State<ApprovalTimeline> {
  String? type;
  String? controlNo;
  List data = [];

  bool isLoading = false;

  @override
  void initState() {
    // getData();
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
          'Approvals Request Timeline',
          style: TextStyle(
              color: Colors.white, fontFamily: "Ubuntu", fontSize: 11.sp),
        ),
      ),
      body: isLoading
          ? const SpinKitCircle(
              color: kPrimaryColor,
            )
          : ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                final tpdata = widget.data.reversed.toList();
                //print(tpdata);
                return Center(
                  child: SizedBox(
                    width: getProportionateScreenWidth(400),
                    child: Card(
                      margin: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.all(20.0),
                          //   child: _OrderTitle(
                          //     checkpointInfo: tpdata[index],
                          //     verTime: tpdata[index],
                          //   ),
                          // ),
                          const Divider(height: 1.0),
                          _DeliveryProcesses(processes: tpdata),
                          const Divider(height: 1.0),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: _OnTimeBar(driver: tpdata[index].toString()),
                          ),
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
      children: const [
        Expanded(
          child: Text(
            'Approvals Request Timeline',
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
        shape: const RoundedRectangleBorder(
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
                  padding: const EdgeInsets.only(left: 8.0),
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
      style: const TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 12.5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            color: const Color(0xff989898),
            indicatorTheme: const IndicatorThemeData(
              position: 0,
              size: 20.0,
            ),
            connectorTheme: const ConnectorThemeData(
              thickness: 2.5,
            ),
          ),
          builder: TimelineTileBuilder.connected(
              connectionDirection: ConnectionDirection.after,
              itemCount: processes.length,
              contentsBuilder: (_, index) {
                //if (processes[index].isCompleted) return null;

                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        index == 0
                            ? "Client/DFC"
                            : index == 1
                                ? "Zonal Manager"
                                : index == 2
                                    ? "Licensing Officer"
                                    : "DMRU",
                        style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontFamily: "Ubuntu"),
                      ),
                      _InnerTimeline(messages: [
                        index == 0
                            ? processes[index] == ""
                                ? "Scheduled"
                                : "Submitted Time: ${processes[index]} "
                            : index == 1
                                ? processes[index] == ""
                                    ? "Scheduled"
                                    : "Review Time: ${processes[index]} "
                                : index == 2
                                    ? processes[index] == ""
                                        ? "Scheduled"
                                        : "Assessment Time: ${processes[index]} "
                                    : processes[index] == ""
                                        ? "Scheduled"
                                        : "Review Time: ${processes[index]} ",
                        " ",
                        "",
                      ]),
                    ],
                  ),
                );
              },
              indicatorBuilder: (_, index) {
                return const DotIndicator(
                  color: Color(0xff66c97f),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12.0,
                  ),
                );
              },
              connectorBuilder: (_, index, ___) {
                // ////print((processes[0]["checkpoint"]["remarks"]);

                return const SolidLineConnector(
                  color: Color.fromARGB(255, 180, 181, 182),
                );
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
              const SnackBar(
                content: Text('Approve TimeLine!'),
              ),
            );
          },
          elevation: 0,
          shape: const StadiumBorder(),
          color: const Color(0xff66c97f),
          textColor: Colors.white,
          child: const Text('Route Map Of Approve Requests'),
        ),
        const Spacer(),
        const Text(
          '',
          textAlign: TextAlign.center,
        ),
        const SizedBox(width: 12.0),
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
