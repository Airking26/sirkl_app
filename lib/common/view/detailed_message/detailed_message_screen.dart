import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;


import '../bubble/bubble.dart';


class DetailedMessageScreen extends StatefulWidget {
  const DetailedMessageScreen({Key? key}) : super(key: key);

  @override
  State<DetailedMessageScreen> createState() => _DetailedMessageScreenState();
}

class _DetailedMessageScreenState extends State<DetailedMessageScreen> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3a');
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chat(
        theme: DefaultChatTheme(backgroundColor: Color.fromARGB(255, 247, 253, 255), 
            sentMessageBodyTextStyle: TextStyle(color: Colors.black, fontSize: 15, fontFamily: "Gilroy", fontWeight: FontWeight.w500),
        deliveredIcon: Image.asset("assets/images/plus.png", color: Colors.amber,),
        seenIcon: Image.asset("assets/images/plus.png", color: Colors.amber,),
        sendingIcon: Image.asset("assets/images/plus.png", color: Colors.amber,),),
        customBottomWidget: buildBottomBar(),
        showUserAvatars: true,
        showUserNames: true,
        bubbleBuilder: _bubbleBuilder,
        messages: _messages,
        onSendPressed: (message){},
        user: _user,
      ),
    );
  }

  /*void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: "3R3RF3RFD3F4G4GG4",
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }*/

  Container buildBottomBar() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(color: Colors.grey, width: 0.01)),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Get.isDarkMode ? const Color(0xFF111D28) : Colors.white,
              Get.isDarkMode ? const Color(0xFF1E2032) : Colors.white
            ]),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 3,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282),
                  ),
                  onPressed: () {
                   // _handleImageSelection();
                  },
                ),
                hintText: con.writeHereRes.tr,
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: "Gilroy",
                    color: Get.isDarkMode
                        ? const Color(0xff9BA0A5)
                        : const Color(0xFF828282)),
                filled: true,
                fillColor:
                Get.isDarkMode ? const Color(0xFF2D465E) : const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Flexible(
            child: InkWell(
              onTap: (){
                final textMessage = types.TextMessage(
                  author: _user,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  id: 'fj324FFZ2342DZ23E3D33DDD3D2E2',
                  text: controller.text,
                );
                _handleSendPressed(textMessage);
                },
              child: Container(
                width: 55,
                height: 55,
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
                      height: 32,
                      width: 32,
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      //await OpenFile.open(message.uri);
    }
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.TextMessage message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: 'fj324FFZ2342DZ23E3D33DDD3D2E2',
      text: message.text,
    );

    _addMessage(textMessage);
  }

  Widget _bubbleBuilder(
      Widget child, {
        required message,
        required nextMessageInGroup,
      }) =>
      Bubble(
        child: child,
        radius: Radius.circular(15),
        color: _user.id != message.author.id ||
            message.type == types.MessageType.image
            ? const Color(0xff102437)
            : const Color(0xffffffff),
        margin: nextMessageInGroup
            ? const BubbleEdges.symmetric(horizontal: 6)
            : null,
        nip: nextMessageInGroup
            ? BubbleNip.no
            : _user.id != message.author.id
            ? BubbleNip.leftBottom
            : BubbleNip.no,
      );
}
