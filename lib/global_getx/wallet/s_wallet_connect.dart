


import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import '../../config/s_config.dart';
class SWalletConnectController extends GetxController with StateMixin {
    String? uri;
    final int chainId;
    
    SWalletConnectController({required this.chainId});
    
    final WalletConnect  _connector = WalletConnect(
    bridge: SConfig.wBridgeUrl,
    
    clientMeta: const PeerMeta(
      name: SConfig.wAppName,
      description: 'SIRKL Login',
      
      url: SConfig.wUrl, 
      icons: [
        SConfig.wIcon
      ],
    ),
  );
    @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  // connectWallet();

  }
  WalletConnectSession? get session => _connector.connected? null: _connector.session;
  String? get address => session?.accounts.first;

  Future<WalletConnect> get connector async {
    if (_connector.connected) {
      
      return _connector;
    }
    await connectWallet();
  
    return _connector;
  }
  Future<void> connectWallet() async {
    _connector.on('connect', (SessionStatus session) async{
     
    });
    _connector.on('session_request', (WCSessionRequest payload) {
    
    });

    _connector.on('disconnect', (SessionStatus session) async {
    
    });
    if (!_connector.connected) {
   
    await _createSession();
  }


  }
  _createSession() async {
    Completer _completer = Completer();
           change(null, status: RxStatus.loading());
      await _connector.createSession(
        chainId: chainId,
        onDisplayUri: (uri) async {
      
          this.uri = uri;
          try{
            var isLaunched = await launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
              
            if(isLaunched == false) {
                  change(null, status: RxStatus.empty());
            } else {
                  change(null, status: RxStatus.success());
            }
          } on Exception {
             change(null, status: RxStatus.error());
          }
          _completer.complete();
        },
      );
      await _completer.future;
  }



}