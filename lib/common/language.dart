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
      c.myNFTCollectionRes: "My NFT Collection",
      c.editProfileRes: "• Edit profile",
      c.contactUsRes: "• Contact us",
      c.logoutRes: "• Logout",
      c.noGroupYetRes: "No Group Yet",
      c.errorFindingCollection: "You don't find your collection here and you own the NFT",
      c.addGroupRes: "+ Add the group chat to the list",
      c.newMessageRes: "New Message",
      c.toRes: "To",
      c.contactsRes: "Contacts"
    }
  };

}