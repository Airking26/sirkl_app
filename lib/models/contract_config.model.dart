

class ContractConfigModel {

  final String abiPath;
  final String contractName;
  final String contractAddress;
  final String bridgeUrl;
  final String websocketUrl;

  ContractConfigModel({required this.abiPath, required this.contractAddress, required this.contractName, required this.bridgeUrl, required this.websocketUrl});

}