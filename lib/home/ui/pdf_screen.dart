import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFScreen extends StatefulWidget {
  const PDFScreen({Key? key, required  this.isTermsAndConditions}) : super(key: key);
  final bool isTermsAndConditions;

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfPdfViewer.asset(widget.isTermsAndConditions ? "assets/pdf/tc.pdf" : "assets/pdf/pp.pdf"),
    );
  }
}
