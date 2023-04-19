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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E2032) : Colors.white
            ]),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 44.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: ImageIcon(const AssetImage(
                    "assets/images/arrow_left.png",
                  ),color:  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Image.asset(
                  MediaQuery.of(context).platformBrightness == Brightness.dark ? "assets/images/logo_dark_theme.png" : "assets/images/logo_light_theme.png",
                  height: 25,
                ),
              ),
              IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    "assets/images/edit.png",
                    color:MediaQuery.of(context).platformBrightness == Brightness.dark
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
