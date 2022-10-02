import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/model/update_me_dto.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';
import 'package:sirkl/profile/ui/notifications_screen.dart';

import '../../common/view/dialog/custom_dial.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final _profileController = Get.put(ProfileController());
  final _homeController = Get.put(HomeController());
  YYDialog dialogMenu = YYDialog();

  @override
  void initState(){
    _profileController.usernameTextEditingController.value.text = _homeController.userMe.value.userName!.isEmpty ? _homeController.userMe.value.wallet!.substring(0, 20) : _homeController.userMe.value.userName!;
    _profileController.descriptionTextEditingController.value.text = _homeController.userMe.value.description == null ? "" : _homeController.userMe.value.description!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() => Column(
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
                          IconButton(onPressed: (){
                            _profileController.isEditingProfile.value ? _profileController.updateMe(UpdateMeDto(
                              userName: _profileController.usernameTextEditingController.value.text.isEmpty ? _homeController.userMe.value.wallet!.substring(0, 20) : _profileController.usernameTextEditingController.value.text,
                              description: _profileController.descriptionTextEditingController.value.text.isEmpty ? null : _profileController.descriptionTextEditingController.value.text
                            )):
                            Get.to(() => const NotificationScreen());
                            }, icon: Image.asset(_profileController.isEditingProfile.value ? "assets/images/done.png" : "assets/images/bell.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child:
                                _profileController.isEditingProfile.value ?
                               SizedBox(
                                 width: 200,
                                 child: TextField(
                                   autofocus: true,
                                   maxLines: 1,
                                   controller: _profileController.usernameTextEditingController.value,
                                   maxLength: 20,
                                   textAlign: TextAlign.center,
                                   style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black),
                                   decoration: const InputDecoration(
                                     border: InputBorder.none,
                                     isCollapsed: true,
                                     //prefixIcon: IconButton(onPressed: (){}, icon: Image.asset('assets/images/edit.png', width: 18, height: 18)),
                                     hintText: ""
                                       //hintText: _homeController.userMe.value.userName!.isEmpty ? _homeController.userMe.value.wallet! : _homeController.userMe.value.userName!,
                                      // hintStyle: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black)
                                     ),
                                 ),
                               )
                             : Text(_homeController.userMe.value.userName!.isEmpty ? "${_homeController.userMe.value.wallet!.substring(0, 20)}..." : _homeController.userMe.value.userName!, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black),),
                          ),
                          IconButton(onPressed: (){
                            dialogMenu = dialogPopMenu(context);
                            }, icon: Image.asset("assets/images/more.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                        ],),
                    ),
                  ),
                ),
                Positioned(
                  top: Platform.isAndroid ? 105 : 95,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Get.isDarkMode ? const Color(0xFF122034) : Colors.white, width: 5),
                        borderRadius: BorderRadius.circular(90)),
                    child:
                        ClipOval(child: SizedBox.fromSize(size: const Size.fromRadius(70),
                          child: GestureDetector(onTap: (){ _profileController.getImage();},child: Image.network("https://img.seadn.io/files/9a3bb789c07f93d50d9c50dc0dae7cf1.png?auto=format&fit=max&w=640", color: Colors.white.withOpacity(_profileController.isEditingProfile.value ? 0.2 : 0.0), colorBlendMode: BlendMode.difference,))
                          ,),)
                  ),
                ),
                _profileController.isEditingProfile.value ? Container() : Positioned(
                  top: Platform.isAndroid ? 210 : 190,
                    right: MediaQuery.of(context).size.width / 3.25,
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
                autofocus: true,
                controller: _profileController.descriptionTextEditingController.value,
                maxLength: 120,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Get.isDarkMode ? Color(0xFF9BA0A5) : Color(0xFF828282)),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: ""
                ),
              ):
              Text(_homeController.userMe.value.description == null ? con.noDescYetRes.tr : _homeController.userMe.value.description!,  textAlign: TextAlign.center, style: const TextStyle(height: 1.5, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF828282), fontSize: 15),),
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
            MediaQuery.removePadding(
              context:  context,
              removeTop: true,
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SafeArea(
                    child: ListView.builder(
                        itemCount: 10,
                        itemBuilder: nftDisplayWidget
                    ),
                  ),
                ),
              ),
            )
          ],
        )));
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
          leading: Image.network("https://ik.imagekit.io/bayc/assets/bayc-footer.png", width: 60, height: 60, fit: BoxFit.cover,),
          trailing: Obx(() => Image.asset(_profileController.isCardExpanded.value ? "assets/images/arrow_up_rev.png" : "assets/images/arrow_down_rev.png", color: Get.isDarkMode ? Colors.white : Colors.black, height: 20, width: 20,),),
          title: Transform.translate(offset: const Offset(-8, 0),child: Text("Bored Ape Yacht Club", style: TextStyle(fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black))),
          subtitle: Transform.translate(offset: const Offset(-8, 0), child: const Text("1 available", style: TextStyle(fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Color(0xFF828282)))),
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

  YYDialog dialogPopMenu(BuildContext context) {
    return YYDialog().build(context)
      ..width = 120
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor = Colors.transparent
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: (){
          _profileController.isEditingProfile.value = true;
          dialogMenu.dismiss();
        },
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.editProfileRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.contactUsRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: (){},
        child: Padding(padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text(con.logoutRes.tr, style: TextStyle(fontSize: 14, color: Get.isDarkMode ? const Color(0xff9BA0A5) : const Color(0xFF828282), fontFamily: "Gilroy", fontWeight: FontWeight.w600),)),),
      ))
      ..show();
  }

}

