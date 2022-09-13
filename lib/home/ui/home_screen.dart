import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/common/constants.dart' as con;

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
        backgroundColor: const Color(0xFF102437),
        body: Column(
          children: [
            Container(
              height: 115,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(45))
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 0.25),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
                  gradient:  LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF111D28),
                        Color(0xFF1E2032)
                      ]
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(onPressed: (){}, icon: Image.asset("assets/images/arrow_left.png")),
                      SvgPicture.asset("assets/images/logo.svg"),
                      IconButton(onPressed: (){}, icon: Image.asset("assets/images/more.png")),
                  ],),
                ),
              ),
            ),
            const SizedBox(height: 100,),
            Image.asset("assets/images/wallet.png", width: 150, height: 150,),
            const SizedBox(height: 30,),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 54.0),
              child: Text(con.connectYourWalletRes.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 25, fontFamily: "Gilroy", fontWeight: FontWeight.w700),),
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
