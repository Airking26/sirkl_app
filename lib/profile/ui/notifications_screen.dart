import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;
import '../../common/utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
                      Get.isDarkMode ? const Color(0xFF113751) : Colors.white,
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
                      IconButton(onPressed: (){Get.back();}, icon: Image.asset("assets/images/arrow_left.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(con.notificationsRes.tr, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Get.isDarkMode ? Colors.white : Colors.black),),
                      ),
                      IconButton(onPressed: (){Utils().dialogPopMenu(context);}, icon: Image.asset("assets/images/more.png", color: Get.isDarkMode ? Colors.white : Colors.black,)),
                    ],),
                ),
              ),
            ),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Expanded(child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: 20,
                  separatorBuilder: (context, index){return const Divider(color: Color(0xFF828282), thickness: 0.2, endIndent: 20, indent: 20,);},
                  itemBuilder: buildNotificationTile)
              ),
            )
          ],
        ));
  }

  Widget buildNotificationTile(BuildContext context, int index){
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ListTile(
        onTap: (){},
        leading: CachedNetworkImage(imageUrl: "https://ik.imagekit.io/bayc/assets/bayc-footer.png", width: 60, height: 60, fit: BoxFit.cover,placeholder: (context, url) => Center(child: const CircularProgressIndicator()),
            errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png")),
        title: Transform.translate(
          offset: Offset(-8, 0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(),
              children: [
                TextSpan(text: "You have added", style: TextStyle(fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w400, color: Get.isDarkMode ? Colors.white : Colors.black)),
                TextSpan(text: " Grodongoner.eth ", style: TextStyle(fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: Color(0xff00CB7D))),
                TextSpan(text: "in your SIRKL - 2hrs ago", style: TextStyle(fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w400, color: Get.isDarkMode ? Colors.white : Colors.black)),
              ]
            ),
          ),
        ),
        //subtitle: Text("Lorem Ipsum is simply...", style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Get.isDarkMode ? Color(0xFF9BA0A5) : Color(0xFF828282))),
      ),
    );
  }
}
