import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_badged/flutter_badge.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/collection_dto.dart';
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/view/story_insta/drishya_picker.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/home/ui/pdf_screen.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:sirkl/profile/ui/notifications_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:video_player/video_player.dart';
import '../../common/view/dialog/custom_dial.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  late final GalleryController controller;
  final _profileController = Get.put(ProfileController());
  final _homeController = Get.put(HomeController());
  final PagingController<int, CollectionDbDto> pagingController = PagingController(firstPageKey: 0);
  final _navigationController = Get.put(NavigationController());
  YYDialog dialogMenu = YYDialog();
  static var pageKey = 0;

  final _defaultBackgrounds = [
    const GradientBackground(colors: [Color(0xFF00C6FF), Color(0xFF0078FF)]),
    const GradientBackground(colors: [Color(0xFFeb3349), Color(0xFFf45c43)]),
    const GradientBackground(colors: [Color(0xFF26a0da), Color(0xFF314755)]),
    const GradientBackground(colors: [Color(0xFFe65c00), Color(0xFFF9D423)]),
    const GradientBackground(colors: [Color(0xFFfc6767), Color(0xFFec008c)]),
    const GradientBackground(
      colors: [Color(0xFF5433FF), Color(0xFF20BDFF), Color(0xFFA5FECB)],
    ),
    const GradientBackground(colors: [Color(0xFF334d50), Color(0xFFcbcaa5)]),
    const GradientBackground(colors: [Color(0xFF1565C0), Color(0xFFb92b27)]),
    const GradientBackground(
      colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFFA5FECB)],
    ),
    const GradientBackground(colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)]),
    const GradientBackground(colors: [Color(0xFF753a88), Color(0xFFcc2b5e)]),
  ];

  final _colors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.yellow,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
  ];

  @override
  void initState(){
    controller = GalleryController();
    _profileController.checkIfHasUnreadNotif(_homeController.id.value);
    pagingController.addPageRequestListener((pageKey) {
      fetchNFTs();
    });
    _profileController.usernameTextEditingController.value.text = _homeController.userMe.value.userName!.isEmpty ? _homeController.userMe.value.wallet!.substring(0, 20) : _homeController.userMe.value.userName!;
    _profileController.descriptionTextEditingController.value.text = _homeController.userMe.value.description == "" ? "" : _homeController.userMe.value.description!;
    _profileController.urlPicture.value = _homeController.userMe.value.picture == null ? "" : _homeController.userMe.value.picture!;
    super.initState();
  }

  Future<void> fetchNFTs() async {
    try {
      List<CollectionDbDto> newItems = await _homeController.getNFTsTemporary(_homeController.userMe.value.wallet!);
      if (_homeController.cursor.value == "") {
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
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() =>
            Column(
          children: [
            DeferredPointerHandler(
              child: Stack(
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
                            _profileController.isLoadingPicture.value ?
                            Container(padding: const EdgeInsets.all(8), width: 48, height: 48, child: const CircularProgressIndicator(color: Color(0xFF00CB7D),)) :
                            _profileController.isEditingProfile.value ?
                                InkWell(
                                  onTap: (){
                                    _profileController.updateMe(UpdateMeDto(
                                        userName: _profileController.usernameTextEditingController.value.text.isEmpty ? _homeController.userMe.value.wallet! : _profileController.usernameTextEditingController.value.text,
                                        description: _profileController.descriptionTextEditingController.value.text.isEmpty ? "" : _profileController.descriptionTextEditingController.value.text,
                                        picture: _profileController.urlPicture.value
                                    ), StreamChat.of(context).client);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 16.0, left: 16),
                                    child: Text("DONE", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Gilroy', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF00CB7D))),
                                  ),
                                )
                                : IconButton(onPressed: (){
                                  pushNewScreen(context, screen: const NotificationScreen()).then((value) => _profileController.checkIfHasUnreadNotif(_homeController.id.value));
                              }, icon:

                                FlutterBadge(icon: Image.asset("assets/images/bell.png", color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,), itemCount: _profileController.hasUnreadNotif.value ? 1 : 0, hideZeroCount: true, badgeColor: const Color(0xff00CB7D), badgeTextColor: const Color(0xff00CB7D), contentPadding: const EdgeInsets.only(top: 0.1,right: 16, left: 12),)
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child:
                                  _profileController.isEditingProfile.value ?
                                 SizedBox(
                                   width: 200,
                                   child: TextField(
                                     //autofocus: true,
                                     maxLines: 1,
                                     controller: _profileController.usernameTextEditingController.value,
                                     maxLength: 20,
                                     textAlign: TextAlign.center,
                                     style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),
                                     decoration: const InputDecoration(
                                       border: InputBorder.none,
                                       isCollapsed: true,
                                       hintText: ""
                                       ),
                                   ),
                                 )
                               : Text(_homeController.userMe.value.userName!.isEmpty || _homeController.userMe.value.userName == _homeController.userMe.value.wallet ? "${_homeController.userMe.value.wallet!.substring(0, 20)}..." : _homeController.userMe.value.userName!, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),),
                            ),
                            IconButton(onPressed: ()async{
                              //_groupController.retrieveGroupsToCreate(StreamChat.of(context).client);
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
                          border: Border.all(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF122034) : Colors.white, width: 5),
                          borderRadius: BorderRadius.circular(90)),
                      child:
                          DeferPointer(
                            child: ClipOval(child: SizedBox.fromSize(size: const Size.fromRadius(70),
                              child: GestureDetector(onTap: ()async{
                                if(_profileController.isEditingProfile.value) {
                                  await _profileController.getImage();
                                }
                                },
                                  child: _profileController.urlPicture.value.isEmpty ?
                                       TinyAvatar(baseString: _homeController.userMe.value.wallet!, dimension: 140, circular: true, colourScheme: TinyAvatarColourScheme.seascape) :
                                  CachedNetworkImage(imageUrl: _profileController.urlPicture.value, color: Colors.white.withOpacity(_profileController.isEditingProfile.value ? 0.2 : 0.0),fit: BoxFit.cover, colorBlendMode: BlendMode.difference,placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                                      errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png"))

                              )
                              ,),),
                          )
                    ),
                  ),
                  _profileController.isEditingProfile.value ? Container() :
                  Positioned(
                    top: Platform.isAndroid ? 210 : 190,
                      right: MediaQuery.of(context).size.width / 3.25,
                      child: DeferPointer(
                        paintOnTop: true,
                        child: InkWell(
                          onTap:() async {
                            _navigationController.hideNavBar.value = true;
                            await controller.pick(context, setting: const GallerySetting(enableCamera: true, maximumCount: 1, requestType: RequestType.all, selectionMode: SelectionMode.actionBased)).then((value) async{
                              if(!value.first.pickedFile.isNullOrBlank!){
                                final file = await value.first.file;
                                await _profileController.postStory(file!, value.first.type == AssetType.image ? 0 : 1);
                              } else {
                                await _profileController.postStory(value.first.pickedFile!, value.first.type == AssetType.image ? 0 : 1);
                              }
                              _navigationController.hideNavBar.value = false;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF1DE99B), Color(0xFF0063FB)]),
                                borderRadius: BorderRadius.circular(90),
                                border: Border.all(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF122034) : Colors.white, width: 2)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset('assets/images/plus.png', width: 20, height: 20,),
                            ),
                          ),
                        ),
                      )
                  )
                ],
              ),
            ),
            const SizedBox(height: 90,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Text("Wallet: ${_homeController.userMe.value.wallet!.substring(0,20)}...",overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center, style: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF00CB7D), fontSize: 15),),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: _profileController.isEditingProfile.value ?
              TextField(
                maxLines: null,
                controller: _profileController.descriptionTextEditingController.value,
                maxLength: 120,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF9BA0A5) : const Color(0xFF828282)),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: ""
                ),
              ):
              Text(_homeController.userMe.value.description == "" ? con.noDescYetRes.tr : _homeController.userMe.value.description!,  textAlign: TextAlign.center, style: const TextStyle(height: 1.5, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF828282), fontSize: 15),),
            ),
            const SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Divider(color: Color(0xFF828282),),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: _homeController.nfts.value.isNotEmpty ? Align(alignment: Alignment.topLeft, child: Text(con.myNFTCollectionRes.tr, textAlign: TextAlign.start, style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),)) : Container(),
            ),
            MediaQuery.removePadding(
              context:  context,
              removeTop: true,
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SafeArea(
                    child: PagedListView(
                      pagingController: pagingController,
                        builderDelegate: PagedChildBuilderDelegate<CollectionDbDto>(
                          firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF00CB7D),),),
                          newPageProgressIndicatorBuilder: (context) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator(color: Color(0xFF00CB7D),),),
                          ),
                            itemBuilder:  (context, item, index) => CardNFT(item, _profileController, index)),
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
      ..barrierColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.transparent : Colors.black.withOpacity(0.05)
      ..backgroundColor = MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E3244).withOpacity(0.95) : Colors.white
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: (){
          _profileController.isEditingProfile.value = true;
          dialogMenu.dismiss();
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.editProfileRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.contactUsRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () async {
          dialogMenu.dismiss();
          await GetStorage().erase();
          await StreamChat.of(context).client.disconnectUser();
          _homeController.accessToken.value = "";
          _navigationController.controller.value.jumpToTab(0);
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.logoutRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){
          dialogMenu.dismiss();
          pushNewScreen(context, screen: const PDFScreen(isTermsAndConditions: false));
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.privacyPolicyRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){
          dialogMenu.dismiss();
          pushNewScreen(context, screen: const PDFScreen(isTermsAndConditions: true));
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.termsAndConditionsRes.tr, style: TextStyle(fontSize: 14, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


}

class CardNFT extends StatefulWidget {
  final CollectionDbDto collectionDbDTO;
  final ProfileController profileController;
  final int index;
  CardNFT(this.collectionDbDTO, this.profileController, this.index, {Key? key}) : super(key: key);

  @override
  State<CardNFT> createState() => _CardNFTState();
}

class _CardNFTState extends State<CardNFT> with AutomaticKeepAliveClientMixin{

    @override
    bool get wantKeepAlive => true;

    @override
  void initState() {
      //widget.profileController.getThumbnail(widget.collectionDbDTO.collectionImages[0]);
    super.initState();
  }

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
            leading: ClipRRect(borderRadius: BorderRadius.circular(90), child:
            CachedNetworkImage(imageUrl: widget.collectionDbDTO.collectionImage, width: 56, height: 56, fit: BoxFit.cover, placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
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
            },
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0, left: 80, right: 20),
                child: SizedBox(height: 80,
                    child: ListView.builder(
                  itemCount: widget.collectionDbDTO.collectionImages.length,
                  itemBuilder: (context, i){
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: (){
                          if(widget.profileController.isEditingProfile.value) widget.profileController.urlPicture.value = widget.collectionDbDTO.collectionImages[i];
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox.fromSize(
                                child: CachedNetworkImage(fit: BoxFit.cover, imageUrl: widget.collectionDbDTO.collectionImages[i], width: 80, height: 70,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                                    errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")))),
                      ),
                    );
                  }, scrollDirection: Axis.horizontal,)),
              )
            ],
          ),
        ),
      );
    }
}