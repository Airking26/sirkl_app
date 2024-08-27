import 'package:flutter/material.dart';
import 'package:sirkl/common/enums/pdf_type.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFScreen extends StatefulWidget {
  const PDFScreen({Key? key, required this.pdfType}) : super(key: key);
  final PDFType pdfType;

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  String get toRead {
    switch (widget.pdfType) {
      case PDFType.tc:
        return "assets/pdf/tc.pdf";
      // TODO: Handle this case.

      case PDFType.pp:
        return "assets/pdf/pp.pdf";

      case PDFType.all:
        return "assets/pdf/all.pdf";
    }
  }

  @override
  Widget build(BuildContext context) {
    // String toRead;

    // if(widget.isTermsAndConditions == 0) {
    //   toRead = ;
    // } else if(widget.isTermsAndConditions == 1) {
    //   toRead =
    // } else {
    //   toRead =
    // }

    return Scaffold(
      body: Column(
        children: [
          buildAppbar(context),
          Expanded(child: SfPdfViewer.asset(toRead)),
        ],
      ),
    );
  }

  Container buildAppbar(BuildContext context) {
    return Container(
      height: 115,
      margin: const EdgeInsets.only(bottom: 0.25),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 0.01), //(x,y)
            blurRadius: 0.01,
          ),
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF113751)
                  : Colors.white,
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF1E2032)
                  : Colors.white
            ]),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.keyboard_arrow_left_rounded,
                    size: 42,
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Image.asset(
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? "assets/images/logo_dark_theme.png"
                      : "assets/images/logo_light_theme.png",
                  height: 25,
                ),
              ),
              IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    "assets/images/edit.png",
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.transparent
                        : Colors.transparent,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
