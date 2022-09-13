import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:sirkl/home/controller/home_controller.dart';

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
                        Color(0xFF111D28),//.withAlpha(195),
                        Color(0xFF1E2032)//.withAlpha(195)
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
            const SizedBox(height: 120,),
            Container(height: 150, width: 150, child: Image.asset("assets/images/wallet.png")),
            const SizedBox(height: 30,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 54.0),
              child: Text("Connect your wallet", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 25, fontFamily: "Gilroy", fontWeight: FontWeight.w700),),
            ),
            const SizedBox(height: 15,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 54.0),
              child: Text("Talk with other wallets and your NFT groups", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9BA0A5), fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w500),),
            ),
            const SizedBox(height: 50,),
           Obx(() => NiceButtons(
              stretch: false,
                borderThickness: 5,
                progress: _homeController.progress.value,
                borderColor: Color(0xff0063FB).withOpacity(0.5),
                startColor: Color(0xff1DE99B),
                endColor: Color(0xff0063FB),
                gradientOrientation: GradientOrientation.Horizontal,
                onTap: (finish){
                },
               child: Text("Get Started", style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: "Gilroy", fontWeight: FontWeight.w700),)
           )),
          ],
        ));
  }
}
