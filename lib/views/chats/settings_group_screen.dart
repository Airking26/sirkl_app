// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndialog/ndialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sirkl/global_getx/chats/chats_controller.dart';

import 'package:sirkl/global_getx/common/common_controller.dart';
import 'package:sirkl/common/model/report_dto.dart';
import 'package:sirkl/common/model/request_to_join_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:http/http.dart' as htp;
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/common/web3/web3_controller.dart';

import 'package:sirkl/global_getx/navigation/navigation_controller.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:web3dart/web3dart.dart';

import '../../config/s_colors.dart';
import '../../global_getx/home/home_controller.dart';
import '../../global_getx/profile/profile_controller.dart';
import '../../views/group/group_participants_screen.dart';
import 'detailed_chat_screen.dart';
import 'nested_detailed_chat_screen.dart';
import 'requests_waiting_for_approval_screen.dart';


class SettingsGroupScreen extends StatefulWidget {
  const SettingsGroupScreen({Key? key}) : super(key: key);

  @override
  State<SettingsGroupScreen> createState() => _SettingsGroupScreenState();
}

class _SettingsGroupScreenState extends State<SettingsGroupScreen> {


  ProfileController get _profileController => Get.find<ProfileController>();  
  HomeController get _homeController => Get.find<HomeController>();
  CommonController get _commonController => Get.find<CommonController>();
  ChatsController get _chatController => Get.find<ChatsController>();
  NavigationController get _navigationController => Get.find<NavigationController>();

  final _nameGroupController = TextEditingController();
  final web3Controller = Get.put(Web3Controller());
  final utils = Utils();

  @override
  void initState() {
    _chatController.retrieveRequestsWaiting(_chatController.channel.value!.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var k = _chatController.channel.value!.membership != null;
    var fk = _chatController.channel.value!.membership?.channelRole == "channel_member";
    var f  = _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value);
    var kf = _chatController.channel.value?.createdBy?.id != _homeController.id.value;
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : const Color.fromARGB(255, 247, 253, 255),
    body: Obx(() => SingleChildScrollView(child:
    Column(children: [
      buildAppbar(context),
      const SizedBox(height: 24,),
      InkWell(
        onTap: () async {
          if (_chatController
              .isEditingGroup.value) {
            await _profileController.getImageForGroup();
          }
        },
        child: Align(
          alignment: Alignment.center,
          child: ClipOval(
            child: SizedBox.fromSize(
              size: const Size.fromRadius(70),
              child: _chatController.channel.value!.extraData["picOfGroup"] == null
                  ? TinyAvatar(
                  baseString: _chatController.channel.value!.extraData['nameOfGroup'] as String,
                  dimension: 140,
                  circular: true,
                  colourScheme: TinyAvatarColourScheme
                      .seascape)
                  : CachedNetworkImage(
                  imageUrl: !_profileController.urlPictureGroup.value.isNullOrBlank! ? _profileController.urlPictureGroup.value : _chatController.channel.value!.extraData["picOfGroup"] as String,
                  color: Colors.white.withOpacity(0.0),
                  fit: BoxFit.cover,
                  colorBlendMode:
                  BlendMode.difference,
                  placeholder: (context, url) =>
                   Center(
                      child: CircularProgressIndicator(
                          color: SColors.activeColor)),
                  errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")),
            ),
          ),
        ),
      ),
      const SizedBox(height: 32,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (_chatController.channel.value!.membership != null && _chatController.channel.value!.membership?.channelRole == "channel_member") && _chatController.channel.value?.createdBy?.id != _homeController.id.value
              || (_chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value) && _chatController.channel.value?.createdBy?.id != _homeController.id.value) ?
          const SizedBox() : InkWell(
            onTap: () async {
              if((_chatController.channel.value!.membership != null || _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value)) && (_chatController.channel.value!.membership?.channelRole == "channel_moderator" || (_chatController.channel.value?.createdBy?.id == _homeController.id.value))){
                _chatController.isEditingGroup.value = true;
              } else {
                if (_chatController.channel.value!
                    .extraData["isGroupPrivate"] as bool) {
                 if(await _chatController.requestToJoinGroup(RequestToJoinDto(
                      receiver: _chatController.channel.value!.createdBy?.id,
                      requester: _homeController.id.value, channelId: _chatController.channel.value!.id,
                  channelName: _chatController.channel.value!.extraData["nameOfGroup"] as String, paying: _chatController.channel.value!.extraData["isGroupPaying"] != null && _chatController.channel.value!.extraData["isGroupPaying"] == true ? true : false))) {
                   utils.showToast(context, "Your request has been sent, you will be notify if it is accepted");
                 } else {
                   utils.showToast(context, "Request already sent");
                 }
                } else {
                  if (_chatController.channel.value?.extraData["price"] != null) {
                    AlertDialog alert = AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:  [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0, top: 12),
                            child: CircularProgressIndicator(color: SColors.activeColor,),
                          ),
                          Text("Please, wait while group is created on the blockchain. This may take some time.", style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                        ],),
                    );
                    await _homeController.connectWallet(context);
                    var client = Web3Client("https://goerli.infura.io/v3/c193b412278e451ea6725b674de75ef2", htp.Client());
                  //  var address = await web3Controller.joinGroup(client, [BigInt.parse(_chatController.channel.value?.extraData["idGroupBlockChain"] as String)], _homeController.connector.value, _chatController.channel.value?.extraData["price"] is double ? _chatController.channel.value?.extraData["price"] as double : (_chatController.channel.value?.extraData["price"] as int).toDouble());
                    final contract = await web3Controller.getContract();
                    final filter = FilterOptions.events(contract: contract, event: contract.event('GroupJoined'));
                    Stream<FilterEvent> eventStream = client.events(filter);
                  //  if(address != null) alert.show(context, barrierDismissible: false);
                    eventStream.listen((event) async {
                   //   if(address == event.transactionHash) {
                     //   await _chatController.channel.value?.addMembers([_homeController.id.value]);
                        Get.back();
                     // }
                    });
                  } else {
                    await _chatController.channel.value!.addMembers(
                        [_homeController.id.value]);
                    Navigator.pop(context);
                    _chatController.fromGroupJoin.value = true;
                    pushNewScreen(context, screen: DetailedChatScreen(
                      create: false,
                      channelId: _chatController.channel.value!.id,)).then((
                        value) =>
                    _navigationController.hideNavBar.value = false);
                  }
                }
              }
            },
            child: Material(
              borderRadius: BorderRadius.circular(10),
              elevation: 5 ,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF113751) : Colors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon( (_chatController.channel.value!.membership != null || _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value)) && (_chatController.channel.value!.membership?.channelRole == "channel_moderator" || _chatController.channel.value?.createdBy?.id == _homeController.id.value) ? Icons.mode_edit_rounded : Icons.add_rounded, color : MediaQuery.of(context).platformBrightness == Brightness.dark ?  Colors.white : Colors.black),
                    const SizedBox(height: 4),
                    Text((_chatController.channel.value!.membership != null || _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value)) && (_chatController.channel.value!.membership?.channelRole == "channel_moderator" || _chatController.channel.value?.createdBy?.id == _homeController.id.value)? "Edit" : "Join", style: const TextStyle(fontFamily: "Gilroy"),),
                    (_chatController.channel.value?.extraData["price"] != null) ?
                    Text('${_chatController.channel.value?.extraData["price"] is double ? _chatController.channel.value?.extraData["price"] as double : (_chatController.channel.value?.extraData["price"] as int).toDouble()}ETH', style: const TextStyle(fontFamily: "Gilroy", fontSize: 10),) : const SizedBox(),
                  ],),
              ),
            ),
          ),
          SizedBox(width:  ((_chatController.channel.value!.membership != null || _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value)) && _chatController.channel.value?.createdBy?.id != _homeController.id.value) ? 0 : 16,),
          InkWell(
            onTap: () async {
              var uri = await _profileController.createDynamicLink("/joinGroup?id=${_chatController.channel.value!.id!}");
              Share.share("Join this group ${uri.toString()}");
            },
            child: Material(
              borderRadius: BorderRadius.circular(10),
              elevation: 5 ,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF113751) : Colors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share_outlined, color : MediaQuery.of(context).platformBrightness == Brightness.dark ?  Colors.white : Colors.black),
                    const SizedBox(height: 4),
                    const Text("Share", style: TextStyle(fontFamily: "Gilroy"),)
                  ],),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24,),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: (){
                if(_chatController.channel.value!.membership != null || _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value)) {
                  pushNewScreen(context, screen: GroupParticipantScreen(fromChat: true));
                } else {
                  utils.showToast(context, "You have to be a member to access this data");
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Participants (${_chatController.channel.value!.memberCount!})", style: const TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
              ),
            ),
            (_chatController.channel.value!.membership != null || _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value)) && _chatController.requestsWaiting.isNotEmpty && ((_chatController.channel.value?.createdBy?.id == _homeController.id.value) ||  _chatController.channel.value!.membership?.channelRole == "channel_moderator")?
            Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.white : Colors.black,) : const SizedBox(),
            (_chatController.channel.value!.membership != null || _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value)) && _chatController.requestsWaiting.isNotEmpty && ((_chatController.channel.value?.createdBy?.id == _homeController.id.value) ||  _chatController.channel.value!.membership?.channelRole == "channel_moderator")? InkWell(
              onTap: () async {
                pushNewScreen(context, screen: const RequestWaitingForApprovalScreen());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Waiting for approval (${_chatController.requestsWaiting.length})", style: const TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
              ),
            ) : const SizedBox(),
            Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.white : Colors.black,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Notifications", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
                  SizedBox(
                    height: 20,
                    child: Switch(
                      value: (_chatController.channel.value!.membership != null || _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value)) &&
                          !_chatController.channel.value!.isMuted ,
                      onChanged: (_chatController.channel.value!.membership != null || _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value)) ? (active) async {
                        if(!active) {
                          await StreamChat
                              .of(context)
                              .client
                              .muteChannel(
                              _chatController.channel.value!.cid!);
                          _chatController.channel.refresh();
                        } else {
                          await StreamChat
                              .of(context)
                              .client
                              .unmuteChannel(
                              _chatController.channel.value!.cid!);
                          _chatController.channel.refresh();
                        }
                      } : null, activeColor: SColors.activeColor, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,),
                  )
                ],
              ),
            ),
            Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.white : Colors.black,),
            _chatController.channel.value?.createdBy?.id != _homeController.id.value ? InkWell(
              onTap: () async {
                await _commonController.getUserById(_chatController.channel.value!.createdBy!.id);
                pushNewScreen(context, screen: const NestedDetailedChatScreen(create: true), withNavBar: false).then((value) => _navigationController.hideNavBar.value = true);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Contact owner", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
              ),
            ) : const SizedBox(),
            _chatController.channel.value?.createdBy?.id != _homeController.id.value ? Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.white : Colors.black,) : const SizedBox(),
            InkWell(
              onTap: () async {
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => CupertinoAlertDialog(
                      title: Text("Report", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),),
                      actions: [
                        CupertinoDialogAction(child:Text("Harassment or bullying", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                          onPressed: () async {
                            await _commonController.report(context, ReportDto(createdBy: _homeController.id.value, idSignaled: _chatController.channel.value!.id!, description: "Harassment or bullying", type: 1), utils);
                            Get.back();
                          },),
                        CupertinoDialogAction(child:Text("Hate speech or discrimination", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                          onPressed: () async {
                            await _commonController.report(context, ReportDto(createdBy: _homeController.id.value, idSignaled: _chatController.channel.value!.id!, description: "Hate speech or discrimination", type: 1), utils);
                            Get.back();
                          },),
                        CupertinoDialogAction(child:Text("Explicit or inappropriate content", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                          onPressed: () async {
                            await _commonController.report(context, ReportDto(createdBy: _homeController.id.value, idSignaled: _chatController.channel.value!.id!, description: "Explicit or inappropriate content", type: 1), utils);
                            Get.back();
                          },),
                        CupertinoDialogAction(child:Text("Spam or scams", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                          onPressed: () async {
                            await _commonController.report(context, ReportDto(createdBy: _homeController.id.value, idSignaled: _chatController.channel.value!.id!, description: "Spam or scams", type: 1), utils);
                            Get.back();
                          },),
                        CupertinoDialogAction(child:Text("Privacy violations", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white.withOpacity(0.5): Colors.black.withOpacity(0.5))),
                          onPressed: () async {
                            await _commonController.report(context, ReportDto(createdBy: _homeController.id.value, idSignaled: _chatController.channel.value!.id!, description: "Privacy violations", type: 1), utils);
                            Get.back();
                          },),
                      ],
                    ));
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Report", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
              ),
            ),
            (_chatController.channel.value!.membership != null || _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value)) ? Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.white : Colors.black,) :  const SizedBox(),
            (_chatController.channel.value!.membership != null || _chatController.channel.value!.state!.members.map((e) => e.userId!).contains(_homeController.id.value)) ?
            InkWell(
              onTap: () async {
                showDialog(context: context,
                    barrierDismissible: true,
                    builder: (_) =>
                    CupertinoAlertDialog(
                      title: Text("Quit Group", style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Gilroy",
                          color: MediaQuery
                              .of(context)
                              .platformBrightness == Brightness.dark ? Colors
                              .white : Colors.black),),
                      content: Text("Are you sure?",
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Gilroy",
                              color: MediaQuery
                                  .of(context)
                                  .platformBrightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.5))),
                      actions: [
                        CupertinoDialogAction(child: Text("No",
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Gilroy",
                                color: MediaQuery
                                    .of(context)
                                    .platformBrightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black)), onPressed: () {
                          Get.back();
                        },),
                        CupertinoDialogAction(child: Text("Yes",
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Gilroy",
                                color: MediaQuery
                                    .of(context)
                                    .platformBrightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black)),
                          onPressed: () async {
                            await _chatController.channel.value!.removeMembers([_homeController.id.value]);
                            Get.back();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },)
                      ],
                    )
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Leave the group", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
              ),
            ) : const SizedBox(),
            _chatController.channel.value?.createdBy?.id == _homeController.id.value ||
                _chatController.channel.value?.membership?.channelRole == "channel_moderator" ? Divider(color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.white : Colors.black,) : const SizedBox(),
            _chatController.channel.value?.createdBy?.id == _homeController.id.value ||
                _chatController.channel.value?.membership?.channelRole == "channel_moderator" ? InkWell(
              onTap: () async {
                showDialog(context: context,
                    barrierDismissible: true,
                    builder: (_) =>
                        CupertinoAlertDialog(
                          title: Text("Delete Group", style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Gilroy",
                              color: MediaQuery
                                  .of(context)
                                  .platformBrightness == Brightness.dark ? Colors
                                  .white : Colors.black),),
                          content: Text("Are you sure? This action is irreversible",
                              style: TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Gilroy",
                                  color: MediaQuery
                                      .of(context)
                                      .platformBrightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.5))),
                          actions: [
                            CupertinoDialogAction(child: Text("No",
                                style: TextStyle(fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Gilroy",
                                    color: MediaQuery
                                        .of(context)
                                        .platformBrightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black)), onPressed: () {
                              Get.back();
                            },),
                            CupertinoDialogAction(child: Text("Yes",
                                style: TextStyle(fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Gilroy",
                                    color: MediaQuery
                                        .of(context)
                                        .platformBrightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black)),
                              onPressed: () async {
                                if (!_chatController.channel.value!.id!.startsWith(
                                    "!members")) {
                                  await _chatController.deleteInbox(
                                      _chatController.channel.value!.id!);
                                }
                                await _chatController.channel.value!.delete();
                                Get.back();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },)
                          ],
                        )
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Delete the group", style: TextStyle(fontFamily: "Gilroy", fontSize: 18, fontWeight: FontWeight.w500),),
              ),
            ) : const SizedBox(),
          ],
        ),
      )
    ],)
      ,)),);
  }

  Container buildAppbar(BuildContext context) {
    return Container(
      height: 115,
      margin: const EdgeInsets.only(bottom: 0.25),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 0.01), //(x,y)
            blurRadius: 0.01,
          ),
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E2032) : Colors.white
            ]),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: (){Navigator.pop(context);},
                child: Icon(Icons.keyboard_arrow_left_rounded,size: 42,color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: _chatController.isEditingGroup.value ? SizedBox(
                  width: 200,
                  child: TextField(
                    //autofocus: true,
                    maxLines: 1,
                    controller: _nameGroupController,
                    maxLength: 10,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Gilroy",
                        fontWeight: FontWeight.w600,
                        color: MediaQuery.of(context)
                            .platformBrightness ==
                            Brightness.dark
                            ? Colors.white
                            : Colors.black),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        hintText: _chatController.channel.value!.extraData['nameOfGroup'] as String),
                  ),
                ) : Text(
                  formatName(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w600,
                      color: MediaQuery.of(context)
                          .platformBrightness ==
                          Brightness.dark
                          ? Colors.white
                          : Colors.black),
                ),
              ), _chatController.isEditingGroup.value ? InkWell(
                onTap: () async {
                  if(_nameGroupController.text.isNotEmpty || !_profileController.urlPictureGroup.value.isNullOrBlank!){
                    if(_profileController.urlPictureGroup.value.isNullOrBlank!){
                      await _chatController.channel.value!.updatePartial(set: {"nameOfGroup": _nameGroupController.text});
                      _chatController.channel.refresh();
                    } else {
                      await _chatController.channel.value!.updatePartial(set: {"nameOfGroup": _nameGroupController.text.isEmpty ? _chatController.channel.value!.extraData['nameOfGroup'] as String : _nameGroupController.text, "picOfGroup": _profileController.urlPictureGroup.value});
                      _chatController.needToRefresh.value = true;
                      _chatController.channel.refresh();
                    }
                  }
                  _chatController.isEditingGroup.value = false;
                },
                child:  Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0, left: 16),
                  child: Text("DONE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          SColors.activeColor)),
                ),
              ): IconButton(
                  onPressed: () async {
                  },
                  icon:  Icon(Icons.more_vert_outlined, size: 30, color: MediaQuery.of(context)
                      .platformBrightness ==
                      Brightness.dark
                      ? Colors.transparent
                      : Colors.transparent))
            ],
          ),
        ),
      ),
    );
  }

  String formatName(){
    if(_chatController.channel.value!.extraData["isGroupPrivate"] as bool){
      return "${_chatController.channel.value!.extraData['nameOfGroup'] as String} (Private)";
    } else {
      return (_chatController.channel.value!.extraData['nameOfGroup'] as String);
    }
  }

  @override
  void dispose() {
    _chatController.isEditingGroup.value = false;
    _chatController.requestsWaiting.clear();
    super.dispose();
  }

}