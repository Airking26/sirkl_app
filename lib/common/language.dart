import 'package:get/get.dart';
import 'constants.dart' as c;

class Language extends Translations{
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US':{
      c.homeTabRes: "SIRKL",
      c.callsTabRes: "Calls",
      c.groupsTabRes: "Groups",
      c.chatsTabRes: "Inbox",
      c.profileTabRes: "Profile",
      c.connectYourWalletRes: "Connect your wallet",
      c.talkWithRes: "Talk with other wallets and your NFT groups",
      c.getStartedRes: "Get Started",
      c.myNFTCollectionRes: "My NFT Collection"
    }
  };

}