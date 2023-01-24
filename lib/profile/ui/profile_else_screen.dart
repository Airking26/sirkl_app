import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/collection_dto.dart';
import 'package:sirkl/common/model/nft_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/view/stream_chat/src/stream_chat.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
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
  final _profileController = Get.put(ProfileController());
  final _navigationController = Get.put(NavigationController());
  final utils = Utils();
  YYDialog dialogMenu = YYDialog();
  final PagingController<int, NftDto> pagingController = PagingController(firstPageKey: 0);
  static var pageKey = 0;

  @override
  void initState(){
    _commonController.checkUserIsInFollowing();
    pagingController.addPageRequestListener((pageKey) {
      fetchNFTs();
    });
    super.initState();
  }

  Future<void> fetchNFTs() async {
    try {
      List<NftDto> newItems = await _homeController.getNFT(_commonController.userClicked.value!.id!, false, pageKey);
      final isLastPage = newItems.length < 12;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey++;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
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
                          MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
                          MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E2032) : Colors.white
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
                          _profileController.isEditingProfileElse.value ? InkWell(
                            onTap: () async {
                              await _profileController.updateMe(UpdateMeDto(nicknames: {_commonController.userClicked.value!.wallet! : _profileController.usernameElseTextEditingController.value.text}), StreamChat.of(context).client);
                              _homeController.updateNickname(_commonController.userClicked.value!.wallet!, _profileController.usernameElseTextEditingController.value.text);
                              _profileController.isEditingProfileElse.value = false;
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(top: 16.0, left: 16),
                              child: Text("DONE", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Gilroy', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF00CB7D))),
                            ),
                          ) :
                          IconButton(onPressed: () async{
                            if(!_commonController.userClickedFollowStatus.value) {
                              if( await _commonController.addUserToSirkl(_commonController.userClicked.value!.id!, StreamChat.of(context).client, _homeController.id.value)){
                                utils.showToast(context, con.userAddedToSirklRes.trParams({"user": _commonController.userClicked.value!.userName ?? _commonController.userClicked.value!.wallet!}));
                              }
                            } else {
                              widget.fromConversation ? Navigator.of(context).pop():
                              _navigationController.hideNavBar.value = true;
                              pushNewScreen(context, screen: const DetailedChatScreen(create: true)).then((value) => _navigationController.hideNavBar.value = false);
                            }
                            }, icon: Image.asset(_commonController.userClickedFollowStatus.value ? "assets/images/chat_tab.png" : "assets/images/add_user.png", color: _commonController.userClickedFollowStatus.value ? MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black :const Color(0xff00CB7D), height: 28, width: 28,)),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child:
                                _profileController.isEditingProfileElse.value ?
                                SizedBox(
                                  width: 200,
                                  child: TextField(
                                    autofocus: true,
                                    maxLines: 1,
                                    controller: _profileController.usernameElseTextEditingController.value,
                                    maxLength: 20,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isCollapsed: true,
                                        hintText: ""
                                    ),
                                  ),
                                ):
                                Text(_homeController.nicknames[_commonController.userClicked.value!.wallet!] ?? (_commonController.userClicked.value!.userName!.isEmpty ? "${_commonController.userClicked.value!.wallet!.substring(0, 20)}..." : _commonController.userClicked.value!.userName!), textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),),
                          ),
                          IconButton(onPressed: (){
                            dialogMenu = dialogPopMenu(context);
                            }, icon: Image.asset("assets/images/more.png", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,)),
                        ],),
                    ),
                  ),
                ),
                Positioned(
                  top: Platform.isAndroid ? 105 : 95,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: MediaQuery.of(context).platformBrightness == Brightness.dark? const Color(0xFF122034) : Colors.white, width: 5),
                        borderRadius: BorderRadius.circular(90)),
                    child:
                        ClipOval(child: SizedBox.fromSize(size: const Size.fromRadius(70),
                          child: GestureDetector(onTap: (){},
                              child:_commonController.userClicked.value!.picture == null ?
                              TinyAvatar(baseString: _commonController.userClicked.value!.wallet!, dimension: 140, circular: true, colourScheme: TinyAvatarColourScheme.seascape) :
                            CachedNetworkImage(imageUrl: _commonController.userClicked.value!.picture! , color: Colors.white.withOpacity(0.0),fit: BoxFit.cover, colorBlendMode: BlendMode.difference,placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
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
                  // ignore: use_build_context_synchronously
                  utils.showToast(context, con.walletCopiedRes.tr);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${_commonController.userClicked.value!.wallet!.substring(0,6)}...${_commonController.userClicked.value!.wallet!.substring(_commonController.userClicked.value!.wallet!.length - 4)}",overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center, style: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF00CB7D), fontSize: 15),),
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
              child: _homeController.heHasNft.value ? Align(alignment: Alignment.topLeft, child: Text(con.nFTCollectionRes.tr, textAlign: TextAlign.start, style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),)) : Container(),
            ),
            MediaQuery.removePadding(
              context:  context,
              removeTop: true,
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SafeArea(
                    child: PagedListView(
                      pagingController: pagingController,
                      builderDelegate: PagedChildBuilderDelegate<NftDto>(
                          firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF00CB7D),),),
                          newPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF00CB7D),),),
                          itemBuilder:  (context, item, index) => CardNFT(item, _commonController, index)),
                    ),
                  ),
                ),
              ),
            )

          ],
        )));
  }

  YYDialog dialogPopMenu(BuildContext context) {
    return YYDialog().build(context)
      ..width = 180
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor = MediaQuery.of(context).platformBrightness == Brightness.dark? Colors.transparent : Colors.black.withOpacity(0.05)
      ..backgroundColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E3244).withOpacity(0.95) : Colors.white.withOpacity(0.95)
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
          child: Align(alignment: Alignment.centerLeft, child: Text(_commonController.userClickedFollowStatus.value ? con.removeOfMySirklRes.tr : con.addToMySirklRes.tr, style: TextStyle(fontSize: 14,
              color: _commonController.userClickedFollowStatus.value ? MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282) :const Color(0xff00CB7D),
              fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () async {
          _profileController.isEditingProfileElse.value = true;
          dialogMenu.dismiss();
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.renameRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){
          _navigationController.hideNavBar.value = true;
          pushNewScreen(context, screen: const DetailedChatScreen(create: true)).then((value) => _navigationController.hideNavBar.value = false);
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.sendAMessageRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.reportRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }

}

class CardNFT extends StatefulWidget {
  final NftDto nftDto;
  final CommonController profileController;
  final int index;
  CardNFT(this.nftDto, this.profileController, this.index, {Key? key}) : super(key: key);

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
            color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1A2E40) : Colors.white,
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
              leading: ClipRRect(borderRadius: BorderRadius.circular(90), child: CachedNetworkImage(imageUrl: widget.nftDto.collectionImage!, width: 56, height: 56, fit: BoxFit.cover, placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                  errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")),),
            title: Text(widget.nftDto.title!, style: TextStyle(fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: MediaQuery.of(context).platformBrightness == Brightness.dark? Colors.white : Colors.black)),
            subtitle: Text("${widget.nftDto.images!.length} available", style: const TextStyle(fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF828282))),
            onExpansionChanged: (expanded){
              if(expanded) {
                widget.profileController.isCardExpandedList.value.assign(widget.index);
              } else {
                widget.profileController.isCardExpandedList.value.remove(widget.index);
              }
              widget.profileController.isCardExpandedList.refresh();
            },
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0, left: 80, right: 20),
                child: SizedBox(height: 80,
                    child: ListView.builder(
                  itemCount: widget.nftDto.images!.length,
                  itemBuilder: (context, i){
                    return buildCard(i, widget.nftDto);
                  }, scrollDirection: Axis.horizontal,)),
              )
            ],
          ),
        ),
      );
    }

    Padding buildCard(int i, NftDto nftDto) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: (){
            //if(widget.profileController.isEditingProfile.value) widget.profileController.urlPicture.value = collectionDbDTO.collectionImages[i];
            },
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox.fromSize(
                  child: CachedNetworkImage(fit: BoxFit.cover, imageUrl: nftDto.images![i], width: 80, height: 70,placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                      errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")))),
        ),
      );
    }


}

