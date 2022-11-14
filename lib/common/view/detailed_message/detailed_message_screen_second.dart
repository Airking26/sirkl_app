import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/constants.dart' as con;
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/inbox_creation_dto.dart';
import 'package:sirkl/common/model/inbox_modification_dto.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/src/stream_chat.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';
import 'package:sirkl/profile/ui/profile_else_screen.dart';
import 'package:tiny_avatar/tiny_avatar.dart';
import 'package:zego_zim/zego_zim.dart';

import '../../interface/ZIMEventHandlerManager.dart';
import '../../utils.dart';
import '../dialog/custom_dial.dart';

class DetailedMessageScreenOtherSecond extends StatefulWidget {
  const DetailedMessageScreenOtherSecond({Key? key}) : super(key: key);

  @override
  State<DetailedMessageScreenOtherSecond> createState() =>
      _DetailedMessageScreenOtherSecondState();
}

class _DetailedMessageScreenOtherSecondState
    extends State<DetailedMessageScreenOtherSecond> {
  final utils = Utils();
  YYDialog dialogMenu = YYDialog();
  final _commonController = Get.put(CommonController());
  final _chatController = Get.put(ChatsController());
  final _homeController = Get.put(HomeController());
  final _textMessageController = TextEditingController();



  @override
  void initState() {
    _chatController.checkOrCreateChannel(_homeController, _commonController, StreamChat.of(context).client, StreamChat.of(context).currentUser!.id);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Obx(() => StreamChat(
          client: StreamChat.of(context).client,
          child: StreamChannel(channel: _chatController.channel.value!,
          child: ChannelPage(channel : _chatController.channel.value!, homeController:  _homeController, commonController: _commonController)),
        )));
  }


  YYDialog dialogPopMenu(BuildContext context) {
    return YYDialog().build(context)
      ..width = 180
      ..borderRadius = 10.0
      ..gravity = Gravity.rightTop
      ..barrierColor =
          Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05)
      ..backgroundColor =
          Get.isDarkMode ? const Color(0xFF1E3244).withOpacity(0.95) : Colors.white
      ..margin = const EdgeInsets.only(top: 90, right: 20)
      ..widget(InkWell(
        onTap: () async {
          dialogMenu.dismiss();
          if (_commonController.userClickedFollowStatus.value) {
            if (await _commonController
                .removeUserToSirkl(_commonController.userClicked.value!.id!)) {
              utils.showToast(
                  context,
                  con.userRemovedofSirklRes.trParams({
                    "user": _commonController.userClicked.value!.userName.isNullOrBlank!?
                        _commonController.userClicked.value!.wallet! : _commonController.userClicked.value!.userName!
                  }));
            }
          } else {
            if (await _commonController
                .addUserToSirkl(_commonController.userClicked.value!.id!)) {
              utils.showToast(
                  context,
                  con.userAddedToSirklRes.trParams({
                    "user": _commonController.userClicked.value!.userName.isNullOrBlank! ?
                        _commonController.userClicked.value!.wallet! : _commonController.userClicked.value!.userName!
                  }));
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _commonController.userClickedFollowStatus.value
                    ? con.removeOfMySirklRes.tr
                    : con.addToMySirklRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () {
          Get.to(() => const ProfileElseScreen());
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                con.profileTabRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..divider(color: const Color(0xFF828282), padding: 20.0)
      ..widget(InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 10.0, 16.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                con.reportRes.tr,
                style: TextStyle(
                    fontSize: 14,
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w600),
              )),
        ),
      ))
      ..show();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ChannelPage extends StatelessWidget {

  ChannelPage( {Key? key, this.channel, this.homeController, this.commonController,  this.messageInputFocusNode}) : super(key: key);

  final Channel? channel;
  final CommonController? commonController;
  final HomeController? homeController;
  final FocusNode? messageInputFocusNode;
  late BuildContext context;
  final _effectiveController = StreamMessageInputController();

  @override
  Widget build(BuildContext context) {

    this.context = context;

    return StreamChatTheme(
      data: StreamChatThemeData(
        /*messageInputTheme: StreamMessageInputThemeData(borderRadius: BorderRadius.circular(5), elevation: 0, inputTextStyle: TextStyle(fontWeight: FontWeight.w500, fontFamily: "Gilroy", fontSize: 16, color: Get.isDarkMode ? Colors.white : Colors.black), inputDecoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFF2F2F2),
              hintText: con.writeHereRes.tr,
              hintStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, fontFamily: "Gilroy", color: Get.isDarkMode ?  Color(0xff9BA0A5) :  Color(0xFF828282)),
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(60)),
            )),*/
        messageListViewTheme: StreamMessageListViewThemeData(backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255)),
      ),
      child: Scaffold(
        backgroundColor: Get.isDarkMode
            ? const Color(0xFF102437)
            : const Color.fromARGB(255, 247, 253, 255),
        body: Column(
          children: <Widget>[
            buildAppbar(context),
            Expanded(
                child: StreamMessageListView(
                  showFloatingDateDivider: false,
                  //messageBuilder: buildChatTileGetStream,
                  dateDividerBuilder: buildDateTile,
                  showConnectionStateTile: true,
                ),
            ),
            Container(
              color: Get.isDarkMode
                  ? const Color(0xFF102437)
                  : const Color.fromARGB(255, 247, 253, 255),
              child: StreamMessageInput(
                //sendButtonBuilder: buildSendButton,
                //messageInputController: _effectiveController,
                sendButtonLocation: SendButtonLocation.outside,
                actionsLocation: ActionsLocation.left,
                onMessageSent: (e) async{
                  //var k = await channel!.addMembers([homeController!.id.value, commonController!.userClicked.value!.id!]);
                 var t = "";
                },
              ),
            ),
          ],
        ),
      ),
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
              Get.isDarkMode ? const Color(0xFF113751) : Colors.white,
              Get.isDarkMode ? const Color(0xFF1E2032) : Colors.white
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
              SizedBox(
                width: 250,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Image.asset(
                          "assets/images/arrow_left.png",
                          color: Get.isDarkMode ? Colors.white : Colors.black,
                        )),
                    InkWell(
                      onTap: () {
                        Get.to(() => const ProfileElseScreen());
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(90),
                            child:
                            commonController!.userClicked.value!.picture == null ?
                            TinyAvatar(baseString: commonController!.userClicked.value!.wallet!, dimension: 40, circular: true, colourScheme: commonController!.userClicked.value!.wallet!.substring(0, 1).isAz() ? TinyAvatarColourScheme.seascape : TinyAvatarColourScheme.heated,) :
                            CachedNetworkImage(
                              imageUrl: commonController!.userClicked.value!.picture!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => const ProfileElseScreen());
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                               commonController!
                                  .userClicked.value!.userName.isNullOrBlank! ?
                              "${commonController!
                                  .userClicked.value!.wallet!.substring(0, 15)}..." : commonController!
                                  .userClicked.value!.userName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Gilroy",
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              IconButton(
                  onPressed: () {
                    //dialogMenu = dialogPopMenu(context);
                  },
                  icon: Image.asset(
                    "assets/images/more.png",
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSendButton(BuildContext context, StreamMessageInputController streamMessageInputController){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () async {
          //streamMessageInputController.
          var to = await StreamMessageInputState().sendMessage();
        },
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF1DE99B), Color(0xFF0063FB)])),
          child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/send.png",
                height: 26,
                width: 26,
              )),
        ),
      ),
    );
  }

  String buildDivider(DateTime dateTime){
    final createdAt = Jiffy(dateTime);
    final now = Jiffy(DateTime.now());

    var dayInfo = createdAt.MMMd;
    if (createdAt.isSame(now, Units.DAY)) {
      dayInfo = context.translations.todayLabel;
    } else if (createdAt.isSame(now.subtract(days: 1), Units.DAY)) {
      dayInfo = context.translations.yesterdayLabel;
    } else if (createdAt.isAfter(now.subtract(days: 7), Units.DAY)) {
      dayInfo = createdAt.EEEE;
    } else if (createdAt.isAfter(now.subtract(years: 1), Units.DAY)) {
      dayInfo = createdAt.MMMd;
    }

    return dayInfo.toUpperCase();
  }

  Widget buildDateTile(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
              child: Container(
                color: const Color(0XFFF2F2F2),
                height: 1,
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(
              buildDivider(date),
              style: const TextStyle(
                  color: Color(0XFF828282),
                  fontSize: 14,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
              child: Container(
                color: const Color(0XFFF2F2F2),
                height: 1,
              )),
        ],
      ),
    );
  }

  Widget buildChatTile(BuildContext context,
      MessageDetails details,
      List<Message> messages,
      StreamMessageWidget defaultMessageWidget,) {

    final message = details.message;
    final isCurrentUser = StreamChat.of(context).currentUser!.id == message.user!.id;
    final textAlign = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
        alignment: textAlign,
        child: !isCurrentUser
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8),
              child:
              message.user?.image == null ?
              TinyAvatar(baseString: message.user?.name ?? "", dimension: 40, circular: true, colourScheme: TinyAvatarColourScheme.seascape) :
              ClipRRect(
                borderRadius: BorderRadius.circular(90),
                child: CachedNetworkImage(
                  imageUrl: message.user?.image ?? "",
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 80.0, top: 8, bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF102437),
                            Color(0xFF13171B)
                          ]),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: const Offset(0.0, 0.01), //(x,y)
                          blurRadius: Get.isDarkMode ? 0.25 : 0,
                        ),
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message.text!,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "Gilroy",
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          DateFormat("hh:mm a").format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  message.updatedAt.millisecondsSinceEpoch)),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Gilroy"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
            : Padding(
          padding: const EdgeInsets.only(
              left: 80.0, right: 16, top: 8, bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  topRight: Radius.circular(10)),
              gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset:
                  Offset(0.0, Get.isDarkMode ? 0 : 0.01), //(x,y)
                  blurRadius: Get.isDarkMode ? 0 : 0.25,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text!,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      color: Colors.black,
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.w500,
                      fontSize: 15),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 0),
                  child: Text(
                    DateFormat("hh:mm a").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            message.updatedAt.millisecondsSinceEpoch)),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Gilroy"),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget buildChatTileGetStream(BuildContext context,
      MessageDetails details,
      List<Message> messages,
      StreamMessageWidget defaultMessageWidget,) {

    final message = details.message;
    final isCurrentUser = StreamChat.of(context).currentUser!.id == message.user!.id;
    final textAlign = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
        alignment: textAlign,
        child: !isCurrentUser
            ? SizedBox(width: 200, height: 50,child: StreamMessageWidget(message: message, messageTheme: StreamMessageThemeData()))
            : SizedBox(width:200, height: 50, child: StreamMessageWidget(message: message, messageTheme: StreamMessageThemeData()))
    );
  }

}