// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndialog/ndialog.dart';
import 'package:sirkl/global_getx/chats/chats_controller.dart';

import 'package:sirkl/global_getx/common/common_controller.dart';
import 'package:sirkl/common/model/inbox_creation_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/global_getx/web3/web3_controller.dart';
import 'package:sirkl/global_getx/home/home_controller.dart';
import 'package:sirkl/views/chats/detailed_chat_screen.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as htp;

import '../../config/s_colors.dart';
import '../../global_getx/profile/profile_controller.dart';
import '../../global_getx/navigation/navigation_controller.dart';
import 'create_group_second_screen.dart';

class CreateGroupFirstScreen extends StatefulWidget {
  const CreateGroupFirstScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupFirstScreen> createState() => _CreateGroupFirstScreenState();
}

class _CreateGroupFirstScreenState extends State<CreateGroupFirstScreen> {

  ProfileController get _profileController => Get.find<ProfileController>();
  ChatsController get _chatController => Get.find<ChatsController>();
  HomeController get _homeController => Get.find<HomeController>();
  Web3Controller get _web3Controller => Get.find<Web3Controller>();
  CommonController get _commonController => Get.find<CommonController>();

  NavigationController get _navigationController => Get.find<NavigationController>();
  final _priceController = TextEditingController();
  final _utils = Utils();

  @override
  void initState() {
    //_homeController.getDropDownList(_homeController.userMe.value.wallet!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : const Color.fromARGB(255, 247, 253, 255),
      body: Obx(() =>
          Column(children: [
        buildAppbar(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 24,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: MediaQuery.of(context).platformBrightness == Brightness.dark? const Color(0xFF122034) : Colors.white, width: 5),
                            borderRadius: BorderRadius.circular(90)),
                        child:
                        ClipOval(child: SizedBox.fromSize(size: const Size.fromRadius(30),
                          child: GestureDetector(onTap: () async {
                            await _profileController.getImageForGroup();
                          },
                              child:
                              Obx(() => CachedNetworkImage(imageUrl: _profileController.urlPictureGroup.value, color: Colors.white.withOpacity(0.0),fit: BoxFit.cover, colorBlendMode: BlendMode.difference,placeholder: (context, url) =>  Center(child: CircularProgressIndicator(color: SColors.activeColor)),
                                  errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png"))))
                          ,),)
                    ),
                    const SizedBox(width: 8,),
                    Expanded(
                      child: TextField(
                        controller: _chatController.groupTextController.value,
                        onChanged: (query){
                          if(query.isEmpty) {
                            _chatController.groupNameIsEmpty.value = true;
                          } else {
                            _chatController.groupNameIsEmpty.value = false;
                          }
                        },
                        style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500),
                        cursorColor: SColors.activeColor,
                        maxLines: 1,
                        maxLength: 10,
                        decoration:  InputDecoration(hintText: "Name of the group", hintStyle: const TextStyle(fontFamily: "Gilroy"),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: SColors.activeColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: SColors.activeColor),
                          ), ),
                      ),
                    )
                  ],),
              ),
              const SizedBox(height: 24,),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF113751) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          _chatController.groupTypeCollapsed.value = !_chatController.groupTypeCollapsed.value;
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Group type", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),),
                            Text(_chatController.groupType.value == 0 ? "Public" : "Private", style: const TextStyle(color: Colors.grey, fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 16),)
                          ],),
                      ),
                      _chatController.groupTypeCollapsed.value ? const SizedBox(width : 0, height: 0) : const SizedBox(height: 16,),
                      _chatController.groupTypeCollapsed.value ? const SizedBox(width : 0, height: 0) : Transform.translate(
                        offset: const Offset(-16, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(value: _chatController.groupType.value == 0, onChanged: (checked){
                              if(checked!) _chatController.groupType.value = 0;
                            },
                              checkColor: SColors.activeColor,
                              fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              side: MaterialStateBorderSide.resolveWith(
                                    (states) => const BorderSide(width: 0.0, color: Colors.transparent),
                              ),),
                            InkWell(onTap: (){
                              _chatController.groupType.value = 0;
                            },child: Text("Public", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),))
                          ],),
                      ),
                      _chatController.groupTypeCollapsed.value ? const SizedBox(width : 0, height: 0) : Transform.translate(
                        offset: const Offset(-16, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(value: _chatController.groupType.value == 1, onChanged: (checked){
                              if(checked!) _chatController.groupType.value = 1;
                            },
                              checkColor: SColors.activeColor,
                              fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              side: MaterialStateBorderSide.resolveWith(
                                    (states) => const BorderSide(width: 0.0, color: Colors.transparent),
                              ),),
                            InkWell(onTap: (){
                              _chatController.groupType.value = 1;
                            }, child: Text("Private", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),))
                          ],),
                      ),
                    ],
                  ),
                ),
              ),
              _chatController.groupTypeCollapsed.value ? const SizedBox(width : 0, height: 0) : Padding(
                padding: EdgeInsets.only(bottom: 16.0, left: _chatController.groupType.value == 0  ? 0 : 24, right: 24, top: 8),
                child: Text(_chatController.groupType.value == 0  ? "This group is open to everyone interested in joining!" : "Users can request to join your groups, but access will only be granted upon approval from an admin.", textAlign: TextAlign.start, style: const TextStyle(fontFamily: "Gilroy", color:
                Colors.grey, fontWeight: FontWeight.w500, fontSize: 13),),
              ),
              SizedBox(height: _chatController.groupVisibilityCollapsed.value || _chatController.groupTypeCollapsed.value ? 8 : 24,),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF113751) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          _chatController.groupVisibilityCollapsed.value = !_chatController.groupVisibilityCollapsed.value;
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Visible", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),),
                            Text(_chatController.groupVisibility.value == 0 ? "Yes" : "No", style: const TextStyle(color: Colors.grey, fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 16),)
                          ],),
                      ),
                      _chatController.groupVisibilityCollapsed.value ? const SizedBox(width: 0, height: 0,) : const SizedBox(height: 16,),
                      _chatController.groupVisibilityCollapsed.value ? const SizedBox(width: 0, height: 0,) : Transform.translate(
                        offset: const Offset(-16, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(value: _chatController.groupVisibility.value == 0, onChanged: (checked){
                              if(checked!) _chatController.groupVisibility.value = 0;
                            },
                              checkColor: SColors.activeColor,
                              fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              side: MaterialStateBorderSide.resolveWith(
                                    (states) => const BorderSide(width: 0.0, color: Colors.transparent),
                              ),),
                            InkWell(onTap : (){
                              _chatController.groupVisibility.value = 0;
                            },child: Text("Yes", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),))
                          ],),
                      ),
                      _chatController.groupVisibilityCollapsed.value ? const SizedBox(width: 0, height: 0,) : Transform.translate(
                        offset: const Offset(-16, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(value: _chatController.groupVisibility.value == 1, onChanged: (checked){
                              if(checked!) _chatController.groupVisibility.value = 1;
                            },
                              checkColor: SColors.activeColor,
                              fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              side: MaterialStateBorderSide.resolveWith(
                                    (states) => const BorderSide(width: 0.0, color: Colors.transparent),
                              ),),
                            InkWell(onTap: (){
                              _chatController.groupVisibility.value = 1;
                            },
                                child: Text("No", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),))
                          ],),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: _chatController.groupVisibilityCollapsed.value || _chatController.groupTypeCollapsed.value ? 8 : 24,),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF113751) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          _chatController.groupPayingCollapsed.value = !_chatController.groupPayingCollapsed.value;
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Paying", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),),
                            Text(_chatController.groupPaying.value == 0 ? "No" : "Yes", style: const TextStyle(color: Colors.grey, fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 16),)
                          ],),
                      ),
                      _chatController.groupPayingCollapsed.value ? const SizedBox(width: 0, height: 0,) : const SizedBox(height: 16,),
                      _chatController.groupPayingCollapsed.value ? const SizedBox(width: 0, height: 0,) : Transform.translate(
                        offset: const Offset(-16, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(value: _chatController.groupPaying.value == 0, onChanged: (checked){
                              if(checked!) _chatController.groupPaying.value = 0;
                            },
                              checkColor: SColors.activeColor,
                              fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              side: MaterialStateBorderSide.resolveWith(
                                    (states) => const BorderSide(width: 0.0, color: Colors.transparent),
                              ),),
                            InkWell(onTap : (){
                              _chatController.groupPaying.value = 0;
                            },child: Text("No", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),))
                          ],),
                      ),
                      _chatController.groupPayingCollapsed.value ? const SizedBox(width: 0, height: 0,) : Transform.translate(
                        offset: const Offset(-16, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(value: _chatController.groupPaying.value == 1, onChanged: (checked){
                              _chatController.groupPaying.value = 1;
                              /*if(checked! && _homeController.dropDownMenuItems.isNotEmpty) {
                                _chatController.groupPaying.value = 1;
                              } else
                                _utils.showToast(context, "You don't have any token link with this wallet.");
                                */
                            },
                              checkColor: SColors.activeColor,
                              fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              side: MaterialStateBorderSide.resolveWith(
                                    (states) => const BorderSide(width: 0.0, color: Colors.transparent),
                              ),),
                            InkWell(onTap: (){
                              _chatController.groupPaying.value = 1;
                              /*if(_homeController.dropDownMenuItems.isNotEmpty) {
                                _chatController.groupPaying.value = 1;
                              } else {
                                _utils.showToast(context, "You don't have any token link with this wallet.");
                              }*/

                            },
                                child: Text("Yes", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),))
                          ],),

                      ),
                      _chatController.groupPaying.value == 0 || _chatController.groupPayingCollapsed.value ? const SizedBox(width: 0, height: 0,) : Transform.translate(
                        offset: const Offset(-16, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 20,),
                            Transform.translate(offset: const Offset(0, 8), child: Text("Admission Price : ", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),)),
                            const Spacer(),
                            Transform.translate(offset: const Offset(0, 3.75),
                                child:  SizedBox(width: 50,
                                  child: TextField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,cursorColor: SColors.activeColor, decoration: const InputDecoration(
                                      hintText: "0.0", hintStyle: TextStyle(fontWeight: FontWeight.w500, fontFamily: "Gilroy", fontSize: 18),contentPadding: EdgeInsets.only(bottom: 4), isDense: true, enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                                  ), focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 0.5),
                                  ),  ),),)),
                        const SizedBox(width: 4,),
                        DropdownButton<dynamic>(
                        items: [DropdownMenuItem(
                            child: Row(
                              children: [
                                Image.network(
                                  "https://raw.githubusercontent.com/dappradar/tokens/main/ethereum/0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee/logo.png",
                                  width: 22,
                                  height: 22,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                const Text(
                                  "ETH",
                                  style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w500),
                                )
                              ],
                            ))],
                            onChanged: (any){})
                          ],),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24,),
            ],),
          ),
        ),
      ],)),
    );
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
        padding: const EdgeInsets.only(top: 44.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () {
                _profileController.urlPictureGroup.value = "";
                _chatController.groupTextController.value.text = "";
                Navigator.pop(context);
                }, child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontFamily: "Gilroy"),),),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  "New group",
                  style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy",
                      fontSize: 20),
                ),
              ),
              TextButton(onPressed: () async {
                if(_chatController.groupTextController.value.text.isEmpty) {
                  _utils.showToast(context, "Please, enter a name for you group.");
                } else {
                  if(_chatController.groupPaying.value == 1){
                    if(_priceController.text.isNotEmpty && isNumeric(_priceController.text)){
                      await createPaidGroup();
                    }
                    else if(_priceController.text.isEmpty || (_priceController.text.isNotEmpty && double.parse(_priceController.text.replaceAll(RegExp('[^A-Za-z0-9]'), '.')) == 0.0) || (_priceController.text.isNotEmpty && !isNumeric(_priceController.text))){
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : const Color(0xFF102437),
                            content: Text("Fee value invalid", textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "Gilroy", fontSize: 15, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF102437) : Colors.white),),
                          )
                      );
                    }
                  } else {
                    pushNewScreen(
                        context, screen: const CreateGroupSecondScreen(), withNavBar: false).then((
                        value) {
                      _navigationController.hideNavBar.value = true;
                    });
                  }
                }
              }, child:
              _web3Controller.loadingToCreateGroup.value ?
              SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: SColors.activeColor, strokeWidth: 2,)) :
              Text("Create", style: TextStyle(color: _chatController.groupNameIsEmpty.value ? Colors.grey : SColors.activeColor, fontFamily: "Gilroy", fontWeight: FontWeight.w600,),)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createPaidGroup() async{
    _web3Controller.loadingToCreateGroup.value = true;
     AlertDialog alert = _web3Controller.blockchainInfo("Please, wait while group is created on the Blockchain. This may take some time.");
     var client = _web3Controller.client;
     var price = double.parse(_priceController.text.replaceAll(RegExp('[^A-Za-z0-9]'), '.')) * 1e18;
     var connector = await _web3Controller.connect();
     connector.onSessionConnect.subscribe((args) async {
       var address = await _web3Controller.createGroup(
         connector, args,
           [_chatController.groupTextController.value.text, "A small example", BigInt.from(price), EthereumAddress.fromHex("0x0000000000000000000000000000000000000000")],
           _homeController.userMe.value.wallet!);
       final contract = await _web3Controller.getContract();
       final filter = FilterOptions.events(
         contract: contract,
         event: contract.event('GroupCreated'),
       );

       Stream<FilterEvent> eventStream = client.events(filter);
       if(address != null) showDialog(context: context, builder: (_) => WillPopScope(onWillPop : () async => false, child: alert), barrierDismissible: false);
       eventStream.listen((event) async {
         final decoded = contract.event("GroupCreated").decodeResults(event.topics!, event.data!);
         if(address == event.transactionHash) {
           _chatController.messageSending.value = true;
           var idChannel = DateTime
               .now()
               .millisecondsSinceEpoch
               .toString();
           var idChannelCreated = await _chatController.createInbox(
               InboxCreationDto(
                   price: double.parse(_priceController.text),
                   tokenAccepted: "0x0000000000000000000000000000000000000000",
                   idGroupBlockchain: decoded[0].toString(),
                   isConv: false,
                   createdBy: _homeController.id.value,
                   isGroupPrivate: _chatController.groupType.value == 0
                       ? false
                       : true,
                   isGroupVisible: _chatController.groupVisibility.value == 0
                       ? true
                       : false,
                   isGroupPaying: true,
                   wallets: [_homeController.userMe.value.wallet!],
                   nameOfGroup: _chatController.groupTextController.value.text,
                   picOfGroup: _profileController.urlPictureGroup.value,
                   idChannel: idChannel));
           _web3Controller.loadingToCreateGroup.value = false;
           Get.back();
           FocusManager.instance.primaryFocus?.unfocus();
           _chatController.messageSending.value = false;
           _profileController.urlPictureGroup.value = "";
           _chatController.groupTextController.value.text = "";
           _chatController.fromGroupCreation.value = true;
           _commonController.refreshAllInbox();
           Navigator.popUntil(context, (route) => route.isFirst);
           WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
             pushNewScreen(context, screen: DetailedChatScreen(
               create: false, channelId: idChannelCreated,)).then((value) =>
             _navigationController.hideNavBar.value = false);
           });
         }
       });
     });


  }

  @override
  void dispose() {
    _chatController.groupVisibilityCollapsed.value = true;
    _chatController.groupTypeCollapsed.value = true;
    _chatController.groupType.value = 0;
    _chatController.groupVisibility.value = 0;
    _priceController.clear();
    super.dispose();
  }

}
