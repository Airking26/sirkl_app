import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/view/dialog/custom_dial.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final _profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
        body: Column(
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
                          IconButton(onPressed: (){}, icon: Image.asset("assets/images/bell.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text("Anthony Park", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black),),
                          ),
                          IconButton(onPressed: (){dialogPopMenu();}, icon: Image.asset("assets/images/more.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                          /*PopupMenuButton(
                            elevation: 5,
                            position: PopupMenuPosition.under,
                            color: Colors.white.withOpacity(0.5),
                            icon: ImageIcon(AssetImage("assets/images/more.png"), size: 40,),
                              itemBuilder: (context) => [
                                PopupMenuItem(child: Text("Gef"), value: Text("G"),)
                          ])*/
                        ],),
                    ),
                  ),
                ),
                Positioned(
                  top: 105,
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Get.isDarkMode ? const Color(0xFF122034) : Colors.white, width: 5), borderRadius: BorderRadius.circular(90)),
                    child: const CircleAvatar(
                      radius: 70,
                      backgroundImage:
                      NetworkImage("https://img.seadn.io/files/9a3bb789c07f93d50d9c50dc0dae7cf1.png?auto=format&fit=max&w=640"),
                    ),
                  ),
                ),
                Positioned(
                  top: 210,
                    right: 130,
                    child:
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1DE99B), Color(0xFF0063FB)]),
                          borderRadius: BorderRadius.circular(90),
                          border: Border.all(color: Get.isDarkMode ? const Color(0xFF122034) : Colors.white, width: 2)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset('assets/images/plus.png', width: 20, height: 20,),
                      ),
                    )
                )
              ],
            ),
            const SizedBox(height: 90,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: Text("Wallet: gf4ff4245556fed...",overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center, style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF00CB7D), fontSize: 15),),
            ),
            const SizedBox(height: 10,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: Text("I love NFTs and Crypto the printing and typesetting industry. Ipsumhas been the industry's standard",  textAlign: TextAlign.center, style: TextStyle(height: 1.5, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF828282), fontSize: 15),),
            ),
            const SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Divider(color: Color(0xFF828282),),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Align(alignment: Alignment.topLeft, child: Text(con.myNFTCollectionRes.tr, textAlign: TextAlign.start, style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black),)),
            ),
            Flexible(
              child: ListView.builder(
                //shrinkWrap: true,
                padding: const EdgeInsets.only(top: 10, bottom: 100),
                  itemCount: 10,
                  itemBuilder: nftDisplayWidget
              ),
            )
          ],
        ));
  }

  Widget nftDisplayWidget(BuildContext context, int index){
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
          leading: Image.network("https://ik.imagekit.io/bayc/assets/bayc-footer.png"),
          trailing: Obx(() => Image.asset(_profileController.isCardExpanded.value ? "assets/images/arrow_up_rev.png" : "assets/images/arrow_down_rev.png", color: Get.isDarkMode ? Colors.white : Colors.black, height: 20, width: 20,),),
          title: Text("Bored Ape Yacht Club", style: TextStyle(fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black)),
          subtitle: const Text("1 available", style: TextStyle(fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF828282))),
          onExpansionChanged: (expanded){
            _profileController.isCardExpanded.value = expanded;
          },
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0, left: 80, right: 20),
              child: SizedBox(height: 80, child: ListView.builder(itemCount: 8, itemBuilder: nftImageWidget, scrollDirection: Axis.horizontal,)),
            )
          ],
        ),
      ),
    );
  }

  Widget nftImageWidget(BuildContext context, int index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
          child: SizedBox.fromSize(
              child: Image.network(fit: BoxFit.cover,"https://img.seadn.io/files/9a3bb789c07f93d50d9c50dc0dae7cf1.png?auto=format&fit=max&w=640", width: 80, height: 70,))),
      );
  }

  YYDialog dialogPopMenu() {
    return YYDialog().build(context)
      ..width = 120
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor = Colors.transparent
      ..margin = EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
        child: Align(alignment: Alignment.centerLeft, child: Text("• Edit profile", style: TextStyle(fontSize: 14, color: Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text("• Contact us", style: TextStyle(fontSize: 14, color: Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text("• Logout", style: TextStyle(fontSize: 14, color: Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }
}

