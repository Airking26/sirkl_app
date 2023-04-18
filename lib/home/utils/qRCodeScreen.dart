import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sirkl/common/model/wallet_connect_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({Key? key}) : super(key: key);

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var result;
  QRViewController? controller;
  final _homeController = Get.put(HomeController());


  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: (result != null)
                    ? Text(
                    'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                    : const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text("Generate your QR code from app.sirkl.io by accessing the 'device connect' section from the login page or the settings page",
                textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, fontFamily: "Gilroy"),),
                    ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
        var walletConnectDTO = walletConnectDtoFromJson(scanData.code!);
        _homeController.address.value = walletConnectDTO.wallet!;
        await _homeController.loginWithWallet(context, walletConnectDTO.wallet!, walletConnectDTO.message!, walletConnectDTO.signature!);

    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
