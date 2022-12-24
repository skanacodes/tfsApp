// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tfsappv1/services/constants.dart';

import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfPreviewComponent extends StatefulWidget {
  final String? path;
  final String? name;
  final bool? letterType;
  final String? id;

  const PdfPreviewComponent(
      {Key? key, this.path, this.name, this.letterType, this.id})
      : super(key: key);

  @override
  State<PdfPreviewComponent> createState() => _PdfPreviewComponentState();
}

class _PdfPreviewComponentState extends State<PdfPreviewComponent> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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
              ? IconButton(
                  icon: const Icon(
                    Icons.save_outlined,
                    color: Colors.white,
                    semanticLabel: 'Save Data',
                  ),
                  onPressed: () async {
                    await approveletter();
                  },
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
      body: SfPdfViewer.network(
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
