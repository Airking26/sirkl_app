import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:sirkl/common/model/crypto/chain_metadata.dart';
import 'package:sirkl/common/model/crypto/eip155.dart';
import 'package:sirkl/common/model/crypto/helpers.dart';
import 'package:sirkl/common/model/crypto/test_data.dart';
import 'package:sirkl/common/save_pref_keys.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:sirkl/repo/auth_repo.dart';
import 'package:sirkl/repo/google_repo.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/lists/list_items/wallet_list_item.dart';

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
  var universalUrl = 'http://www.sirklserver-env.eba-advpp2ip.eu-west-1.elasticbeanstalk.com';
  var projectID = "bdfe4b74c44308ffb46fa4e6198605af";

  var errorTextRetrieving = false.obs;

  final box = GetStorage();

  void initializeService(BuildContext context) async {

    w3mService.value = W3MService(
      includedWalletIds: {
        'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // MetaMask
        '4622a2b2d6af1c9844944291e5e7351a6aa24cd7b23099efac1b2fd875da31a0', // Trust
        'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase
        '1ae92b26df02f0abca6304df07debccd18262fdf5fe82daa81593582dac9a369', // Rainbow
        'a797aa35c0fadbfc1a53e7f675162ed5226968b44a19ee3d24385c64d1d3c393', // Phantom
        '19177a98252e07ddfc9af2083ba8e07ef627cb6103467ffebb3f8f4205fd7927' // Ledger
      },
      context: context,
      projectId: projectID,
      logLevel: LogLevel.error,
      loginWithoutWalletWidget: WalletListItem(title: "Connect without wallet", imageUrl: "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/no_wallet.png",
      onTap: () async {
        Get.back();
        _homeController.isLoading.value = true;
        await createWallet(context);
      },),
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

    w3mService.value?.onSessionExpireEvent.subscribe(_onSessionExpired);
    w3mService.value?.onSessionUpdateEvent.subscribe(_onSessionUpdate);
    w3mService.value?.onSessionEventEvent.subscribe(_onSessionEvent);

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

    callChainMethod(ChainType.eip155, EIP155UIMethods.personalSign, chainMetadata, account,)
        .then((value) async {
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
    _homeController.isLoading.value = true;
    _homeController.refresh();
    final mnemonic = bip39.generateMnemonic();
    final seed = bip39.mnemonicToSeed(mnemonic);
    final privateKey = EthPrivateKey.fromHex(seedToPrivateKey(seed));
    final address = privateKey.address.hex;

    await _signMessageLocally(context, bytesToHex(privateKey.privateKey), address, mnemonic);
  }

  String seedToPrivateKey(Uint8List seed) {
    final sha256 = SHA256Digest();
    final privateKeyBytes = sha256.process(seed);
    return bytesToHex(privateKeyBytes);
  }

  Future<void> _signMessageLocally(
      BuildContext context, String? privateKey, String wallet, [String? mnemonic]) async {
    if (privateKey == null) return;

    final privateKeyFromHex = EthPrivateKey.fromHex(privateKey);
    final encodedMessage = Uint8List.fromList(utf8.encode(testSignData(wallet.toLowerCase())));
    final signedMessage = privateKeyFromHex.signPersonalMessageToUint8List(encodedMessage);
    final signature = "0x${bytesToHex(signedMessage)}";

    await _homeController.loginWithWallet(context, wallet.toLowerCase(), testSignData(wallet.toLowerCase()), signature);

    if(mnemonic != null) {
      box.write(SharedPref.SEED_PHRASE, mnemonic);
      if(context.mounted) await promptChoseBackupMethod(context);
    }

    _homeController.isLoading.value = false;
  }

  retrieveWalletFromMnemonic(BuildContext context, String mnemonic) async {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final privateKey = EthPrivateKey.fromHex(seedToPrivateKey(seed));
    final address = privateKey.address.hex;
    if(await AuthRepo.isWalletUser(address)){
      if(context.mounted) {
        await _signMessageLocally(
            context, bytesToHex(privateKey.privateKey), address);
        Get.back();
      }
    } else {
      errorTextRetrieving.value = true;
    }
  }

SIWEConfig returnConfig() {
    return SIWEConfig(
      getNonce: () async {
        // The getNonce method functions as a safeguard
        // against spoofing, akin to a CSRF token.
        return await "yourApigetNofefnce";
      },
      getMessageParams: () async {
        // Parameters to create the SIWE message internally.
        // More info in https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-222.method
        return const SIWEMessageArgs(
          domain: 'yourdomain.com',
          uri: 'https://yourdomain.com/login',
          statement: 'Please sign with your account',
          methods: ['personal_sign', 'eth_sendTransaction'],
        );
      },
      createMessage: (SIWECreateMessageArgs args) {
        // Method for generating an EIP-4361-compatible message.
        // You can use our provided formatMessage() method of implement your own
        return AuthSignature.formatMessage(args);
      },
      verifyMessage: (SIWEVerifyMessageArgs args) async {
        // This function ensures the message is valid,
        // has not been tampered with, and has been appropriately
        // signed by the wallet address.
        var  m = AuthSignature.getChainIdFromMessage(args.message);
        var l = AuthSignature.getAddressFromMessage(args.message);
        try {
          final isValidMessage = true;
          return isValidMessage;
        } catch (error) {
          // error validating message
          return false;
        }
      },
      getSession: () async {
        // Called after verifyMessage() succeeds
        // The backend session should store the associated address and chainId
        // and return it via the `getSession` method.
        try {
          // final session = await yourApi.getSession();
          return const SIWESession(
              address: "0x364fd98df51f0f908207bdddb2f231f77b815644", chains: ["1"]);
        } catch (error) {
          // error getting session
          rethrow;
        }
      },
      onSignIn: (SIWESession session) {
        var k = "";
        // Called after getSession() succeeds
      },
      signOut: () async {
        // Called when wallet disconnects if `signOutOnDisconnect == true` and/or when
        // `signOutOnAccountChange == true` and/or
        // `signOutOnNetworkChange == true`
        try {
          final success = false;
          return success;
        } catch (error) {
          // error signing out
          return false;
        }
      },
      onSignOut: () {
        // Called after signOut() succeeds
      },
      // enabled: true, // OPTIONAL. Enables One-Click Auth + SIWE logic, if `false`, regular session proposal will be used. (default `true`)
      // signOutOnDisconnect: true, // OPTIONAL (default `true`)
      // signOutOnAccountChange: true, // OPTIONAL (default `true`)
      // signOutOnNetworkChange: true, // OPTIONAL (default `true`)
    );
  }
}
