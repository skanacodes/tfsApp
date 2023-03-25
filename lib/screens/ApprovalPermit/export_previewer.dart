import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tfsappv1/services/constants.dart';

import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExportPreviewer extends StatefulWidget {
  final String? path;
  final String? name;
  final bool? letterType;
  final String? id;
  const ExportPreviewer(
      {super.key, this.path, this.name, this.letterType, this.id});

  @override
  State<ExportPreviewer> createState() => _ExportPreviewerState();
}

class _ExportPreviewerState extends State<ExportPreviewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  verificationMessage(String hint, String message) {
    return Alert(
      context: context,
      type: hint == "info" ? AlertType.info : AlertType.success,
      title: "",
      desc: message,
      buttons: [
        DialogButton(
          color: kPrimaryColor,
          radius: const BorderRadius.all(Radius.circular(10)),
          onPressed: () async {
            Navigator.pop(context);

            await approveletter();
          },
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          color: Colors.red,
          radius: const BorderRadius.all(Radius.circular(10)),
          onPressed: () async {
            Navigator.pop(context);
          },
          width: 120,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  approveletter() async {
    setState(() {
      isLoading = true;
    });
    try {
      var tokens = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      //  print(tokens);
      print('$baseUrl/api/v1/exp-letter/confirm/${widget.id}');
      var headers = {"Authorization": "Bearer ${tokens!}"};
      var url = Uri.parse('$baseUrl/api/v1/exp-letter/confirm/${widget.id}');

      final response = await http.get(url, headers: headers);
      var res;
      //final sharedP prefs=await
      print(response.statusCode);
      print(response.body);
      switch (response.statusCode) {
        case 200:
          setState(() {
            res = json.decode(response.body);
            print(res);
            //data = res["data"];
            message("success", "Successfully Approved");
            print(res);
            isLoading = false;
          });

          return 'success';
          // ignore: dead_code
          break;

        default:
          setState(() {
            res = json.decode(response.body);
            print(res);
            message("error", "Successfully Approved");
            isLoading = false;
          });

          break;
      }
    } catch (e) {
      setState(() {
        print(e);
        message("error", e.toString());
        isLoading = false;
      });
      return 'fail';
    }
  }

  message(String hint, String message) {
    return Alert(
      context: context,
      type: hint == "error" ? AlertType.error : AlertType.success,
      title: "Information",
      desc: message,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "Ok",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name.toString(),
        ),
        backgroundColor: kPrimaryColor,
        actions: <Widget>[
          widget.letterType!
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: const ButtonStyle(),
                    onPressed: () async {
                      verificationMessage("info",
                          "Are You Sure You Want to Approve This Letters ?");
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : Container()
          // IconButton(
          //   icon: const Icon(
          //     Icons.approval_outlined,
          //     color: Colors.white,
          //     semanticLabel: 'Bookmark',
          //   ),
          //   onPressed: () {
          //     _pdfViewerKey.currentState?.openBookmarkView();
          //   },
          // ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CupertinoActivityIndicator(
                animating: true,
                radius: 13.sp,
              ),
            )
          : SfPdfViewer.network(
              widget.path.toString(),
              key: _pdfViewerKey,
              // canShowScrollStatus: true,
              // canShowScrollHead: true,
              // enableDoubleTapZooming: true,
              // enableTextSelection: true,
              // pageLayoutMode: PdfPageLayoutMode.continuous,
              // interactionMode: PdfInteractionMode.selection,
            ),
    );
  }
}
