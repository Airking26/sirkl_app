import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/web3/wallet_connect_ethereum_credentials.dart';
import 'package:sirkl/global_getx/wallet/s_wallet_connect.dart';
import 'package:sirkl/models/contract_response.model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import '../../enums/contract_response_status.enum.dart';

// class Web3Controller extends GetxController{

//   Future<DeployedContract> getContract() async {
//     String abi = await rootBundle.loadString("assets/abi.json");
//     //String contractAddress = "0x9B2044615349Ffe31Cf979F16945D0c785eED7da"; 
//     String contractAddress = "0xB3401D28EF2861607Fa77D291B36850B1005dD94"; 
//     String contractName = "PaidGroups";

//     DeployedContract contract = DeployedContract(
//       ContractAbi.fromJson(abi, contractName),
//       EthereumAddress.fromHex(contractAddress),
//     );

//     return contract;
//   }

//   Future<String?> _query(Web3Client ethereumClient, String functionName, List<dynamic> args, WalletConnect connector) async {
//     DeployedContract contract = await getContract();
//     ContractFunction function = contract.function(functionName);
//     //launchUrl(Uri.parse("metamask://"), mode: LaunchMode.externalApplication);
//     //EthereumWalletConnectProvider provider = EthereumWalletConnectProvider(connector);
//      EthPrivateKey _creds = EthPrivateKey.fromHex("0xbce35b50216e9457b85ce85265a2cfe8298717587204714f198da1a4862fd882");
//     // String result = await ethereumClient.sendTransaction(WalletConnectEthereumCredentials(provider: provider),
//     //     Transaction.callContract(contract: contract, function: function, parameters: args), chainId: null, fetchChainIdFromNetworkId: true);
//         String txHash = await ethereumClient.sendTransaction(_creds,
//         Transaction.callContract(contract: contract, function: function, parameters: args,), chainId: 1337);
//        TransactionReceipt? receipt = await ethereumClient.getTransactionReceipt(txHash);
//   if (receipt != null && receipt.status!) {
//     // Transaction successful, now retrieve the return value from the contract
//     var response = await ethereumClient.call(contract: contract, function: function, params: args);
//     //String result = response?.decodedResult?.first.toString();
    
//     return response[0].toString();
//   } else {
//     // Transaction failed or not yet confirmed
//     return null;
//   }
//       // debugPrint('result $result');
//     //TODO : Retrieve the id of the group created
//    // return result;
//   }


//   Future<List<dynamic>> call(Web3Client web3client, String functionName, List<dynamic> args) async {
//     DeployedContract deployedContract = await getContract();
//     ContractFunction contractFunction = deployedContract.function(functionName);
    
//     List<dynamic> result = await web3client.call(
//         contract: deployedContract, function: contractFunction, params: args);
     
//     return result;
//   }

//   Future<String?> createGroup(Web3Client ethereumClient, List<dynamic> args, WalletConnect connector) async {
//     return await _query(ethereumClient, "createGroup", args, connector);
//   }

//   Future<List<dynamic>> getGroups(Web3Client web3client, List<dynamic> args) async {
//     return await call(web3client, "getGroups", args);
//   }

// }



class BaseContract extends GetxController {

  ///
  /// this will be removed, this is not the best approach, in future if we wana have multiple wallet connector, this will be an issue
  ///
  SWalletConnectController get walletConnect => Get.find<SWalletConnectController>();


  final String abiPath;
  late String abi;
  final String contractName;
  final String contractAddress;
  late DeployedContract contract;
  final Completer _completer = Completer();
  final bridgeUrl;
  late Web3Client _client;
  final String websocketUrl;
  BaseContract({required  this.abiPath, required this.contractName, required this.contractAddress, required this.bridgeUrl, required this.websocketUrl });
  Future<void> initialize() async {
    await _connectContract();
    _completer.complete();
    _client = Web3Client(bridgeUrl, http.Client(),
    //socketConnector: IOWebSocketChannel.connect(websocketUrl).cast<String>
    );
  }
   Future<void> _connectContract() async {
    abi = await rootBundle.loadString(abiPath);
    //String contractAddress = "0x9B2044615349Ffe31Cf979F16945D0c785eED7da"; 
    //String contractAddress = "0xB3401D28EF2861607Fa77D291B36850B1005dD94"; 
    //String contractName = "PaidGroups";

    contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );
  }

    Future<ContractResponse> query( String functionName, List<dynamic> args, ) async {

    ContractFunction function = contract.function(functionName);
     Completer _metaCompleter = Completer();
     
   WalletConnect connector = await walletConnect.connector;
   debugPrint('Connector was establised');
   bool canOpen = await canLaunchUrl(Uri.parse("metamask://"));
   debugPrint('Connector can open $canOpen');
      if (!canOpen) {
        await Future.delayed(Duration(seconds: 3));
      }
    launchUrl(Uri.parse("metamask://"), mode: LaunchMode.externalApplication).then((value) => _metaCompleter.complete());
          
       EthereumWalletConnectProvider provider = EthereumWalletConnectProvider(connector);

     await _metaCompleter.future;
    
     EthPrivateKey _creds = EthPrivateKey.fromHex("0xbce35b50216e9457b85ce85265a2cfe8298717587204714f198da1a4862fd882");
     String txId = await _client.sendTransaction(WalletConnectEthereumCredentials(provider: provider),
        Transaction.callContract(contract: contract, function: function, parameters: args), chainId: walletConnect.chainId);

         TransactionReceipt? receipt;
        bool shouldCheck = true;
        int retryNo = 15;
       while(shouldCheck) {
        receipt  = await _client.getTransactionReceipt(txId);
        if(receipt == null && retryNo >=0) {
          await Future.delayed(Duration(seconds: 5));
        } else {
          shouldCheck = false;
        }
        retryNo--;
       }
     
       List<dynamic> result = [];
       debugPrint('Contract response Receipt ${receipt?.status}');
  if (receipt != null && receipt.status!) {
    // Transaction successful, now retrieve the return value from the contract
    result = await _client.call(contract: contract, function: function, params: args);
    //String result = response?.decodedResult?.first.toString();
    
  
  }
  return ContractResponse(txId: txId, result: result, status: ContractResponseStatus.success);
  }

  Future<void> isSafe() async {
    await _completer.future;
  }

}