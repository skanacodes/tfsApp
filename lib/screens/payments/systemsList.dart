import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/payments/billsDashboard.dart';
import 'package:tfsappv1/screens/payments/paymentList.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:sizer/sizer.dart';

class ListSystems extends StatefulWidget {
  static String routeName = "/listsystems";
  ListSystems({Key? key}) : super(key: key);

  @override
  _ListSystemsState createState() => _ListSystemsState();
}

class _ListSystemsState extends State<ListSystems> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Generate Bill Per Each System',
          style: TextStyle(
              color: Colors.black, fontFamily: 'Ubuntu', fontSize: 17),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 60.h,
            // color: kPrimaryColor,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 9.h,
                  color: kPrimaryColor,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      color: Colors.transparent,
                      child: AnimationLimiter(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 5,
                          itemBuilder: (BuildContext context, int index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 1075),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Card(
                                    elevation: 10,
                                    shadowColor: Colors.grey,
                                    child: Container(
                                      child: ListTile(
                                        onTap: () {
                                          // index == 0
                                          //     ? showModal()
                                          //     : print('sahs');
                                          index == 0
                                              ? Navigator.push(context, MaterialPageRoute(builder: (context) => BillsDashBoard("Fremis"))).then(
                                                  (_) => RealTimeCommunication()
                                                      .createConnection("3"))
                                              : index == 1
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              BillsDashBoard("seedMIS"))).then(
                                                      (_) => RealTimeCommunication()
                                                          .createConnection("3"))
                                                  : index == 2
                                                      ? Navigator.push(context, MaterialPageRoute(builder: (context) => BillsDashBoard("HoneyTraceability"))).then((_) => RealTimeCommunication().createConnection("3"))
                                                      : index == 3
                                                          ? Navigator.push(context, MaterialPageRoute(builder: (context) => BillsDashBoard("E-Auction"))).then((_) => RealTimeCommunication().createConnection("3"))
                                                          : Navigator.pushNamed(
                                                              context,
                                                              PaymentList
                                                                  .routeName,
                                                            ).then((_) => RealTimeCommunication().createConnection("3"));
                                        },
                                        trailing: Icon(
                                          Icons.arrow_right,
                                          color: Colors.cyan,
                                        ),
                                        leading: CircleAvatar(
                                            child: Icon(Icons.list)),
                                        title: Text(index == 0
                                            ? "FreMIS Bills"
                                            : index == 1
                                                ? "SeedMIS Bills"
                                                : index == 2
                                                    ? "HoneyTraceability"
                                                    : index == 3
                                                        ? "E-Auction"
                                                        : "PMIS"),
                                      ),
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  showModal() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: new Icon(
                  Icons.select_all_outlined,
                  color: Colors.green,
                ),
                title: new Text('Select The Type Of Inspection'),
              ),
              ListTile(
                leading: new Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                title: new Text('Apiaries inspections'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigator.pushNamed(
                  //   context,
                  //   InspectionJobs.routeName,
                  // );
                },
              ),
              ListTile(
                leading: new Icon(
                  Icons.arrow_right,
                  color: Colors.green,
                ),
                title: new Text('Other Inspections'),
                onTap: () {
                  // Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
