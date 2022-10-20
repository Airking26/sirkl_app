import 'dart:io';

import 'package:advstory/advstory.dart';
import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:get/get.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:sirkl/common/model/example.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/common/constants.dart' as con;

import '../../common/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final _homeController = Get.put(HomeController());
  final _passwordController = TextEditingController();
  final items =
  <Example>[
    Example(name: "Amerique", tagIndex: "A"),
    Example(name: "Ameque", tagIndex: "A"),
    Example(name: "Amerque", tagIndex: "A"),
    Example(name: "Ameriqe", tagIndex: "A"),
    Example(name: "Ameriq", tagIndex: "A"),
    Example(name: "Ame", tagIndex: "A"),
    Example(name: "Boli", tagIndex: "B"),
    Example(name: "Alo", tagIndex: "A"),
    Example(name: "Dilo", tagIndex: "D"),
    Example(name: "Fea", tagIndex: "F"),
    Example(name: "Amerique", tagIndex: "A"),
    Example(name: "Ameque", tagIndex: "A"),
    Example(name: "Amerque", tagIndex: "A"),
    Example(name: "Ameriqe", tagIndex: "A"),
    Example(name: "Ameriq", tagIndex: "A"),
    Example(name: "Ame", tagIndex: "A"),
    Example(name: "Boli", tagIndex: "B"),
    Example(name: "Boli", tagIndex: "B"),
    Example(name: "Boli", tagIndex: "B"),
    Example(name: "Boli", tagIndex: "B"),
    Example(name: "Boli", tagIndex: "B"),
    Example(name: "Boli", tagIndex: "B"),
    Example(name: "Boli", tagIndex: "B"),
    Example(name: "Alo", tagIndex: "A"),
    Example(name: "Dilo", tagIndex: "D"),
    Example(name: "Fea", tagIndex: "F"),
  ];

  @override
  Widget build(BuildContext context) {
    SuspensionUtil.sortListBySuspensionTag(items);
    SuspensionUtil.setShowSuspensionStatus(items);
    return Scaffold(
        backgroundColor: Get.isDarkMode ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() =>
            Column(
              children: [
                buildAppbar(context),
                _homeController.accessToken.value.isNotEmpty ? buildStoryList() : _homeController.address.value.isEmpty ? buildConnectWalletUI() : _homeController.isUserExists.value ? buildSignIn() : buildSignUp(),
                _homeController.accessToken.value.isNotEmpty ? buildRepertoireList(context) : Container(),
              ],
            ),
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
                    IconButton(onPressed: (){}, icon: Image.asset("assets/images/arrow_left.png", color: Get.isDarkMode ? Colors.transparent : Colors.transparent,)),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Image.asset("assets/images/logo.png", height: 20,),
                    ),
                    IconButton(onPressed: (){Utils().dialogPopMenu(context);}, icon: Image.asset("assets/images/more.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                ],),
              ),
            ),
          );
  }

  Container buildStoryList() {
    return Container(
            padding: const EdgeInsets.only(top: 16),
            height: 122,
            child: AdvStory(
              style: AdvStoryStyle(indicatorStyle: IndicatorStyle(padding: EdgeInsets.symmetric(horizontal: 4, vertical: Platform.isAndroid ? 8 : 48))),
              storyCount: 6,
              storyBuilder: (storyIndex) => Story(
                contentCount: 3,
                contentBuilder: (contentIndex) => ImageContent(
                    url: "https://i1.adis.ws/i/canon/canon-get-inspired-party-1-1920?",
                errorBuilder: () {
                return const Center(
                child: Text("An error occured!"),
                );}),
              ),
              trayBuilder: (index) => AdvStoryTray(url: "https://img.seadn.io/files/9a3bb789c07f93d50d9c50dc0dae7cf1.png?auto=format&fit=max&w=640",
                username: Text("Samuel", style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 16, color: Get.isDarkMode ? Colors.white : Colors.black),
                ), gapSize: 0, borderGradientColors: [const Color(0xFF1DE99B), const Color(0xFF0063FB), const Color(0xFF1DE99B), const Color(0xFF0063FB)],),
            ),
          );
  }

  Widget buildRepertoireList(BuildContext context) {
    return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
                child: Padding(padding: const EdgeInsets.only(top: 0),
                child: SafeArea(child:
                AzListView(
                  indexBarMargin: const EdgeInsets.only(right: 8, top: 12, bottom: 12),
                  indexHintBuilder: (context, hint){
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xff00CB7D)),
                      alignment: Alignment.center, child: Text(hint, style: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Colors.white, fontSize: 18)),);
                  },
                  indexBarItemHeight: MediaQuery.of(context).size.height / 50,
                  indexBarOptions: IndexBarOptions(
                    textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy"),
                      decoration: getIndexBarDecoration(const Color(0xFF828282).withOpacity(0.8)),
                      downDecoration: getIndexBarDecoration(const Color(0xFF828282).withOpacity(0.8)),
                      selectTextStyle: const TextStyle(color: const Color(0xff00CB7D), fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "Gilroy"),
                      selectItemDecoration: const BoxDecoration(),
                      needRebuild: true,
                      indexHintAlignment: Alignment.centerRight,
                      indexHintOffset: const Offset(0, 0)),
                  padding: const EdgeInsets.only(top: 16),
                  data: items,
                  itemCount: items.length,
                  itemBuilder: buildSirklRepertoire,
                ),),)),
          );
  }

  Decoration getIndexBarDecoration(Color color) {
    return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.0),);
  }

  Widget buildSirklRepertoire(BuildContext context, int index){

    return Column(
      children: [
        Offstage(
          offstage: !items[index].isShowSuspension,
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 60),
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(items[index].tagIndex!, softWrap: false, style: TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w700, color: Get.isDarkMode ? Colors.white : Colors.black, fontSize: 20),),
                Expanded(
                    child: Divider(
                      color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282),
                      height: 2,
                      indent: 10.0,
                    ))
              ],
            ),
          ),
        ),
        buildSirklTile(context, index),
      ],
    );
  }

  Widget buildSirklTile(BuildContext context, int index){
    return Padding(
      padding: const EdgeInsets.only(right: 36.0),
      child: Column(
        children: [
          ListTile(
            leading: CachedNetworkImage(imageUrl: "https://ik.imagekit.io/bayc/assets/bayc-footer.png", width: 60, height: 60, fit: BoxFit.cover,),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset("assets/images/call_tab.png", color: const Color(0xFF00CB7D), width: 20, height: 20,),
                      const SizedBox(width: 8,),
                      Image.asset("assets/images/chat_tab.png", width: 20, height: 20, color: const Color(0xFF9BA0A5),),
                      const SizedBox(width: 4,),
                      Image.asset("assets/images/more.png", width: 20, height: 20,color: const Color(0xFF9BA0A5))
                    ],),
                )
              ],
            ),
            title: Transform.translate(offset: const Offset(-8, 0),child: Text("Garyvee", style: TextStyle(fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black))),
            subtitle: Transform.translate(offset: const Offset(-8, 0),child: Text("Lorem Ipsum is simply...", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282)))),

          ),
          Divider(color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282),indent: 0,endIndent: 24, thickness: 0.2)
        ],
      ),
    );
  }

  Column buildConnectWalletUI() {
    return Column(
            children: [
              const SizedBox(height: 100,),
              Image.asset("assets/images/wallet.png", width: 150, height: 150,),
              const SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 54.0),
                child: Text(con.connectYourWalletRes.tr, textAlign: TextAlign.center, style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black, fontSize: 25, fontFamily: "Gilroy", fontWeight: FontWeight.w700),),
              ),
              const SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 54.0),
                child: Text(con.talkWithRes.tr, textAlign: TextAlign.center, style: TextStyle(color: Get.isDarkMode ? const Color(0xFF9BA0A5) : const Color(0xFF828282), fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w500),),
              ),
              const SizedBox(height: 50,),
              NiceButtons(
                  stretch: false,
                  borderThickness: 5,
                  progress: false,
                  borderColor: const Color(0xff0063FB).withOpacity(0.5),
                  startColor: const Color(0xff1DE99B),
                  endColor: const Color(0xff0063FB),
                  gradientOrientation: GradientOrientation.Horizontal,
                  onTap: (finish) async{
                    await _homeController.connectWallet();
                  },
                  child: Text(con.getStartedRes.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: "Gilroy", fontWeight: FontWeight.w700),)
              ),
            ],
          );
  }

  Column buildSignUp() {
    return Column(
            children: [
              const SizedBox(height: 35,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                    controller: _passwordController,
                  decoration: const InputDecoration(border: OutlineInputBorder(borderSide: BorderSide())),
                ),
              ),
              const SizedBox(height: 10,),
              FlutterPwValidator(
                  controller: _passwordController,
                  minLength: 6,
                  uppercaseCharCount: 2,
                  numericCharCount: 3,
                  specialCharCount: 1,
                  width: 350,
                  height: 120,
                  onSuccess: (){},
                  onFail: (){}
              ),
              const SizedBox(height: 30,),
              Container( width: 350, height: 50, padding: const EdgeInsets.all(8), child: const Text("Hello darkness my old friend", style: const TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w600, fontSize: 16),)),
              const SizedBox(height: 30,),
              NiceButtons(
                  stretch: false,
                  borderThickness: 5,
                  progress: false,
                  borderColor: const Color(0xff0063FB).withOpacity(0.5),
                  startColor: const Color(0xff1DE99B),
                  endColor: const Color(0xff0063FB),
                  gradientOrientation: GradientOrientation.Horizontal,
                  onTap: (finish) async{
                    await _homeController.signUp(_homeController.address.value, _passwordController.text, "Hello Darkness My Old Friend");
                  },
                  child: Text(con.getStartedRes.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: "Gilroy", fontWeight: FontWeight.w700),)
              ),
            ],
          );
  }

  Column buildSignIn() {
    return Column(
            children: [
              const SizedBox(height: 50,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                    controller: _passwordController,
                  decoration: const InputDecoration(border: const OutlineInputBorder(borderSide: BorderSide())),
                ),
              ),
              const SizedBox(height: 30,),
              NiceButtons(
                  stretch: false,
                  borderThickness: 5,
                  progress: false,
                  borderColor: const Color(0xff0063FB).withOpacity(0.5),
                  startColor: const Color(0xff1DE99B),
                  endColor: const Color(0xff0063FB),
                  gradientOrientation: GradientOrientation.Horizontal,
                  onTap: (finish) async{
                    await _homeController.signIn(_homeController.address.value, _passwordController.text);
                  },
                  child: Text(con.getStartedRes.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: "Gilroy", fontWeight: FontWeight.w700),)
              ),
            ],
          );
  }

}
