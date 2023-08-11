import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/model/eth_transaction_dto.dart';
import 'package:sirkl/common/web3/wallet_connect_ethereum_credentials_v2.dart';
import 'package:sirkl/networks/request.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';

class Web3Controller extends GetxController{

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
        chains: [],
        methods: [
          'personal_sign',
          'eth_sign',
          'eth_signTransaction',
          'eth_signTypedData',
          'eth_sendTransaction',
        ], // Requestable Methods
      ),
    });
    launchUrl(res.uri!, mode: LaunchMode.externalApplication);
    return connector;
  }

  Future<dynamic> query(Web3App connector, SessionConnect? sessionConnect, String functionName, List<dynamic> arg, bool hasFee, double? fee, String? wallet) async {
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    //var client = Web3Client("https://goerli.infura.io/v3/c193b412278e451ea6725b674de75ef2", Client());

    Transaction transaction = Transaction.callContract(
          from: EthereumAddress.fromHex(wallet!),
          contract: contract,
          function: function,
          parameters: arg);

    launchUrl(Uri.parse("metamask://"), mode: LaunchMode.externalApplication);

    EthereumTransaction ethereumTransaction = EthereumTransaction(
        from: wallet,
        to: "0x9B2044615349Ffe31Cf979F16945D0c785eED7da",
        value: "0x${hasFee ? BigInt.from(fee! * 1e18).toRadixString(16) : "0"}",
        data: hex.encode(List<int>.from(transaction.data!)),
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


















/*Future<List<dynamic>> call(Web3Client web3client, String functionName, List<dynamic> args) async {
    DeployedContract deployedContract = await getContract();
    ContractFunction contractFunction = deployedContract.function(functionName);
    List<dynamic> result = await web3client.call(
        contract: deployedContract, function: contractFunction, params: args);
    return result;
  }


  Future<String?> query(Web3Client ethereumClient, String functionName, List<dynamic> args, WalletConnect connector, bool hasFee, dynamic fee) async {
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    bool canOpen = await canLaunchUrl(Uri.parse("metamask://"));
    if (!canOpen) {await Future.delayed(const Duration(seconds: 3));}
    launchUrl(Uri.parse("metamask://"), mode: LaunchMode.externalApplication);
    EthereumWalletConnectProvider provider = EthereumWalletConnectProvider(connector);
    String result = await ethereumClient.sendTransaction(WalletConnectEthereumCredentials(provider: provider),
        Transaction.callContract(contract: contract, function: function, parameters: args, value : hasFee ? EtherAmount.fromUnitAndValue(EtherUnit.wei, BigInt.from(fee * 1e18)): null) , chainId: null, fetchChainIdFromNetworkId: true);
    return result;
  }

  Future<String?> createGroup(Web3Client ethereumClient, List<dynamic> args, WalletConnect connector) async {
    return await query(ethereumClient, "createGroup", args, connector, false, null);
  }

    Future<String?> joinGroup(Web3Client ethereumClient, List<dynamic> args, WalletConnect connector, dynamic fee) async {
    return await query(ethereumClient, "joinGroup", args, connector, true, fee);
  }


  Future<List<dynamic>> getGroups(Web3Client web3client, List<dynamic> args) async {
    return await call(web3client, "getGroups", args);
  }

  */



}