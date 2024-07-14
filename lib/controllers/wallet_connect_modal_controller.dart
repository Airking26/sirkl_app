import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:sirkl/common/model/crypto/chain_metadata.dart';
import 'package:sirkl/common/model/crypto/eip155.dart';
import 'package:sirkl/common/model/crypto/helpers.dart';
import 'package:sirkl/common/model/crypto/test_data.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:bip39/bip39.dart' as bip39;

class WalletConnectModalController extends GetxController {
  Rx<W3MService?> w3mService = (null as W3MService?).obs;

  HomeController get _homeController => Get.find<HomeController>();
  var name = "Sirkl.io";
  var desc = "Sirkl.io Login";
  var url = "https://sirkl.io/";
  var icons = [
    "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png"
  ];
  var nativeUrl = "sirkl://";
  var universalUrl = 'https://walletconnect.com/appkit';
  var projectID = "bdfe4b74c44308ffb46fa4e6198605af";

  var isInitialized = false.obs;

  void initializeService(BuildContext context) async {
    //W3MChainPresets.chains.putIfAbsent('1564830818', () => W3MChainInfo(chainName: "SKALE Calypso Hub", chainId: '1564830818', namespace: "eip155:1564830818", tokenName: "sFuel", rpcUrl: "https://mainnet.skalenodes.com/v1/honorable-steel-rasalhague"));

    w3mService.value = W3MService(
      context: context,
      projectId: projectID,
      logLevel: LogLevel.error,
      metadata: PairingMetadata(
        name: name,
        description: desc,
        url: url,
        icons: icons,
        redirect: Redirect(
          native: nativeUrl,
          universal: universalUrl,
        ),
      ),
    );


    w3mService.value?.onModalConnect.subscribe(_onModalConnect);
    w3mService.value?.onModalNetworkChange.subscribe(_onModalNetworkChange);
    w3mService.value?.onModalDisconnect.subscribe(_onModalDisconnect);
    w3mService.value?.onModalError.subscribe(_onModalError);

    //
    w3mService.value?.onSessionExpireEvent.subscribe(_onSessionExpired);
    w3mService.value?.onSessionUpdateEvent.subscribe(_onSessionUpdate);
    w3mService.value?.onSessionEventEvent.subscribe(_onSessionEvent);

    //
    w3mService.value?.web3App!.core.relayClient.onRelayClientConnect
        .subscribe(_onRelayClientConnect);
    w3mService.value?.web3App!.core.relayClient.onRelayClientError
        .subscribe(_onRelayClientError);
    w3mService.value?.web3App!.core.relayClient.onRelayClientDisconnect
        .subscribe(_onRelayClientDisconnect);


    await w3mService.value?.init();
  }

  void _onModalConnect(ModalConnect? event) {
    debugPrint('[ExampleApp] _onModalConnect ${event?.toString()}');
    debugPrint('[ExampleApp] _onModalConnect selectedChain ${w3mService.value?.selectedChain?.chainId}');
    debugPrint('[ExampleApp] _onModalConnect address ${w3mService.value?.session!.address}');
    _homeController.address.value = w3mService.value!.session!.address!.toLowerCase();
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    debugPrint('[ExampleApp] _onModalNetworkChange ${event?.toString()}');
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    debugPrint('[ExampleApp] _onModalDisconnect ${event?.toString()}');
  }

  void _onModalError(ModalError? event) {
    debugPrint('[ExampleApp] _onModalError ${event?.toString()}');
    if ((event?.message ?? '').contains('Coinbase Wallet Error')) {
      w3mService.value?.disconnect();
    }
  }

  void _onSessionExpired(SessionExpire? event) {
    debugPrint('[ExampleApp] _onSessionExpired ${event?.toString()}');
  }

  void _onSessionUpdate(SessionUpdate? event) {
    debugPrint('[ExampleApp] _onSessionUpdate ${event?.toString()}');
  }

  void _onSessionEvent(SessionEvent? event) {
    debugPrint('[ExampleApp] _onSessionEvent ${event?.toString()}');
  }

  void _onRelayClientConnect(EventArgs? event) {
    debugPrint('[ExampleApp] _onSessionEvent ${event?.toString()}');
    isInitialized.value = true;
  }

  void _onRelayClientError(EventArgs? event) {
    debugPrint('[ExampleApp] _onRelayClientError ${event?.toString()}');
  }

  void _onRelayClientDisconnect(EventArgs? event) {
    debugPrint('[ExampleApp] _onSessionEvent ${event?.toString()}');
  }

  signMessageWithWC(BuildContext context) async {
    String? accountNameSpace;
    final accounts = w3mService.value!.session?.getAccounts() ?? [];
    final currentNamespace = w3mService.value!.selectedChain?.namespace;
    final chainsNamespaces = NamespaceUtils.getChainsFromAccounts(accounts);
    if (chainsNamespaces.contains(currentNamespace)) {
      accountNameSpace = accounts.firstWhere(
        (account) => account.contains('$currentNamespace:'),
      );
    }

    final chainId = NamespaceUtils.getChainFromAccount(
        accountNameSpace ?? w3mService.value!.selectedChain!.namespace);
    final account = NamespaceUtils.getAccount(
        accountNameSpace ?? w3mService.value!.selectedChain!.namespace);
    final chainMetadata = getChainMetadataFromChain(chainId);

    w3mService.value!.launchConnectedWallet();

    callChainMethod(
      ChainType.eip155,
      EIP155UIMethods.personalSign,
      chainMetadata,
      account,
    ).then((value) async {
      await _homeController.loginWithWallet(
          context,
          account.toLowerCase(),
          testSignData(account.toLowerCase()),
          value.toString());
    });
  }

  Future<dynamic> callChainMethod(
    ChainType type,
    EIP155UIMethods method,
    ChainMetadata chainMetadata,
    String address,
  ) {
    switch (type) {
      case ChainType.eip155:
        return EIP155.callMethod(
          w3mService: w3mService.value!,
          topic: w3mService.value!.session!.topic ?? "",
          method: method,
          chainId: chainMetadata.w3mChainInfo.namespace,
          address: address.toLowerCase(),
        );
      default:
        return Future<dynamic>.value();
    }
  }

  Future<void> createWallet(BuildContext context) async {
    final mnemonic = bip39.generateMnemonic();
    final seed = bip39.mnemonicToSeed(mnemonic);
    final privateKey = EthPrivateKey.fromHex(seedToPrivateKey(seed));
    final address = privateKey.address.hex;

    await _signMessageLocally(context, bytesToHex(privateKey.privateKey), address);
  }

  String seedToPrivateKey(Uint8List seed) {
    final sha256 = SHA256Digest();
    final privateKeyBytes = sha256.process(seed);
    return bytesToHex(privateKeyBytes);
  }

  Future<void> _signMessageLocally(
      BuildContext context, String? privateKey, String wallet) async {
    if (privateKey == null) return;

    final privateKeyFromHex = EthPrivateKey.fromHex(privateKey);
    final encodedMessage = Uint8List.fromList(utf8.encode(testSignData(wallet.toLowerCase())));
    final signedMessage = privateKeyFromHex.signPersonalMessageToUint8List(encodedMessage);
    final signature = "0x${bytesToHex(signedMessage)}";

    await _homeController.loginWithWallet(context, wallet.toLowerCase(), testSignData(wallet.toLowerCase()), signature);
  }

  retrieveWalletFromMnemonic(String mnemonic) {
    final isValidLength = mnemonic.split(' ').length >= 12;
    if(isValidLength) {
      if(bip39.validateMnemonic(mnemonic)) {
        final seed = bip39.mnemonicToSeed(mnemonic);
        final privateKey = EthPrivateKey.fromHex(seedToPrivateKey(seed));
        final address = privateKey.address.hex;
      } else {

      }
    } else {

    }
  }
}
