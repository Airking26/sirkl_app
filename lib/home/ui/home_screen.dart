import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nice_buttons/nice_buttons.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.isDarkMode ? const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
        body: Column(
          children: [
            Container(
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
                      IconButton(onPressed: (){}, icon: Image.asset("assets/images/arrow_left.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: SvgPicture.asset("assets/images/logo.svg"),
                      ),
                      IconButton(onPressed: (){Utils().dialogPopMenu(context);}, icon: Image.asset("assets/images/more.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                  ],),
                ),
              ),
            ),
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
              child: Text(con.talkWithRes.tr, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9BA0A5), fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w500),),
            ),
            const SizedBox(height: 50,),
           Obx(() => NiceButtons(
              stretch: false,
                borderThickness: 5,
                progress: _homeController.progress.value,
                borderColor: const Color(0xff0063FB).withOpacity(0.5),
                startColor: const Color(0xff1DE99B),
                endColor: const Color(0xff0063FB),
                gradientOrientation: GradientOrientation.Horizontal,
                onTap: (finish){
                },
               child: Text(con.getStartedRes.tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: "Gilroy", fontWeight: FontWeight.w700),)
           )),
          ],
        ));
  }
}
