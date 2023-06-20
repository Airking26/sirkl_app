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

  Future<String?> call(Web3Client ethereumClient, String functionName, List<dynamic> args, WalletConnect connector) async {
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    launchUrl(Uri.parse("metamask://"), mode: LaunchMode.externalApplication);
    EthereumWalletConnectProvider provider = EthereumWalletConnectProvider(connector);
    String result = await ethereumClient.sendTransaction(WalletConnectEthereumCredentials(provider: provider),
        Transaction.callContract(contract: contract, function: function, parameters: args), chainId: null, fetchChainIdFromNetworkId: true);

    ethereumClient.addedBlocks().listen((event) async {
      var receipt = await ethereumClient.getTransactionReceipt(result);

    });

    return result;
  }




  Future<List<dynamic>> query(Web3Client web3client, String functionName, List<dynamic> args) async {
    DeployedContract deployedContract = await getContract();
    ContractFunction contractFunction = deployedContract.function(functionName);
    List<dynamic> result = await web3client.call(
        contract: deployedContract, function: contractFunction, params: args);
    return result;
  }

  Future<String?> createGroup(Web3Client ethereumClient, List<dynamic> args, WalletConnect connector) async {
    return await call(ethereumClient, "createGroup", args, connector);
  }

  Future<List<dynamic>> getGroups(Web3Client web3client, List<dynamic> args) async {
    return await query(web3client, "getGroups", args);
  }

}