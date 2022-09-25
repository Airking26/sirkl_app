import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

import '../../utils.dart';

class DetailedMessageScreenOther extends StatefulWidget {
  const DetailedMessageScreenOther({Key? key}) : super(key: key);

  @override
  State<DetailedMessageScreenOther> createState() => _DetailedMessageScreenOtherState();
}

class _DetailedMessageScreenOtherState extends State<DetailedMessageScreenOther> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
        body: Column(
          children: [
            buildAppbar(context),
            buildListChat(context),
            buildBottomBar()
          ],
        ));
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
              gradient:  LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Get.isDarkMode ? const Color(0xFF111D28) : Colors.white,
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
                    SizedBox(width: 250, height: 50, child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(onPressed: (){Get.back();}, icon: Image.asset("assets/images/arrow_left.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Image.network("https://ik.imagekit.io/bayc/assets/bayc-footer.png", width: 40, height: 40, fit: BoxFit.cover,),
                        ),
                        Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Text("Cryptopunks",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: "Gilroy", color: Get.isDarkMode ? Colors.white : Colors.black),),
                          Text("3245 participants",style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: "Gilroy", color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282)),)
                        ],),
                      )
                    ],),),
                    IconButton(onPressed: (){Utils().dialogPopMenu(context);}, icon: Image.asset("assets/images/more.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                  ],),
              ),
            ),
          );
  }

  MediaQuery buildListChat(BuildContext context) {
    return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: Expanded(
              child: SafeArea(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: 50,
                  itemBuilder: buildChatTile,
                ),
              ),
            ),
          );
  }

  Container buildBottomBar() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(color: Colors.grey, width: 0.01)),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Get.isDarkMode ? const Color(0xFF111D28) : Colors.white,
              Get.isDarkMode ? const Color(0xFF1E2032) : Colors.white
            ]),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                  ),
                  onPressed: () {},
                ),
                hintText: con.writeHereRes.tr,
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: "Gilroy",
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282)),
                filled: true,
                fillColor:
                Get.isDarkMode ? const Color(0xFF2D465E) : const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Flexible(
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF1DE99B), Color(0xFF0063FB)])),
              child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/images/send.png",
                    height: 32,
                    width: 32,
                  )),
            ),
          )
        ],
      ),
    );
  }

  Widget buildChatTile(BuildContext context, int index){
    return Align(
      alignment: index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
        child:  index % 2 == 0 ?
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Image.network("https://ik.imagekit.io/bayc/assets/bayc-footer.png", width: 40, height: 40, fit: BoxFit.cover,),
              ),
              const SizedBox(width: 8,),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 80.0),
                  child: Container(decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF102437), Color(0xFF13171B)]),

                  ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                      child: Column(
                        children: [
                        const Text("Could you make sure to involve the Head of R&D here? Could you make sure to involve the Head of R&D here?", style: TextStyle(color: Colors.white, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 15),),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Align(alignment: Alignment.bottomRight, child: Text("12:23", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600, fontFamily: "Gilroy"),),),
                        )
                      ],),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ):
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 80.0, right: 16),
              child: Container(decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 0.01), //(x,y)
                    blurRadius: 1,
                  ),
                ],
              ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                  child: Column(
                    children: [
                      const Text("Could you make sure to involve the Head of R&D here? Could you make sure to involve the Head of R&D here?", style: TextStyle(color: Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 15),),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Align(alignment: Alignment.bottomRight, child: Text("12:23", style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600, fontFamily: "Gilroy"),),),
                      )
                    ],),
                ),
              ),
            ),
          ),
        )
    ) ;
  }



}
