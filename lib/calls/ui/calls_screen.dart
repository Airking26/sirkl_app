import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sirkl/common/view/nav_bar/persistent-tab-view.dart';
import 'package:sirkl/calls/controller/calls_controller.dart';
import 'package:sirkl/calls/ui/new_call_screen.dart';
import 'package:sirkl/chats/ui/detailed_chat_screen.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/call_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/navigation/controller/navigation_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tiny_avatar/tiny_avatar.dart';
import 'dart:io';

import '../../common/utils.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({Key? key}) : super(key: key);

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {

  final _callController = Get.put(CallsController());
  final _homeController = Get.put(HomeController());
  final _commonController = Get.put(CommonController());
  final _navigationController = Get.put(NavigationController());
  final PagingController<int, CallDto> pagingSearchController = PagingController(firstPageKey: 0);


  Future<void> fetchPageCallDTO() async {
    try {
      List<CallDto> newItems = await _callController.retrieveCalls(_callController.pageKey.value.toString());
      final isLastPage = newItems.length < 12;
      if (isLastPage) {
        _callController.pagingController.value.appendLastPage(newItems);
      } else {
        final nextPageKey = _callController.pageKey.value++;
        _callController.pagingController.value.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _callController.pagingController.value.error = error;
    }
  }

  Future<void> fetchPageSearchCallDTO(String query) async {
    try {
      List<CallDto> newItems = await _callController.searchInCalls(query);
      pagingSearchController.appendLastPage(newItems);
    } catch (error) {
      pagingSearchController.error = error;
    }
  }

  @override
  void initState() {
    _callController.pagingController.value.addPageRequestListener((pageKey) {
      fetchPageCallDTO();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(()=>Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Column(children: [
          buildAppbar(context),
          buildListCall(context)
          //buildListCall(context)
        ])));
  }

  Widget buildAppbar(BuildContext context) {
    return DeferredPointerHandler(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.topCenter,
        fit: StackFit.loose,
        children: [
          Container(
            height: _callController.callList.value == null || _callController.callList.value!.isEmpty ? 115 : 140,
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
                    MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF113751) : Colors.white,
                    MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF1E2032) : Colors.white
                  ]),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 44.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          "assets/images/arrow_left.png",
                          color:
                          MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.transparent : Colors.transparent,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        con.callsTabRes.tr,
                        style: TextStyle(
                            color: MediaQuery.of(context).platformBrightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Gilroy",
                            fontSize: 20),
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          pushNewScreen(context, screen: const NewCallScreen());
                        },
                        icon: Image.asset(
                          "assets/images/call_tab.png",
                          width: 24,
                          height: 24,
                          color:
                          MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                        )),
                  ],
                ),
              ),
            ),
          ),
          _callController.callList.value == null || _callController.callList.value!.isEmpty ? Container() : Positioned(
              top: Platform.isAndroid? 80 : 60,
              child: DeferPointer(
                child: SizedBox(
                    height: 110,
                    width: MediaQuery.of(context).size.width,
                    child: buildFloatingSearchBar()),
              ))
        ],
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      clearQueryOnClose: false,
      closeOnBackdropTap: false,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      hint: 'Search here...',
      backdropColor: Colors.transparent,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 0),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      queryStyle: TextStyle(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      hintStyle: TextStyle(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xff9BA0A5) : const Color(0xFF828282),
          fontSize: 15,
          fontFamily: "Gilroy",
          fontWeight: FontWeight.w500),
      elevation: 5,
      showCursor: true,
      width: 350,
      accentColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
      borderRadius: BorderRadius.circular(10),
      backgroundColor:
      MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF2D465E).withOpacity(1) : Colors.white,
      debounceDelay: const Duration(milliseconds: 200),
      onQueryChanged: (query) {
        pagingSearchController.itemList = [];
        pagingSearchController.refresh();
        if(query.isNotEmpty) {
          _callController.isSearchIsActive.value = true;
          fetchPageSearchCallDTO(query);
        } else {
          _callController.isSearchIsActive.value = false;
        }
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      automaticallyImplyBackButton: false,
      leadingActions: [
        FloatingSearchBarAction.icon(
          icon: Image.asset(
            "assets/images/search.png",
            width: 24,
            height: 24,
          ),
          showIfClosed: true,
          showIfOpened: true,
          onTap: () {

          },
        ),
      ],
      actions: [],
      builder: (context, transition) {
        return const SizedBox(
          height: 0,
        );
      },
    );
  }

  MediaQuery buildListCall(BuildContext context) {
    return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SafeArea(
                child: PagedListView.separated(
                  pagingController: _callController.isSearchIsActive.value ? pagingSearchController :  _callController.pagingController.value,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  builderDelegate: PagedChildBuilderDelegate<CallDto>(
                    noItemsFoundIndicatorBuilder: (context) => noCallUI(),
                      itemBuilder: (context, item, index) => callTile(item, index)),
                  separatorBuilder: (context, index){
                    return const Divider(color: Color(0xFF828282), thickness: 0.2, endIndent: 20, indent: 86,);},
                ),
              ),
            ),
          ),
        );
  }

  Widget callTile(CallDto callDto, int index){
    var nowMilli = DateTime.now().millisecondsSinceEpoch;
    var updatedAtMilli =  DateTime.parse(callDto.updatedAt.toIso8601String()).millisecondsSinceEpoch;
    var diffMilli = nowMilli - updatedAtMilli;
    var timeSince = DateTime.now().subtract(Duration(milliseconds: diffMilli));
    var now = DateTime.now();
    var dateSubstring = DateTime(callDto.updatedAt.year, callDto.updatedAt.month, callDto.updatedAt.day) == DateTime(now.year, now.month, now.day) ? DateFormat("HH:mm").format(callDto.updatedAt.toLocal()) : DateFormat("dd MMM").format(callDto.updatedAt.toLocal());
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ListTile(

        leading: callDto.called.picture.isNullOrBlank! ?
        InkWell(
          onTap: (){
            _commonController.userClicked.value = callDto.called;
            pushNewScreen(context, screen: const ProfileElseScreen(fromConversation: false, fromNested: true,));
          },
            child: SizedBox(height: 50, width: 50, child: TinyAvatar(baseString: callDto.called.wallet!, dimension: 50, circular: true, colourScheme:TinyAvatarColourScheme.seascape))) :
        InkWell(
          onTap: (){
            _commonController.userClicked.value = callDto.called;
            pushNewScreen(context, screen: const ProfileElseScreen(fromConversation: false, fromNested: true,)).then((value) => _callController.pagingController.value.notifyListeners());
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(90),
            child: CachedNetworkImage(imageUrl: callDto.called.picture!, width: 50, height: 50, fit: BoxFit.cover,placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xff00CB7D))),
                errorWidget: (context, url, error) => Image.asset("assets/images/app_icon_rounded.png", width: 50, height: 50, fit: BoxFit.cover)),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(timeago.format(timeSince), style: TextStyle(fontSize: 12, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color:MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF9BA0A5) : const Color(0xFF828282))),
            ),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                InkWell(onTap:()async{
                  await _callController.inviteCall(callDto.called, DateTime.now().toString(), _homeController.id.value);
                  } ,child: Image.asset("assets/images/call_tab.png", color: const Color(0xFF00CB7D), width: 20, height: 20,)),
                const SizedBox(width: 10,),
                InkWell(
                  onTap: () {
                    _commonController.userClicked.value = callDto.called;
                    _navigationController.hideNavBar.value = true;
                    pushNewScreen(context, screen: const DetailedChatScreen(create: true)).then((value) =>
                    _navigationController.hideNavBar.value = false).then((value) =>
                        _callController.pagingController.value.notifyListeners());
                  },
                    child: Image.asset("assets/images/chat_tab.png", width: 20, height: 20, color: const Color(0xFF9BA0A5),)),
                  const SizedBox(width: 6,),
              ],),
            )
          ],
        ),
        title: Transform.translate(offset: const Offset(-4, 0),child: Text(
            callDto.called.nickname.isNullOrBlank! ?
            (callDto.called.userName.isNullOrBlank! ? "${callDto.called.wallet!.substring(0, 6)}...${callDto.called.wallet!.substring(callDto.called.wallet!.length - 4)}" : callDto.called.userName!.length > 15 ? "${callDto.called.userName!.substring(0,15)}..." : callDto.called.userName!):
            "${callDto.called.nickname!} (${callDto.called.userName.isNullOrBlank! ? "${callDto.called.wallet!.substring(0, 6)}...${callDto.called.wallet!.substring(callDto.called.wallet!.length - 4)}" : callDto.called.userName!.length > 10 ? "${callDto.called.userName!.substring(0,10)}..." : callDto.called.userName!}"")",
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontFamily: "Gilroy", fontWeight: FontWeight.w600, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black))),
        subtitle: Transform.translate(
              offset: const Offset(-4, 0),
              child: Row(children: [
                if(callDto.status == 0)Image.asset("assets/images/outgoing.png", width: 10, height: 10,)
                else if(callDto.status == 1)Image.asset("assets/images/incoming.png", width: 10, height: 10,)
                else Image.asset("assets/images/missed.png", width: 10, height: 10,),
                if(callDto.status == 0) Text( "  Outgoing - $dateSubstring", style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF9BA0A5) : const Color(0xFF828282)))
                else if(callDto.status == 1) Text( "  Incoming - $dateSubstring", style: TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF9BA0A5) : const Color(0xFF828282)))
                else Text( "  Missed - $dateSubstring", style: const TextStyle(fontSize: 13, fontFamily: "Gilroy", fontWeight: FontWeight.w500, color: Colors.red))
              ],),
            )
      ),
    );
  }

  Column noCallUI() {
    return Column(
      children: [
        const SizedBox(
          height: 100,
        ),
        Image.asset(
          "assets/images/people.png",
          width: 150,
          height: 150,
        ),
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Text(
            _callController.isSearchIsActive.value ? "No Results Found" : con.noCallsRes.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black,
                fontSize: 25,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        _callController.isSearchIsActive.value ? const SizedBox() : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: Text(
            con.noCallsSentenceRes.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xFF9BA0A5),
                fontSize: 16,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.w500),
          ),
        ) ,
      ],
    );
  }

  @override
  void dispose() {
    pagingSearchController.dispose();
    _callController.pagingController.value.dispose();
    super.dispose();
  }

}
