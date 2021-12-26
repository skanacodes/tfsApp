import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ota_update/ota_update.dart';

import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class UpdateApp extends StatefulWidget {
  static String routeName = "/UpdateApp";
  UpdateApp({Key? key}) : super(key: key);

  @override
  _UpdateAppState createState() => _UpdateAppState();
}

class _UpdateAppState extends State<UpdateApp> {
  OtaEvent? currentEvent;
  int percentage = 0;
  Future<void> tryOtaUpdate() async {
    try {
      //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
      OtaUpdate()
          .execute(
        'http://mis.tfs.go.tz/fremis/download_APK',

        destinationFilename: 'app-release.apk',
        //FOR NOW ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
      )
          .listen(
        (OtaEvent event) {
          setState(() {
            currentEvent = event;
            percentage = int.parse(currentEvent!.value!);
          });
        },
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print('Failed to make TFSApp update. Details: $e');
    }
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
          text: "TFSApp",
          style: GoogleFonts.portLligatSlab(
            textStyle: Theme.of(context).textTheme.bodyText1,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: ' Upda',
              style: TextStyle(color: Colors.green[400], fontSize: 15.sp),
            ),
            TextSpan(
              text: "tes",
              style: TextStyle(color: kPrimaryColor, fontSize: 15.sp),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // currentEvent == null
    //     ? print("90")
    //     : setState(() {
    //         print(currentEvent!.value! + "hgfyuuy");
    //         //percentage = currentEvent!.value!;
    //       });
    //print("biuld");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          '',
          style: TextStyle(
              fontFamily: 'Ubuntu', color: Colors.black, fontSize: 15),
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: getProportionateScreenHeight(70),
                color: Colors.white,
                // decoration: BoxDecoration(color: Colors.white),
              ),
              Container(
                height: getProportionateScreenHeight(50),
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
                        child: Icon(Icons.update),
                      ),
                      title: _title(),
                      trailing: Icon(
                        Icons.format_align_justify,
                        color: Colors.pink,
                      ),
                      tileColor: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: getProportionateScreenHeight(10),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  CircularStepProgressIndicator(
                    totalSteps: 100,
                    currentStep: percentage,
                    stepSize: 1,
                    selectedColor: Colors.green,
                    padding: 0,
                    unselectedColor: Colors.grey[400],
                    width: 200,
                    height: 200,
                    selectedStepSize: 15,
                    roundedCap: (_, __) => true,
                    child: currentEvent == null
                        ? Container()
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    currentEvent!.status == ""
                                        ? "100%"
                                        : '${currentEvent!.value}% \n',
                                    style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(100),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 10,
              child: ListTile(
                onTap: () async {
                  await tryOtaUpdate();
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.upgrade,
                    color: Colors.green,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.pink,
                ),
                title: Text("Click To Update App To The Latest Version"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
