import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:sirkl/common/constants.dart' as con;

import '../../common/utils.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode ? const Color(0xFF102437) : const Color
            .fromARGB(255, 247, 253, 255),
        body: Column(
            children: [
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
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(35)),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Get.isDarkMode ? const Color(0xFF111D28) : Colors
                                .white,
                            Get.isDarkMode ? const Color(0xFF1E2032) : Colors
                                .white
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
                            IconButton(onPressed: () {},
                                icon: Image.asset(
                                  "assets/images/arrow_left.png",
                                  color: Get.isDarkMode ? Colors.white : Colors
                                      .black,)),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text("Groups", style: TextStyle(
                                  color: Get.isDarkMode ? Colors.white : Colors
                                      .black,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Gilroy",
                                  fontSize: 20),),
                            ),
                            IconButton(onPressed: () {
                              Utils().dialogPopMenu(context);
                            },
                                icon: Image.asset("assets/images/more.png",
                                  color: Get.isDarkMode ? Colors.white : Colors
                                      .black,)),
                          ],),
                      ),
                    ),
                  ),
                  Positioned(
                      top: 80,
                      child: Container(height: 90, width: MediaQuery.of(context).size.width, child: buildFloatingSearchBar()))
                ],
              ),
        const SizedBox(height: 100,),
        Image.asset("assets/images/people.png", width: 150, height: 150,),
        const SizedBox(height: 30,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Text(con.noGroupYetRes.tr, textAlign: TextAlign.center, style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black, fontSize: 25, fontFamily: "Gilroy", fontWeight: FontWeight.w700),),
        ),
        const SizedBox(height: 15,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Text(con.errorFindingCollection.tr, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9BA0A5), fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w500),),
        ),
        const SizedBox(height: 50,),
        NiceButtons(
            stretch: false,
            width: 350,
            borderThickness: 5,
            progress: true,
            borderColor: const Color(0xff0063FB).withOpacity(0.5),
            startColor: const Color(0xff1DE99B),
            endColor: const Color(0xff0063FB),
            gradientOrientation: GradientOrientation.Horizontal,
            onTap: (finish){
            },
            child: Text(con.addGroupRes.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: "Gilroy", fontWeight: FontWeight.w700),)
        ),
            ])
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
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0 ,
      openAxisAlignment: 0.0,
      queryStyle: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black, fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: Get.isDarkMode ? Color(0xff9BA0A5) : Color(0xFF828282), fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w500),
      elevation: 5,
      showCursor: true,
      width:350,
      accentColor: Get.isDarkMode ? Colors.white : Colors.black,
      borderRadius: BorderRadius.circular(10),
      backgroundColor: Get.isDarkMode ? Color(0xFF2D465E).withOpacity(1) : Colors.white,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      leadingActions: [
        FloatingSearchBarAction.icon(
          icon: Image.asset("assets/images/search.png", width: 24, height: 24,),
          showIfClosed: true,
          showIfOpened: true,
          onTap: () {
          },
        ),
      ],
      actions: [

      ],
      builder: (context, transition) {
        return SizedBox(
          height: 0,
        );
      },
    );
  }

}