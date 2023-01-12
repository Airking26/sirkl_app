
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';

class ChannelPage extends StatefulWidget {
  const ChannelPage({Key? key}) : super(key: key);

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {

  FocusNode? _focusNode;
  final StreamMessageInputController _messageInputController = StreamMessageInputController();
  final _commonController = Get.put(CommonController());
  final _chatController = Get.put(ChatsController());

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _chatController.channel.value = null;
    _focusNode!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF102437) :const Color.fromARGB(255, 247, 253, 255) :MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
      body: Column(
        children: <Widget>[
          StreamChannelHeader(commonController: _commonController),
          Expanded(
            child: StreamMessageListView(
              onMessageSwiped: _reply,
              messageBuilder: (context, details, messages, defaultMessageWidget) {
                return defaultMessageWidget.copyWith(
                  onReplyTap: _reply,
                  deletedBottomRowBuilder: (context, message){
                    return const StreamVisibleFootnote();
                  },
                );
              },
            ),
          ),
          const StreamTypingIndicator(),
          StreamMessageInput(messageInputController: _messageInputController, focusNode: _focusNode,),
        ],
      ),
    );
  }

  void _reply(Message message) {
    _messageInputController.quotedMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode!.requestFocus();
    });
  }



}