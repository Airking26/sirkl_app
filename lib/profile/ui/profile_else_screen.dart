import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/collection_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/detailed_message/detailed_message_screen.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/view/stream_chat/src/stream_chat.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import '../../common/view/dialog/custom_dial.dart';

class ProfileElseScreen extends StatefulWidget {
  const ProfileElseScreen({Key? key, required this.fromConversation}) : super(key: key);
  final bool fromConversation;

  @override
  State<ProfileElseScreen> createState() => _ProfileElseScreenState();
}

class _ProfileElseScreenState extends State<ProfileElseScreen> {

  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  final utils = Utils();
  YYDialog dialogMenu = YYDialog();

  @override
  void initState(){
    _commonController.checkUserIsInFollowing();
    _homeController.getNFTsTemporary(_commonController.userClicked.value!.wallet!, context);
    //_commonController.userClickedFollowStatus.value = _commonController.userClicked.value!.isInFollowing!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() =>
            Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.topCenter,
              fit: StackFit.loose,
              children: [
                Container(
                  height: 180,
                  margin: const EdgeInsets.only(bottom: 0.25),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 0.01), //(x,y)
                        blurRadius: 0.01,
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(45)),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Get.isDarkMode ? const Color(0xFF113751) : Colors.white,
                          Get.isDarkMode ? const Color(0xFF1E2032) : Colors.white
                        ]
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 44.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(onPressed: () async{
                            if(!_commonController.userClickedFollowStatus.value) {
                              if( await _commonController.addUserToSirkl(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value)){
                                utils.showToast(context, con.userAddedToSirklRes.trParams({"user": _commonController.userClicked.value!.userName ?? _commonController.userClicked.value!.wallet!}));
                              }
                            } else {
                              widget.fromConversation ? Get.back(): Get.to(() => const DetailedChatScreen(create: true));
                            }
                            }, icon: Image.asset(_commonController.userClickedFollowStatus.value ? "assets/images/chat_tab.png" : "assets/images/add_user.png", color: Get.isDarkMode ? Colors.white : Colors.black, height: 28, width: 28,)),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child:
                            Text(_commonController.userClicked.value!.userName!.isEmpty ? "${_commonController.userClicked.value!.wallet!.substring(0, 20)}..." : _commonController.userClicked.value!.userName!, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black),),
                          ),
                          IconButton(onPressed: (){
                            dialogMenu = dialogPopMenu(context);
                            }, icon: Image.asset("assets/images/more.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                        ],),
                    ),
                  ),
                ),
                Positioned(
                  top: Platform.isAndroid ? 105 : 95,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Get.isDarkMode ? const Color(0xFF122034) : Colors.white, width: 5),
                        borderRadius: BorderRadius.circular(90)),
                    child:
                        ClipOval(child: SizedBox.fromSize(size: const Size.fromRadius(70),
                          child: GestureDetector(onTap: (){},
                              child:_commonController.userClicked.value!.picture == null ?
                              TinyAvatar(baseString: _commonController.userClicked.value!.wallet!, dimension: 140, circular: true, colourScheme: TinyAvatarColourScheme.seascape) :
                            CachedNetworkImage(imageUrl: _commonController.userClicked.value!.picture! , color: Colors.white.withOpacity(0.0),fit: BoxFit.cover, colorBlendMode: BlendMode.difference,placeholder: (context, url) => Center(child: const CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")))
                          ,),)
                  ),
                ),
                Container()
              ],
            ),
            const SizedBox(height: 90,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: _commonController.userClicked.value!.wallet!));
                  utils.showToast(context, con.walletCopiedRes.tr);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Wallet: ${_commonController.userClicked.value!.wallet!.substring(0,20)}...",overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center, style: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF00CB7D), fontSize: 15),),
                    const SizedBox(width: 4,),
                    Image.asset("assets/images/copy.png", height: 18, width: 18, color: const Color(0xFF00CB7D),)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(_commonController.userClicked.value!.description ==  "" ? con.noDescYetRes.tr : _commonController.userClicked.value!.description!,  textAlign: TextAlign.center, style: const TextStyle(height: 1.5, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF828282), fontSize: 15),),
            ),
            const SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Divider(color: Color(0xFF828282),),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: _homeController.nfts.value.isNotEmpty ? Align(alignment: Alignment.topLeft, child: Text(con.myNFTCollectionRes.tr, textAlign: TextAlign.start, style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black),)) : Container(),
            ),
            _homeController.isLoadingNfts.value ? const Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: CircularProgressIndicator(),
            ) :
            _homeController.nfts.value.isNotEmpty ? MediaQuery.removePadding(
              context:  context,
              removeTop: true,
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SafeArea(
                    child: ListView.builder(
                        cacheExtent: 1000,
                        itemCount: _homeController.nfts.value.length,
                        itemBuilder: (context, index){
                          return CardNFT(_homeController.nfts.value[index], _commonController, index);
                        },
                    ),
                  ),
                ),
              ),
            ) :  Container(
              margin: const EdgeInsets.only(top: 24, left: 48, right: 48),
              child: Text(con.dontHaveNftRes.tr, textAlign: TextAlign.center, style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black, fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600),),
            )
          ],
        )));
  }

  YYDialog dialogPopMenu(BuildContext context) {
    return YYDialog().build(context)
      ..width = 180
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor = Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05)
      ..backgroundColor = Get.isDarkMode ? const Color(0xFF1E3244).withOpacity(0.95) : Colors.white
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: () async{
          dialogMenu.dismiss();
          if(_commonController.userClickedFollowStatus.value) {
            if(await _commonController.removeUserToSirkl(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value)) {
              utils.showToast(context, con.userRemovedofSirklRes.trParams({"user": _commonController.userClicked.value!.userName ?? _commonController.userClicked.value!.wallet!}));
            }
          } else {
            if(await _commonController.addUserToSirkl(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value)){
              utils.showToast(context, con.userAddedToSirklRes.trParams({"user": _commonController.userClicked.value!.userName ?? _commonController.userClicked.value!.wallet!}));
            }
          }
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(_commonController.userClickedFollowStatus.value ? con.removeOfMySirklRes.tr : con.addToMySirklRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){
          Get.to(() => const DetailedChatScreen(create: true));
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.sendAMessageRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.reportRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }

}

class CardNFT extends StatefulWidget {
  final CollectionDbDto collectionDbDTO;
  final CommonController profileController;
  final int index;
  CardNFT(this.collectionDbDTO, this.profileController, this.index, {Key? key}) : super(key: key);

  @override
  State<CardNFT> createState() => _CardNFTState();
}

class _CardNFTState extends State<CardNFT> with AutomaticKeepAliveClientMixin{

    @override
    bool get wantKeepAlive => true;

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Get.isDarkMode ? const Color(0xFF1A2E40) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 0.01), //(x,y)
                blurRadius: 0.01,
              ),
            ],
          ),
          child: ExpansionTile(
              leading: ClipRRect(borderRadius: BorderRadius.circular(90), child: CachedNetworkImage(imageUrl: widget.collectionDbDTO.collectionImages[0], width: 56, height: 56, fit: BoxFit.cover, placeholder: (context, url) => Center(child: const CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")),),
            trailing: Obx(() => Image.asset(
              widget.profileController.isCardExpandedList.value.contains(widget.index) ?
              "assets/images/arrow_up_rev.png" :
              "assets/images/arrow_down_rev.png",
              color: Get.isDarkMode ? Colors.white : Colors.black, height: 20, width: 20,),),
            title: Text(widget.collectionDbDTO.collectionName, style: TextStyle(fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text("${widget.collectionDbDTO.collectionImages.length} available", style: const TextStyle(fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF828282))),
            onExpansionChanged: (expanded){
              if(expanded) {
                widget.profileController.isCardExpandedList.value.assign(widget.index);
              } else {
                widget.profileController.isCardExpandedList.value.remove(widget.index);
              }
              widget.profileController.isCardExpandedList.refresh();
              //widget.profileController.isCardExpanded.value = expanded;
            },
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0, left: 80, right: 20),
                child: SizedBox(height: 80,
                    child: ListView.builder(
                  cacheExtent: 1000,
                  itemCount: widget.collectionDbDTO.collectionImages.length,
                  itemBuilder: (context, i){
                    return buildCard(i, widget.collectionDbDTO);
                  }, scrollDirection: Axis.horizontal,)),
              )
            ],
          ),
        ),
      );
    }

    Padding buildCard(int i, CollectionDbDto collectionDbDTO) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: (){
            //if(widget.profileController.isEditingProfile.value) widget.profileController.urlPicture.value = collectionDbDTO.collectionImages[i];
            },
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox.fromSize(
                  child: CachedNetworkImage(fit: BoxFit.cover, imageUrl: collectionDbDTO.collectionImages[i], width: 80, height: 70,placeholder: (context, url) => Center(child: const CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")))),
        ),
      );
    }



}

