import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFScreen extends StatefulWidget {
  const PDFScreen({Key? key, required  this.isTermsAndConditions}) : super(key: key);
  final int isTermsAndConditions;

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  @override
  Widget build(BuildContext context) {
    String toRead;
    if(widget.isTermsAndConditions == 0) {
      toRead = "assets/pdf/tc.pdf";
    } else if(widget.isTermsAndConditions == 1) {
      toRead = "assets/pdf/tc.pdf";
    } else {
      toRead = "assets/pdf/all.pdf";
    }
    return Scaffold(
      body: SfPdfViewer.asset(toRead),
    );
  }
}
