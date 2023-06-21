import 'package:sirkl/models/contract_config.model.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

import '../../models/contract_response.model.dart';
import 'base_contract.dart';

class PaidGroupContract extends BaseContract {
  PaidGroupContract(ContractConfigModel config)
      : super(
            abiPath: config.abiPath,
            contractAddress: config.contractAddress,
            bridgeUrl: config.bridgeUrl,
            websocketUrl: config.websocketUrl,
            contractName: config.contractName);
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initialize();
  }
  @override
  Future<void> initialize() async {
    await super.initialize();
  }
   Future<ContractResponse> createGroup({required String title, required description, required int fee, required String acceptedToken} ) async {
       List<dynamic> args =   [title, description, BigInt.from(fee), EthereumAddress.fromHex(acceptedToken)];
     return await query( "createGroup", args);
   }

  // Future<List<dynamic>> getGroups(Web3Client web3client, List<dynamic> args) async {
  //   return await call(web3client, "getGroups", args);
  // }
}
  
