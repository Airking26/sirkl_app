class SUrls {
  static String get ethMainNetBaseUrl => "https://eth-mainnet.g.alchemy.com/";
  static String get etherscanBaseUrl => "https://api.etherscan.io/";
  static String baseURL =
      'http://sirklserver-env.eba-advpp2ip.eu-west-1.elasticbeanstalk.com/';
  static String infura =
      'https://mainnet.infura.io/v3/c193b412278e451ea6725b674de75ef2';

  /// Auth Repo
  static const String verifySignature = 'auth/verifySignature';
  static const String refreshToken = 'auth/refresh';
  static String checkBetaCode(String code) => "auth/check_beta_code/$code";
  static String checkWalletIsUser(String wallet) =>
      "auth/check_wallet_is_user/$wallet";

  /// User Repo
  static const String userMe = 'user/me';
  static String userById(String id) => 'user/$id';
  static const String userMeFCM = 'user/me/fcm';
  static const String userMeAPN = 'user/me/apn';
  static const String userMeWelcomeMessage = 'user/me/welcome_message';
  static String userSearchByWallet(String wallet) => 'user/search/$wallet';
  static const String userMeTokenStreamChat = 'user/me/tokenStreamChat';
  static const String userAdminRole = 'user/admin_role';
  static String userAddSirklClub(String id) =>
      'user/add_user_to_sirkl_club/$id';
  static String userMeTokenAgoraRTC(
          String channel, String role, String tokenType, String id) =>
      'user/me/tokenAgoraRTC/$channel/$role/$tokenType/$id';
  static String checkIsUsernameAvailable(String value) =>
      'user/check_username_free/$value';

  /// Join Repo
  static const String joinRequestToJoin = 'join/request_to_join';
  static const String joinAcceptDeclineRequest = 'join/accept_decline_request';
  static String joinRequestsByChannelId(String channelId) =>
      'join/requests/$channelId';

  /// Nickname Repo
  static const String nicknames = 'nicknames';
  static const String nicknamesRetrieve = 'nicknames/retrieve';

  /// Story repo
  static const String storyCreate = 'story/create';
  static const String storyModify = 'story/modify';
  static String storyOthers(String offset) => 'story/others/$offset';
  static const String storyMine = 'story/mine';
  static String storyReadersById(String id) => 'story/readers/$id';
  static String deleteStory(String createdBy, String id) =>
      'story/mine/$createdBy/$id';

  /// Group repo
  static const String groupRetrieve = 'group/retrieve';
  static const String groupCreate = 'group/create';

  /// Inbox repo
  static const String inboxCreate = 'inbox/create';
  static const String inboxUpdate = 'inbox/update';
  static String inboxEthFromENS(String ens) => 'inbox/eth_from_ens/$ens';
  static String inboxDeleteById(String id) => 'inbox/delete/$id';

  /// Call repo
  static String callEndByIdChannel(String id, String channel) =>
      'call/end/$id/$channel';
  static String callMissedCallById(String id) => 'call/missed_call/$id';
  static const String callCreate = 'call/create';
  static const String callUpdate = 'call/update';
  static String retrieveCalls(String offset) => 'call/retrieve/$offset';
  static String callSearchBySubstring(String substring) =>
      'call/search/$substring';

  /// Notification repo
  static String retrieveNotifications(String id, String offset) =>
      'notification/$id/notifications/$offset';
  static String notificationById(String id) => 'notification/$id';
  static String notificationUnreadNotif(String id) =>
      'notification/$id/unreadNotif';
  static const String notificationRegister = 'notification/register';
  static const String notificationAddedInGroup = 'notification/added_in_group';
  static const String notificationUpgradedAsAdmin =
      'notification/upgraded_as_admin';
  static const String notificationInvitedToJoinPayingGroup =
      'notification/invited_to_join_paying_group';

  /// Follow repo
  static String followMeById(String id) => 'follow/me/$id';
  static String followIsInFollowing(String id) => 'follow/isInFollowing/$id';
  static String followByIdFollowing(String id) => 'follow/$id/following';

  /// Search repo
  static String searchUsersBySubstringOffset(String substring, String offset) =>
      'search/users/$substring/$offset';

  /// Assets repo
  static const String nftRetrieveAll = 'nft/retrieveAll';
  static const String nftUpdateAll = 'nft/updateAll';
  static String nftRetrieve(String id, bool isFav, String offset) =>
      'nft/retrieve/$id/$isFav/$offset';
  static const String nftUpdate = 'nft/update';
  static const String retrieveContractAddress = 'nft/retrieve_contract_address';
  static String retrieveAssetToCreateNewCommunity(String offset) =>
      "nft/retrieve/group_to_create/$offset";

  /// Report repo
  static const String signalmentReport = 'signalment/report';
}
