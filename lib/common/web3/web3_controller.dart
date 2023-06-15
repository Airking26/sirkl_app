import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/web3/wallet_connect_ethereum_credentials.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

class Web3Controller extends GetxController{

  Future<DeployedContract> getContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x45dcC4DEC99C37d802Fed2e54fB170E18606A22C";
    String contractName = "PaidGroups";

    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );

    return contract;
  }

  Future<List<dynamic>> query(Web3Client ethereumClient) async {
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function("getGroupCount");
    List<dynamic> result = await ethereumClient.call(
        contract: contract, function: function, params: []);
    return result;
  }

  Future<String> call(Web3Client ethereumClient, String functionName, List<dynamic> args, WalletConnect connector) async {
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    launchUrl(Uri.parse("metamask://"), mode: LaunchMode.externalApplication);
    EthereumWalletConnectProvider provider = EthereumWalletConnectProvider(connector);
    String result = await ethereumClient.sendTransaction(WalletConnectEthereumCredentials(provider: provider),
        Transaction.callContract(contract: contract, function: function, parameters: args, gasPrice: EtherAmount.inWei(BigInt.one), maxGas: 500000));
    return result;
  }


}