import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/common/constants.dart' as con;

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Column(children: [
          Stack(
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
                        IconButton(
                            onPressed: () {
                            },
                            icon: Image.asset(
                              "assets/images/arrow_left.png",
                              color:
                              Get.isDarkMode ? Colors.white : Colors.black,
                            )),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            con.newMessageRes.tr,
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
                              Get.isDarkMode ? Colors.transparent : Colors.transparent,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: 80,
                  child: Container(
                      height: 90,
                      width: MediaQuery.of(context).size.width,
                      child:buildFloatingSearchBar()))
            ],
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 45.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("To", textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, fontFamily: "Gilroy", color: Get.isDarkMode ? Colors.white : Colors.black),),
                    const SizedBox(height: 15,),
                  ],
                )),
          )
        ]));
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
