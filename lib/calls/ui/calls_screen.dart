import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/home/controller/home_controller.dart';
import 'dart:io';

import '../../common/utils.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({Key? key}) : super(key: key);

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {

  final _callController = Get.put(CallsController());
  final _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Column(children: [
          buildAppbar(context),
          buildListCall(context)
        ]));
  }

  Stack buildAppbar(BuildContext context) {
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
                  //Get.isDarkMode ? const Color(0xFF111D28) : Colors.white,
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
                      onPressed: () {},
                      icon: Image.asset(
                        "assets/images/arrow_left.png",
                        color:
                        Get.isDarkMode ? Colors.transparent : Colors.transparent,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      con.callsTabRes.tr,
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
                        Utils().dialogPopMenu(context);
                      },
                      icon: Image.asset(
                        "assets/images/more.png",
                        color:
                        Get.isDarkMode ? Colors.transparent : Colors.transparent,
                      )),
                ],
              ),
            ),
          ),
        ),
        Positioned(
            top: Platform.isAndroid? 80 : 60,
            child: SizedBox(
                height: 110,
                width: MediaQuery.of(context).size.width,
                child: buildFloatingSearchBar()))
      ],
    );
  }

  MediaQuery buildListCall(BuildContext context) {
    return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SafeArea(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: 50,
                  itemBuilder: callTile,
                  separatorBuilder: (context, index){return const Divider(color: Color(0xFF828282), thickness: 0.2, endIndent: 20, indent: 86,);},
                ),
              ),
            ),
          ),
        );
  }

  Widget callTile(BuildContext context, int index){
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ListTile(
        leading: CachedNetworkImage(imageUrl: "https://ik.imagekit.io/bayc/assets/bayc-footer.png", width: 60, height: 60, fit: BoxFit.cover,placeholder: (context, url) => Center(child: const CircularProgressIndicator()),
            errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text("2 Days", style: TextStyle(fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282))),
            ),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                InkWell(onTap:()async{
                  await _callController.inviteCall(_homeController.agoraClient.value!, "638db80a0753b1001e10b21d", "knflknzzdzdzjjfr");
                  } ,child: Image.asset("assets/images/call_tab.png", color: const Color(0xFF00CB7D), width: 20, height: 20,)),
                const SizedBox(width: 8,),
                InkWell(
                  onTap: () async{
                    //await _callController.inviteCall('dd', "exampleShan");
                  },
                    child: Image.asset("assets/images/chat_tab.png", width: 20, height: 20, color: const Color(0xFF9BA0A5),)),
                  const SizedBox(width: 4,),
                  Image.asset("assets/images/more.png", width: 20, height: 20,color: const Color(0xFF9BA0A5))
              ],),
            )
          ],
        ),
        title: Transform.translate(offset: const Offset(-8, 0),child: Text("Bored Ape Yacht", style: TextStyle(fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black))),
        subtitle:
            Transform.translate(
              offset: const Offset(-8, 0),
              child: Row(children: [
                Image.asset("assets/images/outgoing.png", width: 10, height: 10,),
                Text( "  Outgoing  - 12:15PM", style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282)))
              ],),
            )
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      clearQueryOnClose: false,
      closeOnBackdropTap: false,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      hint: 'Search here...',
      backdropColor: Colors.transparent,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
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
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
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
      actions: const [],
      builder: (context, transition) {
        return const SizedBox(
          height: 0,
        );
      },
    );
  }
}
