import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:bs58/bs58.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:pinenacl/x25519.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class PhantomConnectService {
  late final AppLinks _appLinks;
  Uint8List? _sharedSecret;
  PrivateKey? _dappPrivateKey;
  PublicKey? _phantomPublicKey;
  String? _session;
  HomeController _homeController = Get.find<HomeController>();

  String testSignData(String wallet) =>
      'Welcome to $wallet SIRKL.io by signing this message you agree to learn and have fun with blockchain';

  PhantomConnectService(BuildContext context) {
    _initializeAppLinks(context);
  }

  // Generate a key pair using X25519 algorithm in pinenacl
  Future<void> generateKeyPair() async {
    _dappPrivateKey = PrivateKey.generate(); // Generate X25519 private key
  }

  // Get the public key from the private key, encoded in base58
  Future<String> getPublicKey() async {
    final publicKey = _dappPrivateKey!.publicKey;
    return base58.encode(publicKey.asTypedList);
  }

  // Initialize AppLinks to listen for deep link changes
  void _initializeAppLinks(BuildContext context) async {
    _appLinks = AppLinks();

    // Listen for deep link changes (callbacks from Phantom)
    _appLinks.getInitialLink().then((uri) {
      _handleIncomingLink(context, uri);
    });

    _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingLink(context, uri);
    });
  }

  // Handle incoming deep links
  void _handleIncomingLink(BuildContext context, Uri? uri) async {
    if (uri != null) {
      print("Received deep link: $uri");

      if (_dappPrivateKey == null) {
        return;
      }

      // Check if the URI is for connection or message signing
      if (uri.path == '/connected') {
        // Process connection response
        _phantomPublicKey = PublicKey(
          base58.decode(uri.queryParameters['phantom_encryption_public_key']!),
        );
        final data = uri.queryParameters['data'];
        final nonce = uri.queryParameters['nonce'];

        // Derive shared secret and decrypt payload
        await _deriveSharedSecret();
        final connectData = await _decryptPayload(data!, nonce!);
        _session = connectData['session'];

        print("Connected to Phantom Wallet with session: $_session");

        var wallet = connectData['public_key'];
        if (wallet != null) {
          _homeController.address.value = connectData["public_key"];
          Get.back();
        }
      } else if (uri.path == '/messageSigned') {
        // Handle the signed message response
        _handleSignedMessage(context, uri);
      } else {
        print("Unknown deep link path: ${uri.path}");
      }
    }
  }

  // Derive the shared secret using pinenacl (X25519 key exchange)
  Future<void> _deriveSharedSecret() async {
    final box =
        Box(myPrivateKey: _dappPrivateKey!, theirPublicKey: _phantomPublicKey!);
    _sharedSecret = Uint8List.fromList(
        box.sharedKey.asTypedList); // Convert ByteList to Uint8List
    print("Shared Secret: $_sharedSecret");
  }

  // Encrypt the payload using the shared secret and pinenacl Box
  Future<Map<String, String>> _encryptPayload(
      Map<String, dynamic> payload) async {
    final nonce = PineNaClUtils.randombytes(24); // Generate 24-byte nonce
    final payloadBytes = utf8.encode(json.encode(payload));

    final box =
        Box(myPrivateKey: _dappPrivateKey!, theirPublicKey: _phantomPublicKey!);
    final encrypted =
        box.encrypt(Uint8List.fromList(payloadBytes), nonce: nonce);

    return {
      'nonce': base58.encode(nonce),
      'data': base58.encode(encrypted.cipherText.asTypedList)
    };
  }

  // Decrypt the payload using the shared secret and pinenacl Box
  Future<Map<String, dynamic>> _decryptPayload(
      String data, String nonce) async {
    final decodedData = base58.decode(data);
    final decodedNonce = base58.decode(nonce);

    final box =
        Box(myPrivateKey: _dappPrivateKey!, theirPublicKey: _phantomPublicKey!);
    final decrypted = box.decrypt(ByteList(decodedData), nonce: decodedNonce);

    return json.decode(utf8.decode(decrypted));
  }

  // Connect to Phantom Wallet
  Future<void> connectToPhantom() async {
    await generateKeyPair();
    final publicKey = await getPublicKey();

    final uri = Uri.parse('https://phantom.app/ul/v1/connect'
        '?dapp_encryption_public_key=$publicKey'
        '&app_url=https://phantom.app'
        '&redirect_link=sirkl://phantom/connected');

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // Disconnect from Phantom Wallet
  Future<void> disconnectFromPhantom() async {
    if (_session == null) {
      print("Not connected to Phantom.");
      return;
    }

    final payload = {'session': _session};
    final encryptedPayload = await _encryptPayload(payload);

    final uri = Uri.parse('https://phantom.app/ul/v1/disconnect'
        '?dapp_encryption_public_key=${await getPublicKey()}'
        '&nonce=${encryptedPayload['nonce']}'
        '&payload=${encryptedPayload['data']}'
        '&redirect_link=sirkl://phantom/disconnected');

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // Function to request Phantom to sign a message
  Future<void> signMessage(String message) async {
    if (_session == null) {
      print("Not connected to Phantom.");
      return;
    }

    // Prepare the message payload
    final payload = {
      'session': _session,
      'message': base58.encode(utf8.encode(message))
    };

    // Encrypt the message payload
    final encryptedPayload = await _encryptPayload(payload);

    // Construct the Phantom signMessage URL
    final uri = Uri.parse('https://phantom.app/ul/v1/signMessage'
        '?dapp_encryption_public_key=${await getPublicKey()}'
        '&nonce=${encryptedPayload['nonce']}'
        '&payload=${encryptedPayload['data']}'
        '&redirect_link=sirkl://phantom/messageSigned');

    // Launch the Phantom app to sign the message
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

// Handle the response for the signed message
  void _handleSignedMessage(BuildContext context, Uri? uri) {
    if (uri != null &&
        uri.queryParameters.containsKey('data') &&
        uri.queryParameters.containsKey('nonce')) {
      final data = uri.queryParameters['data'];
      final nonce = uri.queryParameters['nonce'];

      _decryptPayload(data!, nonce!).then((signedMessageData) async {
        final signedMessage = signedMessageData['signed_message'];
        print("Signed Message: $signedMessage");
        await _homeController.loginWithWallet(
            context,
            _homeController.address.value,
            testSignData(_homeController.address.value),
            signedMessageData['signature']);
      }).catchError((error) {
        print("Failed to decrypt signed message: $error");
      });
    }
  }
}
