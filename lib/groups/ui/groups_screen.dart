import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/view/stream_chat/src/channel/channel_page.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/groups/controller/groups_controller.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
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
  StreamChannelListController? streamChannelListControllerGroups;

  StreamChannelListController buildStreamChannelListController(){
    return StreamChannelListController(
      client: StreamChat.of(context).client,
      filter:
      _groupController.searchIsActive.value && _groupController.query.value.isNotEmpty ?
      Filter.and([
        Filter.autoComplete('member.user.name', _groupController.query.value),
        Filter.in_("members", [_homeController.id.value]),
        Filter.in_("contractAddress", _homeController.userMe.value.contractAddresses!.map((e) => e.toLowerCase()).toList()),
        Filter.greater("member_count", 2)
      ]) :
      Filter.and([
        Filter.equal('type', "try"),
        Filter.in_("members", [_homeController.id.value]),
        if(_homeController.userMe.value.contractAddresses!.isNotEmpty) Filter.in_("contractAddress", _homeController.userMe.value.contractAddresses!.map((e) => e.toLowerCase()).toList()),
        Filter.greater("member_count", 2)
      ]),
      channelStateSort: const [SortOption('last_message_at')],
      limit: 20,
    );
  }

  @override
  void initState() {
   //_groupController.retrieveGroups(StreamChat.of(context).client);
    streamChannelListControllerGroups = buildStreamChannelListController();
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
        body: Column(children: [
          buildAppBar(context),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top:24.0),
                child: SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Obx(() =>StreamChannelListView(
                        emptyBuilder: (context){
                          return noGroupUI();
                        },
                        controller: _groupController.searchIsActive.value && _groupController.query.value.isNotEmpty ? buildStreamChannelListController() : streamChannelListControllerGroups!, onChannelTap: (channel){
                        Get.to(() => StreamChannel(channel: channel, child: const ChannelPage()))!.then((value) {
                          streamChannelListControllerGroups!.refresh();
                        });
                      },
                      ),
                      )),
                ),
              ),
            ),
          )
        ]));
  }

  Stack buildAppBar(BuildContext context) {
    return Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.topCenter,
          fit: StackFit.loose,
          children: [
            Container(
              height: 140,
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

                          },
                          icon: Image.asset(
                            "assets/images/arrow_left.png",
                            color:
                                Get.isDarkMode ? Colors.transparent : Colors.transparent,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          con.groupsTabRes.tr,
                          style: TextStyle(
                              color: Get.isDarkMode
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
                                Get.isDarkMode ? Colors.white : Colors.black,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                top: Platform.isAndroid ? 80 : 60,
                child: Container(
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
      ..backgroundColor = Get.isDarkMode ? Color(0xFF1E3244).withOpacity(0.95) : Colors.white
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

  /*Widget groupTile(BuildContext context, int index){
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ListTile(
        onTap: (){Get.to(() => const DetailedChatScreen());},
        leading: CachedNetworkImage(imageUrl: "https://ik.imagekit.io/bayc/assets/bayc-footer.png", height: 60, width: 60, fit: BoxFit.cover,),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("2 Days", style: TextStyle(fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Color(0xFF9BA0A5) : Color(0xFF828282))),
            Container(height: 24, width: 24, decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Color(0xFF00CB7D)), child: Padding(padding: EdgeInsets.all(0), child: Align(alignment: Alignment.center, child: Text(textAlign: TextAlign.center,"2", style: TextStyle(color: Get.isDarkMode ? Color(0xFF232323) : Colors.white, fontFamily: 'Gilroy', fontSize: 12, fontWeight: FontWeight.w600),)),),)
          ],
        ),
        title: Transform.translate(offset: Offset(-8, 0), child: Text("Bored Ape Yacht Club", style: TextStyle(fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black))),
        subtitle: Transform.translate(offset: Offset(-8, 0),child: Text("Lorem Ipsum is simply...", style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Get.isDarkMode ? Color(0xFF9BA0A5) : Color(0xFF828282)))),

      ),
    );
  }*/

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
                progress: true,
                borderColor: const Color(0xff0063FB).withOpacity(0.5),
                startColor: const Color(0xff1DE99B),
                endColor: const Color(0xff0063FB),
                gradientOrientation: GradientOrientation.Horizontal,
                onTap: (finish) {},
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

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      clearQueryOnClose: false,
      closeOnBackdropTap: false,
      padding: EdgeInsets.symmetric(horizontal: 8),
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
          color: Get.isDarkMode ? Color(0xff9BA0A5) : Color(0xFF828282),
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      elevation: 5,
      showCursor: true,
      width: 350,
      accentColor: Get.isDarkMode ? Colors.white : Colors.black,
      borderRadius: BorderRadius.circular(10),
      backgroundColor:
          Get.isDarkMode ? Color(0xFF2D465E).withOpacity(1) : Colors.white,
      debounceDelay: const Duration(milliseconds: 200),
      onQueryChanged: (query) {
        if(query.isNotEmpty){
          _groupController.query.value = query;
          _groupController.searchIsActive.value = true;
        }
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction.icon(
          icon: Image.asset(
            "assets/images/search.png",
            width: 24,
            height: 24,
          ),
          showIfClosed: true,
          showIfOpened: true,
          onTap: () {},
        ),
      ],
      actions: [],
      builder: (context, transition) {
        return SizedBox(
          height: 0,
        );
      },
    );
  }
}
