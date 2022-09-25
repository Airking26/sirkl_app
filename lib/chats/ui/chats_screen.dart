import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/new_message_screen.dart';
import 'package:sirkl/common/constants.dart' as con;


class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with TickerProviderStateMixin {
  final chatController = Get.put(ChatsController());

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging)
        chatController.index.value = _tabController.index;
    });

    return Scaffold(
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Column(children: [
          buildAppbar(context, _tabController),
          buildListConv(context, _tabController)
        ]));
  }

  Stack buildAppbar(BuildContext context, TabController _tabController) {
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
                      Get.isDarkMode ? const Color(0xFF111D28) : Colors.white,
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
                      Obx(()=>IconButton(
                          onPressed: () {
                            chatController.searchIsActive.value = !chatController.searchIsActive.value;
                          },
                          icon: Image.asset(
                            chatController.searchIsActive.value ? "assets/images/close_big.png" : "assets/images/search.png",
                            color:
                                Get.isDarkMode ? Colors.white : Colors.black,
                          ))),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          con.chatsTabRes.tr,
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
                            Get.to(() => const NewMessageScreen());
                          },
                          icon: Image.asset(
                            "assets/images/plus.png",
                            color:
                                Get.isDarkMode ? Colors.white : Colors.black,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Obx(()=>Positioned(
                top: chatController.searchIsActive.value ? Platform.isAndroid ? 80 : 60 : 110,
                child: chatController.searchIsActive.value ? Container(
                    height: 110,
                    width: MediaQuery.of(context).size.width,
                    child:buildFloatingSearchBar()): Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.01), //(x,y)
                            blurRadius: 0.01,
                          ),
                        ],
                        color: Get.isDarkMode
                            ? const Color(0xFF2D465E).withOpacity(1)
                            : Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, bottom: 2, left: 4, right: 4),
                      child: Obx(
                        () => TabBar(
                          labelPadding: EdgeInsets.zero,
                          indicatorPadding: EdgeInsets.zero,
                          indicatorColor: Colors.transparent,
                          controller: _tabController,
                          padding: EdgeInsets.zero,
                          tabs: [
                            Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: chatController.index.value == 0
                                    ? const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                            Color(0xFF1DE99B),
                                            Color(0xFF0063FB)
                                          ])
                                    : Get.isDarkMode
                                        ? const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                                Color(0xFF2D465E),
                                                Color(0xFF2D465E)
                                              ])
                                        : const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                                Colors.white,
                                                Colors.white
                                              ]),
                              ),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Friends",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "Gilroy",
                                        fontWeight: FontWeight.w700,
                                        color: chatController.index.value == 0
                                            ? Colors.white
                                            : Get.isDarkMode
                                                ? Color(0xFF9BA0A5)
                                                : Color(0xFF828282)),
                                  )),
                            ),
                            Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: chatController.index.value == 1
                                    ? const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                            Color(0xFF1DE99B),
                                            Color(0xFF0063FB)
                                          ])
                                    : Get.isDarkMode
                                        ? const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                                Color(0xFF2D465E),
                                                Color(0xFF2D465E)
                                              ])
                                        : const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                                Colors.white,
                                                Colors.white
                                              ]),
                              ),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Others",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "Gilroy",
                                        fontWeight: FontWeight.w700,
                                        color: chatController.index.value == 1
                                            ? Colors.white
                                            : Get.isDarkMode
                                                ? Color(0xFF9BA0A5)
                                                : Color(0xFF828282)),
                                  )),
                            )
                          ],
                        ),
                      ),
                    ))))
          ],
        );
  }

  MediaQuery buildListConv(BuildContext context, TabController _tabController) {
    return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Expanded(
            child: SafeArea(
              minimum: EdgeInsets.only(top: 24),
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: 50,
                    itemBuilder: inboxTile,
                    separatorBuilder: (context, index) {
                      return const Divider(
                        color: Color(0xFF828282),
                        thickness: 0.2,
                        endIndent: 20,
                        indent: 86,
                      );
                    },
                  ),
                  ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: 50,
                    itemBuilder: inboxTile,
                    separatorBuilder: (context, index) {
                      return const Divider(
                        color: Color(0xFF828282),
                        thickness: 0.2,
                        endIndent: 20,
                        indent: 86,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
  }

  Widget inboxTile(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ListTile(
          leading: Image.network(
              "https://ik.imagekit.io/bayc/assets/bayc-footer.png", height: 60, width: 60, fit: BoxFit.cover,),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("2 Days", style: TextStyle(fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Color(0xFF9BA0A5) : Color(0xFF828282))),
            Container(height: 24, width: 24, decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Color(0xFF00CB7D)), child: Padding(padding: EdgeInsets.all(0), child: Align(alignment: Alignment.center, child: Text(textAlign: TextAlign.center,"2", style: TextStyle(color: Get.isDarkMode ? Color(0xFF232323) : Colors.white, fontFamily: 'Gilroy', fontSize: 12, fontWeight: FontWeight.w600),)),),)
          ],
        ),
        title: Transform.translate(
          offset: Offset(-8, 0),
          child: Text("Bored Ape Yacht Club",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600,
                    color: Get.isDarkMode ? Colors.white : Colors.black)),
        ),
        subtitle: Transform.translate(offset: Offset(-8, 0), child: Text("Lorem Ipsum is simply...", style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Get.isDarkMode ? Color(0xFF9BA0A5) : Color(0xFF828282)))),
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
          color: Get.isDarkMode
              ? const Color(0xff9BA0A5)
              : const Color(0xFF828282),
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      elevation: 5,
      showCursor: true,
      width: 350,
      accentColor: Get.isDarkMode ? Colors.white : Colors.black,
      borderRadius: BorderRadius.circular(10),
      backgroundColor: Get.isDarkMode
          ? const Color(0xFF2D465E).withOpacity(1)
          : Colors.white,
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
