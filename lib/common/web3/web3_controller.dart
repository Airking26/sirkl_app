import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/web3/wallet_connect_ethereum_credentials.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
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

  Future<List<dynamic>> call(Web3Client web3client, String functionName, List<dynamic> args) async {
    DeployedContract deployedContract = await getContract();
    ContractFunction contractFunction = deployedContract.function(functionName);
    List<dynamic> result = await web3client.call(
        contract: deployedContract, function: contractFunction, params: args);
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

}