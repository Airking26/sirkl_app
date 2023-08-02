// ignore: implementation_imports
import 'package:web3dart/crypto.dart';
import 'dart:typed_data';

import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';

class WalletConnectEthereumCredentialsV2 extends CustomTransactionSender {
  WalletConnectEthereumCredentialsV2(
      {required this.wcClient, required this.session, this.maxGas });

  final Web3App wcClient;
  final SessionData session;
  BigInt? maxGas;

  @override
  Future<String> sendTransaction(Transaction transaction) async {
    final from = await extractAddress();
    final signResponse = await wcClient.request(
      topic: session.topic,
      chainId: 'eip155:5',
      request: SessionRequestParams(
        method: 'eth_sendTransaction',
        params: [
          {
            'from': from.hex,
            'to': transaction.to?.hex,
            'gas': '0x${maxGas?.toRadixString(16)}',
            'value': '0x${transaction.value?.getInWei.toRadixString(16) ?? '0'}',
            'data': transaction.data != null ? bytesToHex(transaction.data!) : null,
          }
        ],
      ),
    );

    return signResponse.toString();
  }

  @override
  EthereumAddress get address => EthereumAddress.fromHex(
      session.namespaces.values.first.accounts.first.split(':').last);

  @override
  Future<EthereumAddress> extractAddress() =>
      Future(() => EthereumAddress.fromHex(
          session.namespaces.values.first.accounts.first.split(':').last));

  @override
  MsgSignature signToEcSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    // TODO: implement signToEcSignature
    throw UnimplementedError();
  }

  @override
  Future<MsgSignature> signToSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    // TODO: implement signToSignature
    throw UnimplementedError();
  }
}