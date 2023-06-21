import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/web3/wallet_connect_ethereum_credentials.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

class Web3Controller extends GetxController{

  Future<DeployedContract> getContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    //String contractAddress = "0x9B2044615349Ffe31Cf979F16945D0c785eED7da"; 
    String contractAddress = "0xB3401D28EF2861607Fa77D291B36850B1005dD94"; 
    String contractName = "PaidGroups";

    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );

    return contract;
  }

  Future<String?> _query(Web3Client ethereumClient, String functionName, List<dynamic> args, WalletConnect connector) async {
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    //launchUrl(Uri.parse("metamask://"), mode: LaunchMode.externalApplication);
    //EthereumWalletConnectProvider provider = EthereumWalletConnectProvider(connector);
     EthPrivateKey _creds = EthPrivateKey.fromHex("0xbce35b50216e9457b85ce85265a2cfe8298717587204714f198da1a4862fd882");
    // String result = await ethereumClient.sendTransaction(WalletConnectEthereumCredentials(provider: provider),
    //     Transaction.callContract(contract: contract, function: function, parameters: args), chainId: null, fetchChainIdFromNetworkId: true);
        String txHash = await ethereumClient.sendTransaction(_creds,
        Transaction.callContract(contract: contract, function: function, parameters: args,), chainId: 1337);
       TransactionReceipt? receipt = await ethereumClient.getTransactionReceipt(txHash);
  if (receipt != null && receipt.status!) {
    // Transaction successful, now retrieve the return value from the contract
    var response = await ethereumClient.call(contract: contract, function: function, params: args);
    //String result = response?.decodedResult?.first.toString();
    
    return response[0].toString();
  } else {
    // Transaction failed or not yet confirmed
    return null;
  }
      // debugPrint('result $result');
    //TODO : Retrieve the id of the group created
   // return result;
  }


  Future<List<dynamic>> call(Web3Client web3client, String functionName, List<dynamic> args) async {
    DeployedContract deployedContract = await getContract();
    ContractFunction contractFunction = deployedContract.function(functionName);
    
    List<dynamic> result = await web3client.call(
        contract: deployedContract, function: contractFunction, params: args);
     
    return result;
  }

  Future<String?> createGroup(Web3Client ethereumClient, List<dynamic> args, WalletConnect connector) async {
    return await _query(ethereumClient, "createGroup", args, connector);
  }

  Future<List<dynamic>> getGroups(Web3Client web3client, List<dynamic> args) async {
    return await call(web3client, "getGroups", args);
  }

}