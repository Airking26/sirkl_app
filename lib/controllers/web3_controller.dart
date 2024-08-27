// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:async';

import 'package:convert/convert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/model/admin_dto.dart';
import 'package:sirkl/common/model/eth_transaction_dto.dart';
import 'package:sirkl/common/model/notification_added_admin_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/config/s_colors.dart';
import 'package:sirkl/controllers/chats_controller.dart';
import 'package:sirkl/controllers/common_controller.dart';
import 'package:sirkl/controllers/groups_controller.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:sirkl/controllers/profile_controller.dart';
import 'package:sirkl/main.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/views/chats/detailed_chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class Web3Controller extends GetxController {
  var loadingToJoinGroup = false.obs;
  var loadingToCreateGroup = false.obs;
  var client = Web3Client(
      "https://goerli.infura.io/v3/c193b412278e451ea6725b674de75ef2", Client());

  CommonController get _commonController => Get.find<CommonController>();
  GroupsController get _groupController => Get.find<GroupsController>();
  ChatsController get _chatController => Get.find<ChatsController>();
  ProfileController get _profileController => Get.find<ProfileController>();
  HomeController get _homeController => Get.find<HomeController>();

  Uri? _uri;
  var isMintingInProgress = false.obs;

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

  Future<DeployedContract> getContractMint() async {
    String abi = await rootBundle.loadString("assets/abi_mint.json");
    String contractAddress = "0x944a7A6833074122E9c2a7A5882392224C345807";
    String contractName = "SIRKLsbt";

    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );

    return contract;
  }

  Future<Web3App> connect() async {
    var connector = await Web3App.createInstance(
      projectId: 'bdfe4b74c44308ffb46fa4e6198605af',
      metadata: const PairingMetadata(
        name: 'SIRKL',
        description: 'SIRKL.io',
        url: 'https://sirkl.io/',
        icons: [
          "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png"
        ],
      ),
    );

    ConnectResponse res = await connector.connect(requiredNamespaces: {
      'eip155': const RequiredNamespace(
        events: ["chainChanged", "accountsChanged", "session_request"],
        chains: ["eip155:1"],
        methods: [
          "eth_sendTransaction",
          "wallet_switchEthereumChain",
          "wallet_addEthereumChain",
        ], // Requestable Methods
      ),
    }, optionalNamespaces: {
      'eip155': const RequiredNamespace(
          methods: ["eth_sendTransaction"],
          chains: ['eip155:1564830818'],
          events: ["chainChanged", "accountsChanged", "session_request"])
    });

    _uri = res.uri!;
    var encode = Uri.encodeComponent('${res.uri}');

    await launchUrlString("metamask://wc?uri=$encode",
        mode: LaunchMode.externalApplication);
    return connector;
  }

  Future<Web3App> connectCalypso() async {
    var connector = await Web3App.createInstance(
      projectId: 'bdfe4b74c44308ffb46fa4e6198605af',
      metadata: const PairingMetadata(
        name: 'SIRKL',
        description: 'SIRKL.io',
        url: 'https://sirkl.io/',
        icons: [
          "https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png"
        ],
      ),
    );

    ConnectResponse res = await connector.connect(requiredNamespaces: {
      'eip155': const RequiredNamespace(
        events: ["chainChanged", "accountsChanged", "session_request"],
        chains: ["eip155:1564830818"],
        methods: ["eth_sendTransaction"], // Requestable Methods
      ),
    });

    var encode = Uri.encodeComponent('${res.uri}');

    await launchUrlString("metamask://wc?uri=$encode",
        mode: LaunchMode.externalApplication);
    return connector;
  }

  Future<dynamic> queryMint(BuildContext context, Web3App connector,
      SessionConnect? sessionConnect, String wallet) async {
    DeployedContract contract = await getContractMint();
    ContractFunction function = contract.function("mint");
    String contractAddress = "0x944a7A6833074122E9c2a7A5882392224C345807";

    Transaction transaction = Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [],
        from: EthereumAddress.fromHex(wallet));

    EthereumTransaction ethereumTransaction = EthereumTransaction(
        from: wallet,
        to: contractAddress,
        data: hex.encode(List<int>.from(transaction.data!)),
        gas: "0x${(BigInt.parse("${100000}0")).toRadixString(16)}");

    /// IF USER IS NOT ON THE SKALE NETWORK
    if (sessionConnect!.session.namespaces['eip155']!.accounts.last
            .split(":0x")[0] ==
        "eip155:1564830818") {
      var canLaunch = await canLaunchUrl(_uri!);
      if (canLaunch) {
        launchUrlString("metamask://wc?uri=$_uri",
            mode: LaunchMode.externalApplication);
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          launchUrlString("metamask://wc?uri=$_uri",
              mode: LaunchMode.externalApplication);
        });
      }

      await connector.request(
          topic: sessionConnect.session.topic,
          chainId: "eip155:1",
          request:
              SessionRequestParams(method: "wallet_addEthereumChain", params: [
            {
              'chainName': '[S]Calypso Hub',
              'nativeCurrency': {
                'name': 'sFuel',
                'symbol': 'sFuel',
                'decimals': 18,
              },
              'rpcUrls': [
                'https://mainnet.skalenodes.com/v1/honorable-steel-rasalhague'
              ],
              'chainId': '0x${1564830818.toRadixString(16)}',
            },
          ]));

      var con = await connectCalypso();
      con.onSessionConnect.subscribe((args) async {
        var canLaunch = await canLaunchUrl(_uri!);
        if (canLaunch) {
          launchUrlString("metamask://wc?uri=$_uri",
              mode: LaunchMode.externalApplication);
          await con
              .request(
            topic: args!.session.topic,
            chainId: "eip155:1564830818",
            request: SessionRequestParams(
              method: 'eth_sendTransaction',
              params: [ethereumTransaction.toJson()],
            ),
          )
              .then((value) async {
            await updateUserAddToGroupAndRefresh(context);
            Get.back();

            showCupertinoDialog(
                context: navigatorKey.currentContext!,
                barrierDismissible: false,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: const Text("SBT Minted Successfully"),
                    content: const Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 24, right: 24),
                      child: Text(
                        "Your SBT will appear in your NFT Collection, and you also have joined the Sirkl Club Community",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            Get.back();
                          },
                          child: Text(
                            "OK",
                            style: TextStyle(color: SColors.activeColor),
                          ))
                    ],
                  );
                });
          });
        } else {
          Future.delayed(const Duration(seconds: 2), () async {
            launchUrlString("metamask://wc?uri=$_uri",
                mode: LaunchMode.externalApplication);
            await con
                .request(
              topic: args!.session.topic,
              chainId: "eip155:1564830818",
              request: SessionRequestParams(
                method: 'eth_sendTransaction',
                params: [ethereumTransaction.toJson()],
              ),
            )
                .then((value) async {
              await updateUserAddToGroupAndRefresh(context);
              Get.back();

              showCupertinoDialog(
                  context: navigatorKey.currentContext!,
                  barrierDismissible: false,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: const Text("SBT Minted Successfully"),
                      content: const Padding(
                        padding: EdgeInsets.only(top: 8.0, left: 24, right: 24),
                        child: Text(
                          "Your SBT will appear in your NFT Collection, and you also have joined the Sirkl Club Community",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              Get.back();
                            },
                            child: Text(
                              "OK",
                              style: TextStyle(color: SColors.activeColor),
                            ))
                      ],
                    );
                  });
            });
          });
        }
      });
    }

    /// IF USER IS ON THE SKALE NETWORK
    else {
      var canLaunch = await canLaunchUrl(_uri!);
      if (canLaunch) {
        launchUrlString("metamask://wc?uri=$_uri",
            mode: LaunchMode.externalApplication);
        await connector
            .request(
          topic: sessionConnect.session.topic,
          chainId: "eip155:1564830818",
          request: SessionRequestParams(
            method: 'eth_sendTransaction',
            params: [ethereumTransaction.toJson()],
          ),
        )
            .then((value) async {
          await updateUserAddToGroupAndRefresh(context);
          Get.back();

          showCupertinoDialog(
              context: navigatorKey.currentContext!,
              barrierDismissible: false,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: const Text("SBT Minted Successfully"),
                  content: const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 24, right: 24),
                    child: Text(
                      "Your SBT will appear in your NFT Collection, and you also have joined the Sirkl Club Community",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          Get.back();
                        },
                        child: Text(
                          "OK",
                          style: TextStyle(color: SColors.activeColor),
                        ))
                  ],
                );
              });
        });
      } else {
        Future.delayed(const Duration(seconds: 2), () async {
          launchUrlString("metamask://wc?uri=$_uri",
              mode: LaunchMode.externalApplication);
          await connector
              .request(
            topic: sessionConnect.session.topic,
            chainId: "eip155:1564830818",
            request: SessionRequestParams(
              method: 'eth_sendTransaction',
              params: [ethereumTransaction.toJson()],
            ),
          )
              .then((value) async {
            await updateUserAddToGroupAndRefresh(context);
            Get.back();

            showCupertinoDialog(
                context: navigatorKey.currentContext!,
                barrierDismissible: false,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: const Text("SBT Minted Successfully"),
                    content: const Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 24, right: 24),
                      child: Text(
                        "Your SBT will appear in your NFT Collection, and you also have joined the Sirkl Club Community",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            Get.back();
                          },
                          child: Text(
                            "OK",
                            style: TextStyle(color: SColors.activeColor),
                          ))
                    ],
                  );
                });
          });
        });
      }
    }
  }

  Future<void> updateUserAddToGroupAndRefresh(BuildContext context) async {
    await _homeController.updateMe(UpdateMeDto(hasSBT: true));
    await _groupController.addUserToSirklClub(_homeController.id.value);
    _profileController.pagingController.refresh();
    _groupController.refreshGroups.value = true;
  }

  Future<dynamic> query(
      Web3App connector,
      SessionConnect? sessionConnect,
      String functionName,
      List<dynamic> arg,
      bool hasFee,
      double? fee,
      String? wallet) async {
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);

    Transaction transaction = Transaction.callContract(
        from: EthereumAddress.fromHex(wallet!),
        contract: contract,
        function: function,
        parameters: arg);

    var gasPrice = await client.getGasPrice();
    var estimatedGasFee = await client.estimateGas(
        sender: EthereumAddress.fromHex(wallet),
        gasPrice: gasPrice,
        value: hasFee
            ? EtherAmount.inWei(BigInt.from(fee! * 1e18))
            : EtherAmount.zero());

    launchUrlString("metamask://wc?uri=$_uri",
        mode: LaunchMode.externalApplication);

    EthereumTransaction ethereumTransaction = EthereumTransaction(
        from: wallet,
        to: "0x9B2044615349Ffe31Cf979F16945D0c785eED7da",
        value: "0x${hasFee ? BigInt.from(fee! * 1e18).toRadixString(16) : "0"}",
        data: hex.encode(List<int>.from(transaction.data!)),
        gas: "0x${(BigInt.parse("${estimatedGasFee}0")).toRadixString(16)}");

    var transactionId = await connector.request(
      topic: sessionConnect!.session.topic,
      chainId: "eip155:5",
      request: SessionRequestParams(
        method: 'eth_sendTransaction',
        params: [ethereumTransaction.toJson()],
      ),
    );

    return transactionId;
  }

  Future<String?> mint(BuildContext context, Web3App connector,
      SessionConnect? sessionConnect, String wallet) async {
    return await queryMint(context, connector, sessionConnect, wallet);
  }

  Future<String?> createGroup(Web3App connector, SessionConnect? sessionConnect,
      List<dynamic> args, String? wallet) async {
    return await query(
        connector, sessionConnect, "createGroup", args, false, null, wallet);
  }

  Future<String?> joinGroup(Web3App connector, SessionConnect? sessionConnect,
      List<dynamic> args, double fee, String? wallet) async {
    return await query(
        connector, sessionConnect, "joinGroup", args, true, fee, wallet);
  }

  Future<String?> leaveGroup(Web3App connector, SessionConnect? sessionConnect,
      List<dynamic> args, String? wallet) async {
    return await query(
        connector, sessionConnect, "leaveGroup", args, false, null, wallet);
  }

  Future<String?> sendInvite(Web3App connector, SessionConnect? sessionConnect,
      List<dynamic> args, String? wallet) async {
    return await query(
        connector, sessionConnect, "inviteToGroup", args, false, null, wallet);
  }

  Future<String?> acceptInvitation(
      Web3App connector,
      SessionConnect? sessionConnect,
      List<dynamic> args,
      double fee,
      String? wallet) async {
    return await query(
        connector, sessionConnect, "acceptInvitation", args, true, fee, wallet);
  }

  Future<String?> kickMember(Web3App connector, SessionConnect? sessionConnect,
      List<dynamic> args, String? wallet) async {
    return await query(
        connector, sessionConnect, "kickMember", args, false, null, wallet);
  }

  Future<String?> addCreator(Web3App connector, SessionConnect? sessionConnect,
      List<dynamic> args, String? wallet) async {
    return await query(
        connector, sessionConnect, "addCreator", args, false, null, wallet);
  }

  Future<String?> removeCreator(
      Web3App connector,
      SessionConnect? sessionConnect,
      List<dynamic> args,
      String? wallet) async {
    return await query(
        connector, sessionConnect, "removeCreator", args, false, null, wallet);
  }

  Future<String?> updateGroupInfo(
      Web3App connector,
      SessionConnect? sessionConnect,
      List<dynamic> args,
      String? wallet) async {
    return await query(connector, sessionConnect, "updateGroupInfo", args,
        false, null, wallet);
  }

  mintMethod(BuildContext context, Web3App connector, SessionConnect? args,
      String wallet) async {
    await mint(context, connector, args, wallet);
  }

  joinGroupMethod(Web3App connector, SessionConnect? args, BuildContext context,
      Channel channel, String wallet, AlertDialog alert, String id) async {
    loadingToJoinGroup.value = true;
    var address = await joinGroup(
        connector,
        args,
        [BigInt.parse(channel.extraData["idGroupBlockChain"] as String)],
        channel.extraData["price"] is double
            ? channel.extraData["price"] as double
            : (channel.extraData["price"] as int).toDouble(),
        wallet);
    final contract = await getContract();
    final filter = FilterOptions.events(
        contract: contract, event: contract.event('GroupJoined'));
    Stream<FilterEvent> eventStream = client.events(filter);

    if (address != null) {
      showDialog(
          context: context,
          builder: (_) =>
              WillPopScope(onWillPop: () async => false, child: alert),
          barrierDismissible: false);
    }
    eventStream.listen((event) async {
      if (address == event.transactionHash) {
        loadingToJoinGroup.value = false;
        var ua = channel.extraData["users_awaiting"];
        if (ua != null) {
          (ua as List<dynamic>).remove(id);
          await channel.updatePartial(set: {"users_awaiting": ua});
        }
        await channel.addMembers([id]);
        Get.back();
      }
    });
  }

  leaveGroupMethod(
      Web3App connector,
      SessionConnect? args,
      BuildContext context,
      Channel channel,
      String wallet,
      AlertDialog alert,
      String id) async {
    var address = await leaveGroup(
        connector,
        args,
        [BigInt.parse(channel.extraData["idGroupBlockChain"] as String)],
        wallet);
    final contract = await getContract();
    final filter = FilterOptions.events(
        contract: contract, event: contract.event('GroupLeft'));
    Stream<FilterEvent> eventStream = client.events(filter);
    if (address != null) {
      showDialog(
          context: context,
          builder: (_) =>
              WillPopScope(onWillPop: () async => false, child: alert),
          barrierDismissible: false);
    }
    eventStream.listen((event) async {
      if (event.transactionHash == address) {
        await channel.removeMembers([id]);
        Get.back();
        Get.back();
        Navigator.pop(context);
        Navigator.pop(context);
      }
    });
  }

  sendInviteMethod(
      Web3App connector,
      SessionConnect? args,
      BuildContext context,
      Channel channel,
      String wallet,
      AlertDialog alert,
      UserDTO item,
      double fee) async {
    var address = await sendInvite(
        connector,
        args,
        [
          BigInt.parse(channel.extraData['idGroupBlockChain'] as String),
          EthereumAddress.fromHex(item.wallet!),
          BigInt.from(fee * 1e18)
        ],
        wallet);
    final contract = await getContract();
    final filter = FilterOptions.events(
        contract: contract, event: contract.event('InvitationCreated'));
    Stream<FilterEvent> eventStream = client.events(filter);
    if (address != null) {
      showDialog(
          context: context,
          builder: (_) =>
              WillPopScope(onWillPop: () async => false, child: alert),
          barrierDismissible: false);
    }
    eventStream.listen((event) async {
      if (event.transactionHash == address) {
        final inviteId = contract
            .event("InvitationCreated")
            .decodeResults(event.topics!, event.data!)[4];
        await _commonController.notifyUserInvitedToJoinPayingGroup(
            NotificationAddedAdminDto(
                idUser: item.id!,
                idChannel: channel.id!,
                channelName: channel.extraData['nameOfGroup'] as String,
                channelPrice: fee.toString(),
                channelPrivate: channel.extraData["isGroupPrivate"] as bool,
                inviteId: inviteId.toString()));
        Get.back();
      }
    });
  }

  acceptInvitationMethod(
      Web3App connector,
      SessionConnect? args,
      BuildContext context,
      Channel channel,
      String wallet,
      AlertDialog alert,
      String id,
      double fee,
      String inviteId) async {
    var address = await acceptInvitation(
        connector, args, [BigInt.parse(inviteId)], fee, wallet);
    final contract = await getContract();
    final filter = FilterOptions.events(
        contract: contract, event: contract.event("GroupJoined"));
    Stream<FilterEvent> eventStream = client.events(filter);
    if (address != null) {
      showDialog(
          context: context,
          builder: (_) =>
              WillPopScope(onWillPop: () async => false, child: alert),
          barrierDismissible: false);
    }
    eventStream.listen((event) async {
      if (event.transactionHash == address) {
        await channel.addMembers([id]);
        Get.back();
        pushNewScreen(context,
            screen: DetailedChatScreen(
              create: false,
              fromProfile: false,
              channelId: channel.id!,
            ),
            withNavBar: false);
      }
    });
  }

  kickMemberMethod(
      Web3App connector,
      SessionConnect? args,
      Channel channel,
      String wallet,
      AlertDialog alert,
      String id,
      StreamMemberListController memberListController,
      String walletToKick) async {
    var address = await kickMember(
        connector,
        args,
        [
          BigInt.parse(channel.extraData["idGroupBlockChain"] as String),
          EthereumAddress.fromHex(walletToKick)
        ],
        wallet);
    final contract = await getContract();
    final filter = FilterOptions.events(
        contract: contract, event: contract.event("GroupLeft"));
    Stream<FilterEvent> eventStream = client.events(filter);
    if (address != null) {
      showDialog(
          context: navigatorKey.currentContext!,
          builder: (_) =>
              WillPopScope(onWillPop: () async => false, child: alert),
          barrierDismissible: false);
    }
    eventStream.listen((event) async {
      if (event.transactionHash == address) {
        await channel.removeMembers([id]);
        await memberListController.refresh();
        Get.back();
      }
    });
  }

  addCreatorMethod(
      BuildContext context,
      Web3App connector,
      SessionConnect? args,
      Channel channel,
      String wallet,
      AlertDialog alert,
      String id,
      StreamMemberListController memberListController,
      String walletToAddAsCreator,
      double share) async {
    var address = await addCreator(
        connector,
        args,
        [
          BigInt.parse(channel.extraData['idGroupBlockChain'] as String),
          EthereumAddress.fromHex(walletToAddAsCreator),
          BigInt.from(share)
        ],
        wallet);
    final contract = await getContract();
    final filter = FilterOptions.events(
        contract: contract, event: contract.event('CreatorAdded'));
    Stream<FilterEvent> eventStream = client.events(filter);
    if (address != null) {
      showDialog(
          context: navigatorKey.currentContext!,
          builder: (_) =>
              WillPopScope(onWillPop: () async => false, child: alert),
          barrierDismissible: false);
    }
    eventStream.listen((event) async {
      if (event.transactionHash == address) {
        await _groupController.changeAdminRole(AdminDto(
            idChannel: channel.id!, userToUpdate: id, makeAdmin: true));
        await _commonController.notifyUserAsAdmin(NotificationAddedAdminDto(
            idUser: id,
            idChannel: channel.id!,
            channelName: channel.extraData["nameOfGroup"] as String));
        await memberListController.refresh();
        Get.back();
      }
    });
  }

  removeCreatorMethod(
      BuildContext context,
      Web3App connector,
      SessionConnect? args,
      Channel channel,
      String wallet,
      AlertDialog alert,
      String id,
      StreamMemberListController memberListController,
      String walletToAddAsCreator) async {
    var address = await removeCreator(
        connector,
        args,
        [
          BigInt.parse(channel.extraData['idGroupBlockChain'] as String),
          EthereumAddress.fromHex(walletToAddAsCreator)
        ],
        wallet);
    final contract = await getContract();
    final filter = FilterOptions.events(
        contract: contract, event: contract.event('CreatorRemoved'));
    Stream<FilterEvent> eventStream = client.events(filter);
    if (address != null) {
      showDialog(
          context: navigatorKey.currentContext!,
          builder: (_) =>
              WillPopScope(onWillPop: () async => false, child: alert),
          barrierDismissible: false);
    }
    eventStream.listen((event) async {
      if (event.transactionHash == address) {
        await _groupController.changeAdminRole(AdminDto(
            idChannel: channel.id!, userToUpdate: id, makeAdmin: false));
        await memberListController.refresh();
        Get.back();
      }
    });
  }

  updateGroupInfoMethod(
      BuildContext context,
      Web3App connector,
      SessionConnect? args,
      Channel channel,
      String wallet,
      AlertDialog alert,
      String nameOfGroup,
      double fee,
      TextEditingController nameGroupController,
      TextEditingController priceController) async {
    var address = await updateGroupInfo(
        connector,
        args,
        [
          BigInt.parse(channel.extraData['idGroupBlockChain'] as String),
          nameOfGroup,
          "",
          BigInt.from(fee * 1e18)
        ],
        wallet);
    final contract = await getContract();
    final filter = FilterOptions.events(
        contract: contract, event: contract.event("GroupUpdated"));
    Stream<FilterEvent> eventStream = client.events(filter);
    if (address != null) {
      showDialog(
          context: navigatorKey.currentContext!,
          builder: (_) =>
              WillPopScope(onWillPop: () async => false, child: alert),
          barrierDismissible: false);
    }
    eventStream.listen((event) async {
      if (event.transactionHash == address) {
        if (nameGroupController.text.isNotEmpty ||
            !_profileController.urlPictureGroup.value.isNullOrBlank!) {
          if (_profileController.urlPictureGroup.value.isNullOrBlank!) {
            await _chatController.channel.value!
                .updatePartial(set: {"nameOfGroup": nameGroupController.text});
            _chatController.channel.refresh();
          } else {
            await _chatController.channel.value!.updatePartial(set: {
              "nameOfGroup": nameGroupController.text.isEmpty
                  ? _chatController.channel.value!.extraData['nameOfGroup']
                      as String
                  : nameGroupController.text,
              "picOfGroup": _profileController.urlPictureGroup.value
            });
            _chatController.needToRefresh.value = true;
            _chatController.channel.refresh();
          }
        }
        _chatController.isEditingGroup.value = false;
        nameGroupController.clear();
        priceController.clear();
        Get.back();
      }
    });
  }

  AlertDialog blockchainInfo(String info) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, top: 12),
            child: CircularProgressIndicator(
              color: SColors.activeColor,
            ),
          ),
          const Text(
            "Please, wait while the transaction is processed. This may take some time.",
            style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
