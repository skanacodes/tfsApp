// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tfsappv1/services/constants.dart';

class PdfPreviewComponent extends StatefulWidget {
  final String? path;
  final String? name;

  const PdfPreviewComponent({Key? key, this.path, this.name}) : super(key: key);

  @override
  State<PdfPreviewComponent> createState() => _PdfPreviewComponentState();
}

class _PdfPreviewComponentState extends State<PdfPreviewComponent> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name.toString(),
          style: TextStyle(
              color: Colors.white, fontFamily: 'ubuntu', fontSize: 11.sp),
        ),
        backgroundColor: kPrimaryColor,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.white,
              semanticLabel: 'Bookmark',
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
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
