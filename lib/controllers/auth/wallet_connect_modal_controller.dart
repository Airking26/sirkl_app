import 'dart:convert';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:sirkl/common/save_pref_keys.dart';
import 'package:sirkl/controllers/auth/phantom_connect_service.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:sirkl/repositories/auth_repo.dart';
import 'package:sirkl/repositories/google_repo.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item.dart';

class WalletConnectModalController extends GetxController {
  HomeController get _homeController => Get.find<HomeController>();
  String messageToSign(String wallet) =>
      'Welcome to $wallet SIRKL.io by signing this message you agree to learn and have fun with blockchain';
  var name = "Sirkl.io";
  var desc = "Sirkl.io Login";
  var url = "https://sirkl.io/";
  var icons = [
    "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png"
  ];
  var nativeUrl = "sirkl://";
  var universalUrl =
      'http://sirklserver-env.eba-advpp2ip.eu-west-1.elasticbeanstalk.com';
  var projectID = "8b7c50c39f39c858c492ad3970d1ca55";

  var errorTextRetrieving = false.obs;

  final box = GetStorage();
  late W3MService? w3mService;
  late PhantomConnectService phantomConnectService;

  void initializeService(BuildContext context) async {
    phantomConnectService = PhantomConnectService(context);

    w3mService = W3MService(
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
      includedWalletIds: {
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // MetaMask
        '4622a2b2d6af1c9844944291e5e7351a6aa24cd7b23099efac1b2fd875da31a0', // Trust
        'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase
        '1ae92b26df02f0abca6304df07debccd18262fdf5fe82daa81593582dac9a369', // Rainbow
        '19177a98252e07ddfc9af2083ba8e07ef627cb6103467ffebb3f8f4205fd7927' // Ledger
      },
      context: context,
      projectId: projectID,
      logLevel: LogLevel.error,
      loginWithoutWalletWidget: Column(
        children: [
          WalletListItem(
            imageUrl:
                "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/channels4_profile.jpg",
            title: 'Phantom',
            onTap: () {
              phantomConnectService.connectToPhantom();
            },
          ),
          const SizedBox(
            height: 8,
          ),
          WalletListItem(
            title: "Connect without wallet",
            imageUrl:
                "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/no_wallet.png",
            onTap: () async {
              Get.back();
              _homeController.isLoading.value = true;
              await createWallet(context);
            },
          ),
        ],
      ),
    );

    w3mService?.onModalConnect.subscribe(_onModalConnect);

    await w3mService?.init();
  }

  void _onModalConnect(ModalConnect? event) {
    _homeController.address.value = event?.session.address?.toLowerCase() ?? "";
    if (event != null &&
        event.session.address != null &&
        event.session.address!.isNotEmpty) {
      w3mService?.closeModal();
    }
  }

  signWithWalletConnect(BuildContext context) async {
    String? accountNameSpace;
    final accounts = w3mService?.session?.getAccounts() ?? [];
    final currentNamespace = w3mService?.selectedChain?.namespace;
    final chainsNamespaces = NamespaceUtils.getChainsFromAccounts(accounts);
    if (chainsNamespaces.contains(currentNamespace)) {
      accountNameSpace = accounts.firstWhere(
        (account) => account.contains('$currentNamespace:'),
      );
    }

    final chainId = NamespaceUtils.getChainFromAccount(
        accountNameSpace ?? w3mService!.selectedChain!.namespace);
    final address = NamespaceUtils.getAccount(
        accountNameSpace ?? w3mService!.selectedChain!.namespace);

    try {
      w3mService?.launchConnectedWallet();
      await w3mService
          ?.request(
        topic: w3mService!.session!.topic!,
        chainId: chainId,
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [
            messageToSign(address.toLowerCase()),
            address.toLowerCase(),
          ],
        ),
      )
          .then((value) async {
        await _homeController.loginWithWallet(context, address.toLowerCase(),
            messageToSign(address.toLowerCase()), value.toString());
      });
    } catch (e) {
      _homeController.address.value = '';
    }
  }

  Future<void> createWallet(BuildContext context) async {
    _homeController.isLoading.value = true;
    _homeController.refresh();
    final mnemonic = bip39.generateMnemonic();
    final seed = bip39.mnemonicToSeed(mnemonic);
    final privateKey = EthPrivateKey.fromHex(_seedToPrivateKey(seed));
    final address = privateKey.address.hex;

    try {
      AppsflyerSdk appsflyerSdk = Get.find<AppsflyerSdk>();
      await appsflyerSdk.logEvent("af_login_without_wallet", {});
    } catch (e) {}

    await _signMessageLocally(
        context, bytesToHex(privateKey.privateKey), address, mnemonic);
  }

  String _seedToPrivateKey(Uint8List seed) {
    final sha256 = SHA256Digest();
    final privateKeyBytes = sha256.process(seed);
    return bytesToHex(privateKeyBytes);
  }

  Future<void> _signMessageLocally(
      BuildContext context, String? privateKey, String wallet,
      [String? mnemonic]) async {
    if (privateKey == null) return;

    final privateKeyFromHex = EthPrivateKey.fromHex(privateKey);
    final encodedMessage =
        Uint8List.fromList(utf8.encode(messageToSign(wallet.toLowerCase())));
    final signedMessage =
        privateKeyFromHex.signPersonalMessageToUint8List(encodedMessage);
    final signature = "0x${bytesToHex(signedMessage)}";

    await _homeController.loginWithWallet(context, wallet.toLowerCase(),
        messageToSign(wallet.toLowerCase()), signature);

    if (mnemonic != null) {
      box.write(SharedPref.SEED_PHRASE, mnemonic);
      if (context.mounted) await promptChoseBackupMethod(context);
    }

    _homeController.isLoading.value = false;
  }

  retrieveWalletFromMnemonic(BuildContext context, String mnemonic) async {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final privateKey = EthPrivateKey.fromHex(_seedToPrivateKey(seed));
    final address = privateKey.address.hex;
    if (await AuthRepo.isWalletUser(address)) {
      if (context.mounted) {
        await _signMessageLocally(
            context, bytesToHex(privateKey.privateKey), address);
        Get.back();
      }
    } else {
      errorTextRetrieving.value = true;
    }
  }
}
