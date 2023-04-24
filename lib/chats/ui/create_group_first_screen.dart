import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/chats/ui/create_group_second_screen.dart';
import 'package:sirkl/common/utils.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/profile/controller/profile_controller.dart';

import '../../navigation/controller/navigation_controller.dart';

class CreateGroupFirstScreen extends StatefulWidget {
  const CreateGroupFirstScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupFirstScreen> createState() => _CreateGroupFirstScreenState();
}

class _CreateGroupFirstScreenState extends State<CreateGroupFirstScreen> {

  final _profileController = Get.put(ProfileController());
  final _chatController = Get.put(ChatsController());
  final _navigationController = Get.put(NavigationController());
  final _utils = Utils();

  @override
  void initState() {
    var kr = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? const Color(0xFF102437)
          : const Color.fromARGB(255, 247, 253, 255),
      body: Obx(() =>Column(children: [
        buildAppbar(context),
        const SizedBox(height: 24,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Container(
                decoration: BoxDecoration(
                    border: Border.all(color: MediaQuery.of(context).platformBrightness == Brightness.dark? const Color(0xFF122034) : Colors.white, width: 5),
                    borderRadius: BorderRadius.circular(90)),
                child:
                ClipOval(child: SizedBox.fromSize(size: const Size.fromRadius(30),
                  child: GestureDetector(onTap: () async {
                    await _profileController.getImageForGroup();
                  },
                      child:
                      Obx(() => CachedNetworkImage(imageUrl: _profileController.urlPictureGroup.value, color: Colors.white.withOpacity(0.0),fit: BoxFit.cover, colorBlendMode: BlendMode.difference,placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                          errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png"))))
                  ,),)
            ),
            const SizedBox(width: 8,),
            Expanded(
              child: TextField(
                controller: _chatController.groupTextController.value,
                onChanged: (query){
                  if(query.isEmpty) {
                    _chatController.groupNameIsEmpty.value = true;
                  } else {
                    _chatController.groupNameIsEmpty.value = false;
                  }
                },
                style: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w500),
                cursorColor: const Color(0xff00CB7D),
                maxLines: 1,
                maxLength: 10,
                decoration: const InputDecoration(hintText: "Name of the group", hintStyle: TextStyle(fontFamily: "Gilroy"),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff00CB7D)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff00CB7D)),
                  ), ),
              ),
            )
          ],),
        ),
        const SizedBox(height: 24,),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF113751) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: (){
                    _chatController.groupTypeCollapsed.value = !_chatController.groupTypeCollapsed.value;
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Group type", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),),
                    Text(_chatController.groupType.value == 0 ? "Public" : "Private", style: const TextStyle(color: Colors.grey, fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 16),)
                  ],),
                ),
                _chatController.groupTypeCollapsed.value ? const SizedBox(width : 0, height: 0) : const SizedBox(height: 16,),
                _chatController.groupTypeCollapsed.value ? const SizedBox(width : 0, height: 0) : Transform.translate(
                  offset: const Offset(-16, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(value: _chatController.groupType.value == 0, onChanged: (checked){
                        if(checked!) _chatController.groupType.value = 0;
                      },
                        checkColor: const Color(0xFF00CB7D),
                        fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
                        side: MaterialStateBorderSide.resolveWith(
                              (states) => const BorderSide(width: 0.0, color: Colors.transparent),
                        ),),
                      InkWell(onTap: (){
                        _chatController.groupType.value = 0;
                      },child: Text("Public", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),))
                  ],),
                ),
                _chatController.groupTypeCollapsed.value ? const SizedBox(width : 0, height: 0) : Transform.translate(
                  offset: const Offset(-16, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(value: _chatController.groupType.value == 1, onChanged: (checked){
                        if(checked!) _chatController.groupType.value = 1;
                      },
                        checkColor: const Color(0xFF00CB7D),
                        fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
                        side: MaterialStateBorderSide.resolveWith(
                              (states) => const BorderSide(width: 0.0, color: Colors.transparent),
                        ),),
                      InkWell(onTap: (){
                        _chatController.groupType.value = 1;
                      }, child: Text("Private", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),))
                  ],),
                ),
              ],
            ),
          ),
        ),
        _chatController.groupTypeCollapsed.value ? const SizedBox(width : 0, height: 0) : Padding(
          padding: EdgeInsets.only(bottom: 16.0, left: _chatController.groupType.value == 0  ? 0 : 24, right: 24, top: 8),
          child: Text(_chatController.groupType.value == 0  ? "This group is open to everyone interested in joining!" : "Users can request to join your groups, but access will only be granted upon approval from an admin.", textAlign: TextAlign.start, style: TextStyle(fontFamily: "Gilroy", color:
               Colors.grey, fontWeight: FontWeight.w500, fontSize: 13),),
        ),
        SizedBox(height: _chatController.groupVisibilityCollapsed.value || _chatController.groupTypeCollapsed.value ? 8 : 24,),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF113751) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    _chatController.groupVisibilityCollapsed.value = !_chatController.groupVisibilityCollapsed.value;
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Visible", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),),
                      Text(_chatController.groupVisibility.value == 0 ? "Yes" : "No", style: const TextStyle(color: Colors.grey, fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 16),)
                    ],),
                ),
                _chatController.groupVisibilityCollapsed.value ? const SizedBox(width: 0, height: 0,) : const SizedBox(height: 16,),
                _chatController.groupVisibilityCollapsed.value ? const SizedBox(width: 0, height: 0,) : Transform.translate(
                  offset: const Offset(-16, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(value: _chatController.groupVisibility.value == 0, onChanged: (checked){
                        if(checked!) _chatController.groupVisibility.value = 0;
                      },
                        checkColor: const Color(0xFF00CB7D),
                        fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
                        side: MaterialStateBorderSide.resolveWith(
                              (states) => const BorderSide(width: 0.0, color: Colors.transparent),
                        ),),
                      InkWell(onTap : (){
                        _chatController.groupVisibility.value = 0;
                      },child: Text("Yes", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),))
                    ],),
                ),
                _chatController.groupVisibilityCollapsed.value ? const SizedBox(width: 0, height: 0,) : Transform.translate(
                  offset: const Offset(-16, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(value: _chatController.groupVisibility.value == 1, onChanged: (checked){
                        if(checked!) _chatController.groupVisibility.value = 1;
                      },
                        checkColor: const Color(0xFF00CB7D),
                        fillColor: MaterialStateProperty.all<Color>(Colors.transparent),
                        side: MaterialStateBorderSide.resolveWith(
                              (states) => const BorderSide(width: 0.0, color: Colors.transparent),
                        ),),
                      InkWell(onTap: (){
                        _chatController.groupVisibility.value = 1;
                      },
                          child: Text("No", style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black, fontFamily: "Gilroy", fontWeight: FontWeight.w500, fontSize: 16),))
                    ],),
                ),
              ],
            ),
          ),
        )
      ],)),
    );
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
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
              MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E2032) : Colors.white
            ]),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 44.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () {
                _profileController.urlPictureGroup.value = "";
                _chatController.groupTextController.value.text = "";
                Navigator.pop(context);
                }, child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontFamily: "Gilroy"),),),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  "New group",
                  style: TextStyle(
                      color: MediaQuery.of(context).platformBrightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gilroy",
                      fontSize: 20),
                ),
              ),
              TextButton(onPressed: () {
                if(_chatController.groupTextController.value.text.isEmpty) {
                  _utils.showToast(context, "Please, enter a name for you group.");
                } else {
                  _navigationController.hideNavBar.value = true;
                  pushNewScreen(context, screen: const CreateGroupSecondScreen()).then((value) => _navigationController.hideNavBar.value = true);
                }
              }, child: Text("Create", style: TextStyle(color: _chatController.groupNameIsEmpty.value ? Colors.grey : Color(0xff00CB7D), fontFamily: "Gilroy", fontWeight: FontWeight.w600,),),),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chatController.groupVisibilityCollapsed.value = true;
    _chatController.groupTypeCollapsed.value = true;
    _chatController.groupType.value = 0;
    _chatController.groupVisibility.value = 0;
    super.dispose();
  }

}
