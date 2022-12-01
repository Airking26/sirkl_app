import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/view/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/groups/controller/groups_controller.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import '../../common/view/dialog/custom_dial.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {

  YYDialog dialogMenu = YYDialog();
  final _groupController = Get.put(GroupsController());
  final _homeController = Get.put(HomeController());
  final _floatingSearchBarController = FloatingSearchBarController();
  StreamChannelListController? streamChannelListControllerGroups;

  StreamChannelListController buildStreamChannelListController(){
    return StreamChannelListController(
      client: StreamChat.of(context).client,
      filter:
      _groupController.searchIsActive.value && _groupController.query.value.isNotEmpty ?
      Filter.and([
        Filter.autoComplete('name', _groupController.query.value),
        if(_homeController.userMe.value.contractAddresses!.isNotEmpty) Filter.in_("contractAddress", _homeController.userMe.value.contractAddresses!.map((e) => e.toLowerCase()).toList())
        else Filter.equal("contractAddress", ""),
        Filter.greater("member_count", 2)
      ]) :
      Filter.and([
        if(_homeController.userMe.value.contractAddresses!.isNotEmpty) Filter.in_("contractAddress", _homeController.userMe.value.contractAddresses!.map((e) => e.toLowerCase()).toList())
        else Filter.equal("contractAddress", ""),
        Filter.greater("member_count", 2)
      ]),
      channelStateSort: const [SortOption('last_message_at')],
      limit: 20,
    );
  }

  @override
  void initState() {
    streamChannelListControllerGroups = buildStreamChannelListController();
    _homeController.getNFTsTemporary(_homeController.userMe.value.wallet!, context);
    super.initState();
  }

  @override
  void dispose() {
    streamChannelListControllerGroups?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() => Column(children: [
          buildAppBar(context),
          _groupController.addAGroup.value ? buildSelectNFT() : MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top:24.0),
                child: SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: StreamChannelListView(
                        emptyBuilder: (context){
                          return _groupController.searchIsActive.value && _groupController.query.value.isNotEmpty ? SingleChildScrollView(child: noGroupFoundUI()) : noGroupUI();
                        },
                        controller: _groupController.searchIsActive.value && _groupController.query.value.isNotEmpty ? buildStreamChannelListController() : streamChannelListControllerGroups!,
                        onChannelTap: (channel) async{
                          var isMember = await channel.queryMembers(filter: Filter.equal("id", _homeController.id.value));
                          if(isMember.members.isEmpty) await channel.addMembers([_homeController.id.value]);
                          Get.to(() => StreamChannel(channel: channel, child: const ChannelPage())
                        )!.then((value) {streamChannelListControllerGroups!.refresh();});
                      },
                      ),
                      ),
                ),
              ),
            ),
          )
        ])));
  }

  Stack buildAppBar(BuildContext context) {
    return Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.topCenter,
          fit: StackFit.loose,
          children: [
            Container(
              height: _groupController.addAGroup.value ? 115 : 140,
              margin: const EdgeInsets.only(bottom: 0.25),
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 0.01), //(x,y)
                    blurRadius: 0.01,
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(35)),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Get.isDarkMode ? const Color(0xFF113751) : Colors.white,
                      Get.isDarkMode ? const Color(0xFF1E2032) : Colors.white
                    ]),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 44.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            _groupController.addAGroup.value = false;
                            _groupController.query.value = "";
                            _groupController.searchIsActive.value = false;
                          },
                          icon: Image.asset(
                            "assets/images/arrow_left.png",
                            color:
                                _groupController.addAGroup.value ? Get.isDarkMode ? Colors.white : Colors.black : Colors.transparent,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          con.groupsTabRes.tr,
                          style: TextStyle(
                              color:  Get.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Gilroy",
                              fontSize: 20),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            dialogMenu = dialogPopMenu(context);
                          },
                          icon: Image.asset(
                            "assets/images/more.png",
                            color:
                            _groupController.addAGroup.value ? Colors.transparent : Get.isDarkMode ? Colors.transparent : Colors.transparent,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            _groupController.addAGroup.value ? Container() : Positioned(
                top: Platform.isAndroid ? 80 : 60,
                child: SizedBox(
                    height: 110,
                    width: MediaQuery.of(context).size.width,
                    child: buildFloatingSearchBar()))
          ],
        );
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
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.notificationsOffRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.contactOwnerRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.claimOwnershipeRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.reportRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }

  Column noGroupUI() {
    return Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Image.asset(
              "assets/images/people.png",
              width: 150,
              height: 150,
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 54.0),
              child: Text(
                con.noGroupYetRes.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 25,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 54.0),
              child: Text(
                con.errorGroupCollection.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF9BA0A5),
                    fontSize: 16,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
  }

  Column noGroupFoundUI() {
    return Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Image.asset(
              "assets/images/people.png",
              width: 150,
              height: 150,
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 54.0),
              child: Text(
                con.noGroupYetRes.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 25,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 54.0),
              child: Text(
                con.errorFindingCollection.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF9BA0A5),
                    fontSize: 16,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            NiceButtons(
                stretch: false,
                width: 350,
                borderThickness: 5,
                progress: false,
                borderColor: const Color(0xff0063FB).withOpacity(0.5),
                startColor: const Color(0xff1DE99B),
                endColor: const Color(0xff0063FB),
                gradientOrientation: GradientOrientation.Horizontal,
                onTap: (finish) {
                  _groupController.addAGroup.value = true;
                },
                child: Text(
                  con.addGroupRes.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w700),
                )),
          ],
        );
  }

  Widget buildSelectNFT(){
    _groupController.retrieveGroups(_homeController.nfts.value);
    return _groupController.isLoadingAvailableNFT.value ?
         const Padding(
           padding: EdgeInsets.only(top: 54.0),
           child: CircularProgressIndicator(),
         ) :
     MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: SafeArea(
            child: ListView.builder(
              cacheExtent: 1000,
              itemCount: _groupController.nftsAvailable.value.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(8),
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
                    child: ListTile(
                      onTap: ()async{
                        await _groupController.createGroup(StreamChat.of(context).client, _groupController.nftsAvailable.value[index].collectionName, _groupController.nftsAvailable.value[index].collectionImages[0], _groupController.nftsAvailable.value[index].contractAddress);
                        Get.to(() => const DetailedChatScreen(create:false));
                      },
                      leading: ClipRRect(borderRadius: BorderRadius.circular(90), child: CachedNetworkImage(imageUrl: _groupController.nftsAvailable[index].collectionImages[0], width: 50, height: 50, fit: BoxFit.cover, placeholder: (context, url) => const CircularProgressIndicator(), errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png", fit: BoxFit.cover,)),),

                      title: Text(_groupController.nftsAvailable.value[index].collectionName, style: TextStyle(fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black)),
                      //subtitle: Transform.translate(offset: const Offset(-8, 0), child: Text("${_homeController.nfts.value[index].collectionImages.length} available", style: TextStyle(fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF828282)))),
                    ),
                  ),
                );;
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      clearQueryOnClose: false,
      controller: _floatingSearchBarController,
      closeOnBackdropTap: false,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      hint: 'Search here...',
      backdropColor: Colors.transparent,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 0),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      queryStyle: TextStyle(
          color: Get.isDarkMode ? Colors.white : Colors.black,
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      hintStyle: TextStyle(
          color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282),
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      elevation: 5,
      showCursor: true,
      width: 350,
      accentColor: Get.isDarkMode ? Colors.white : Colors.black,
      borderRadius: BorderRadius.circular(10),
      backgroundColor:
          Get.isDarkMode ? const Color(0xFF2D465E).withOpacity(1) : Colors.white,
      debounceDelay: const Duration(milliseconds: 200),
      onQueryChanged: (query) {
        if(query.isNotEmpty){
          _groupController.query.value = query;
          _groupController.searchIsActive.value = true;
        }
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      leadingActions: [
        FloatingSearchBarAction.icon(
          icon: Image.asset(
            _groupController.searchIsActive.value ? "assets/images/close.png" : "assets/images/search.png",
            width: 24, height: 24, color: Colors.grey,),
          showIfClosed: true,
          showIfOpened: true,
          onTap: () {
            if(_groupController.searchIsActive.value){
              _floatingSearchBarController.clear();
              _floatingSearchBarController.close();
              _groupController.query.value = "";
              _groupController.searchIsActive.value = false;
            }
          },
        ),
      ],
      actions: const [],
      builder: (context, transition) {
        return const SizedBox(
          height: 0,
        );
      },
    );
  }
}
