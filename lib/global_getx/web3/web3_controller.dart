// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:async';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ndialog/ndialog.dart';
import 'package:sirkl/common/model/eth_transaction_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/networks/request.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as htp;

class Web3Controller extends GetxController{

  var loadingToJoinGroup = false.obs;
  var loadingToCreateGroup = false.obs;
  var client = Web3Client("https://goerli.infura.io/v3/c193b412278e451ea6725b674de75ef2", Client());
  var _uri;

  Future<DeployedContract> getContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x9B2044615349Ffe31Cf979F16945D0c785eED7da";
    String contractName = "PAIDGROUPS";

    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );

    return contract;
  }

  Future<Web3App> connect() async {
    var connector = await Web3App.createInstance(
      projectId: 'bdfe4b74c44308ffb46fa4e6198605af',
      metadata: const PairingMetadata(
        name: 'SIRKL',
        description: 'SIRKL Login',
        url: 'https://walletconnect.com',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
      ),
    );

    ConnectResponse res = await connector.connect(requiredNamespaces: {
      'eip155': const RequiredNamespace(
        events: ['session_request','chainChanged', 'accountsChanged',],
        chains: ['eip155:5'],
        methods: [
          'personal_sign',
          'eth_sign',
          'eth_signTransaction',
          'eth_signTypedData',
          'eth_sendTransaction',
        ], // Requestable Methods
      ),
    });

     _uri = res.uri!;

    launchUrl(res.uri!, mode: LaunchMode.externalApplication);
    return connector;
  }

  Future<dynamic> query(Web3App connector, SessionConnect? sessionConnect, String functionName, List<dynamic> arg, bool hasFee, double? fee, String? wallet) async {
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);

    Transaction transaction = Transaction.callContract(
          from: EthereumAddress.fromHex(wallet!),
          contract: contract,
          function: function,
          parameters: arg);

    var gasPrice = await client.getGasPrice();
    var estimatedGasFee = await client.estimateGas(sender: EthereumAddress.fromHex(wallet), gasPrice: gasPrice, value: hasFee ? EtherAmount.inWei(BigInt.from(fee! * 10e18)) : EtherAmount.zero());

    launchUrl(_uri, mode: LaunchMode.externalApplication);

    EthereumTransaction ethereumTransaction = EthereumTransaction(
        from: wallet,
        to: "0x9B2044615349Ffe31Cf979F16945D0c785eED7da",
        value: "0x${hasFee ? BigInt.from(fee! * 1e18).toRadixString(16) : "0"}",
        data: hex.encode(List<int>.from(transaction.data!)),
        gas: "0x${(BigInt.parse("${estimatedGasFee}0")).toRadixString(16)}"
      );


    var transactionId = await connector.request(
      topic: sessionConnect!.session.topic,
      chainId: "eip155:5",
      request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [ethereumTransaction.toJson()],
        ),
    );

    return transactionId;
  }

  Future<String?> createGroup(Web3App connector, SessionConnect? sessionConnect, List<dynamic> args, String? wallet) async {
    return await query(connector, sessionConnect, "createGroup", args, false, null, wallet);
  }

  Future<String?> joinGroup(Web3App connector, SessionConnect? sessionConnect, List<dynamic> args, double fee, String? wallet) async {
    return await query(connector, sessionConnect, "joinGroup", args, true, fee, wallet);
  }

  Future<String?> leaveGroup(Web3App connector, SessionConnect? sessionConnect, List<dynamic> args, String? wallet) async {
    return await query(connector, sessionConnect, "leaveGroup", args, false, null, wallet);
  }

  Future<String?> sendInvite(Web3App connector, SessionConnect? sessionConnect, List<dynamic> args, String? wallet) async {
    return await query(connector, sessionConnect, "inviteToGroup", args, false, null, wallet);
  }

  joinGroupMethod(Web3App connector, SessionConnect? args, BuildContext context, Channel channel, String wallet, AlertDialog alert, String id) async {
    loadingToJoinGroup.value = true;
      var address = await joinGroup(
          connector,
          args,
          [
            BigInt.parse(
                channel.extraData["idGroupBlockChain"]
                as String)
          ],
          channel.extraData["price"] is double
              ? channel.extraData["price"] as double
              : (channel.extraData["price"] as int)
              .toDouble(),
          wallet);
      final contract =
      await getContract();
      final filter = FilterOptions.events(
          contract: contract,
          event: contract.event('GroupJoined'));
      Stream<FilterEvent> eventStream =
      client.events(filter);
      if (address != null) {
        showDialog(context: context, builder: (_) => WillPopScope(onWillPop : () async => false, child: alert), barrierDismissible: false);
      }
      eventStream.listen((event) async {
        if (address == event.transactionHash) {
          loadingToJoinGroup.value =
          false;
          var ua = channel.extraData["users_awaiting"];
          if(ua != null){
            (ua as List<dynamic>).remove(id);
            await channel.updatePartial(set: {"users_awaiting": ua});
          }
          await channel
              .addMembers([id]);
          Get.back();
        }
      });
  }

  leaveGroupMethod(Web3App connector, SessionConnect? args,BuildContext context, Channel channel, String wallet, AlertDialog alert, String id) async {
      var address = await leaveGroup(connector, args, [BigInt.parse(channel.extraData["idGroupBlockChain"] as String)], wallet);
      final contract = await getContract();
      final filter = FilterOptions.events(contract: contract, event: contract.event('GroupLeft'));
      Stream<FilterEvent> eventStream = client.events(filter);
      if (address != null) showDialog(context: context, builder: (_) => WillPopScope(onWillPop : () async => false, child: alert), barrierDismissible: false);
      eventStream.listen((event) async {
        if(event.transactionHash == address) {
          await channel.removeMembers([id]);
          Get.back();
          Get.back();
          Navigator.pop(context);
          Navigator.pop(context);
        }
      });
  }

  sendInviteMethod(Web3App connector, SessionConnect? args, BuildContext context, Channel channel, String wallet, AlertDialog alert, String walletInvited, double fee) async {
    var address = await sendInvite(connector, args, [BigInt.parse(channel.extraData['idGroupBlockChain'] as String), EthereumAddress.fromHex(walletInvited), BigInt.from(fee * 10e18)], wallet);
      final contract = await getContract();
      final filter = FilterOptions.events(contract: contract, event: contract.event('InvitationCreated'));
      Stream<FilterEvent> eventStream = client.events(filter);
      if(address != null) showDialog(context: context, builder: (_) => WillPopScope(onWillPop : () async => false, child: alert), barrierDismissible: false);
      eventStream.listen((event) async {
        if(event.transactionHash == address){
          Get.back();
        }
      });
  }

  AlertDialog blockchainInfo(String info){
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                bottom: 24.0, top: 12),
            child: CircularProgressIndicator(
              color: SColors.activeColor,
            ),
          ),
          const Text(
            "Please, wait while the transaction is processed. This may take some time.",
            style: TextStyle(
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}