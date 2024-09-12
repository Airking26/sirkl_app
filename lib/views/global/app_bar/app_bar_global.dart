import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//TODO : To develop and implement if necessary
class AppBarGlobal extends StatefulWidget {
  AppBarGlobal(Key? key, this.appBarHeight, this.iconLeft, this.iconLeftColor,
      this.title, this.iconRight, this.iconRightColor)
      : super(key: key);

  final double? appBarHeight;
  final String? iconLeft;
  final Color? iconLeftColor;
  final String title;
  final String? iconRight;
  final Color? iconRightColor;

  @override
  State<AppBarGlobal> createState() => _AppBarGlobalState();
}

class _AppBarGlobalState extends State<AppBarGlobal> {
  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.topCenter,
        fit: StackFit.loose,
        children: [
          Container(
            height: widget.appBarHeight,
            margin: const EdgeInsets.only(bottom: 0.25),
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 0.01), //(x,y)
                  blurRadius: 0.01,
                ),
              ],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(35)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xFF113751)
                        : Colors.white,
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? const Color(0xFF1E2032)
                        : Colors.white
                  ]),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 52.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => IconButton(
                        onPressed: () async {},
                        icon: Image.asset(
                          widget.iconLeft!,
                          color: widget.iconLeftColor,
                          width: 32,
                          height: 32,
                        ))),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Obx(() => Text(
                            widget.title,
                            style: TextStyle(
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Gilroy",
                                fontSize: 20),
                          )),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          widget.iconRight!,
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 32,
                          height: 32,
                        )),
                  ],
                ),
              ),
            ),
          ),
          /*Obx(() => Positioned(
              top: 110,
              child: _groupController.isSearchActiveInCommunity.value
                  ? DeferPointer(
                      child: SizedBox(
                          height: 48,
                          width: MediaQuery.of(context).size.width,
                          child: buildFloatingSearchBar()),
                    )
                  : _groupController.isAddingCommunity.value
                      ? Container()
                      : Material(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Container(
                              height: 48,
                              width: 350,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? const Color(0xFF2D465E).withOpacity(1)
                                      : Colors.white),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0, bottom: 2, left: 4, right: 4),
                                child: Obx(
                                  () => TabBar(
                                    labelPadding: EdgeInsets.zero,
                                    indicatorPadding: EdgeInsets.zero,
                                    indicatorColor: Colors.transparent,
                                    controller: tabController,
                                    padding: EdgeInsets.zero,
                                    dividerColor: Colors.transparent,
                                    tabs: [
                                      Container(
                                        height: 48,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gradient: _groupController
                                                      .indexCommunity.value ==
                                                  0
                                              ? const LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                      Color(0xFF1DE99B),
                                                      Color(0xFF0063FB)
                                                    ])
                                              : MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.dark
                                                  ? const LinearGradient(
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                      colors: [
                                                          Color(0xFF2D465E),
                                                          Color(0xFF2D465E)
                                                        ])
                                                  : const LinearGradient(
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                      colors: [
                                                          Colors.white,
                                                          Colors.white
                                                        ]),
                                        ),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Favorites",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: "Gilroy",
                                                  fontWeight: FontWeight.w700,
                                                  color: _groupController
                                                              .indexCommunity
                                                              .value ==
                                                          0
                                                      ? Colors.white
                                                      : MediaQuery.of(context)
                                                                  .platformBrightness ==
                                                              Brightness.dark
                                                          ? const Color(
                                                              0xFF9BA0A5)
                                                          : const Color(
                                                              0xFF828282)),
                                            )),
                                      ),
                                      Container(
                                        height: 48,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gradient: _groupController
                                                      .indexCommunity.value ==
                                                  1
                                              ? const LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                      Color(0xFF1DE99B),
                                                      Color(0xFF0063FB)
                                                    ])
                                              : MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.dark
                                                  ? const LinearGradient(
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                      colors: [
                                                          Color(0xFF2D465E),
                                                          Color(0xFF2D465E)
                                                        ])
                                                  : const LinearGradient(
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                      colors: [
                                                          Colors.white,
                                                          Colors.white
                                                        ]),
                                        ),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Others",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: "Gilroy",
                                                  fontWeight: FontWeight.w700,
                                                  color: _groupController
                                                              .indexCommunity
                                                              .value ==
                                                          1
                                                      ? Colors.white
                                                      : MediaQuery.of(context)
                                                                  .platformBrightness ==
                                                              Brightness.dark
                                                          ? const Color(
                                                              0xFF9BA0A5)
                                                          : const Color(
                                                              0xFF828282)),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                        )))*/
        ],
      ),
    );
  }
}
