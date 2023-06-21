import '../models/contract_config.model.dart';

class SConfig {
  /// contracts
  static ContractConfigModel paidGroupContract = ContractConfigModel(
      abiPath: 'assets/abi.json',
         contractAddress: '0x9B2044615349Ffe31Cf979F16945D0c785eED7da',
      bridgeUrl: "https://goerli.infura.io/v3/c193b412278e451ea6725b674de75ef2",
      websocketUrl: "wss://goerli.infura.io/v3/c193b412278e451ea6725b674de75ef2",
      contractName: 'PaidGroups');
      //   contractAddress: '0x9B2044615349Ffe31Cf979F16945D0c785eED7da',
      // bridgeUrl: "https://goerli.infura.io/v3/c193b412278e451ea6725b674de75ef2",
      //    contractAddress: '0xB3401D28EF2861607Fa77D291B36850B1005dD94',
      // bridgeUrl: "https://e0d1-39-51-164-92.ngrok-free.app",
  /// contracts
  /// Wallet connect
  
   static const String wBridgeUrl = 'https://bridge.walletconnect.org';
  static const String wAppName = 'SIRKL';
 static const String wUrl = 'https://walletconnect.org';
  static const String wIcon = 'https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png';


}
