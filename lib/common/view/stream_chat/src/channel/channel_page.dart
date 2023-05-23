
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sirkl/chats/controller/chats_controller.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/view/stream_chat/src/utils/audio_loading_message.dart';
import 'package:sirkl/common/view/stream_chat/src/utils/audio_player_message.dart';
import 'package:sirkl/common/view/stream_chat/src/utils/record_button.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';

class ChannelPage extends StatefulWidget {
  const ChannelPage({Key? key, this.fromProfile = false}) : super(key: key);
  final bool fromProfile;

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {

  FocusNode? _focusNode;
  final StreamMessageInputController _messageInputController = StreamMessageInputController();
  final _commonController = Get.put(CommonController());

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    //_chatController.channel.value = null;
    _focusNode!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark ? MediaQuery.of(context).platformBrightness == Brightness.dark ? const Color(0xFF102437) :const Color.fromARGB(255, 247, 253, 255) :MediaQuery.of(context).platformBrightness == Brightness.dark ?  const Color(0xFF102437) : const Color.fromARGB(255, 247, 253, 255),
      body: Column(
        children: <Widget>[
          StreamChannelHeader(commonController: _commonController, fromProfile: widget.fromProfile),
          Expanded(
            child: StreamMessageListView(
              onMessageSwiped: _reply,

              messageBuilder: (context, details, messages, defaultMessageWidget) {
                return defaultMessageWidget.copyWith(
                  onReplyTap: _reply,
                  customAttachmentBuilders: {
                    'voicenote': (context, defaultMessage, attachments) {
                      final url = attachments.first.assetUrl;
                      late final Widget widget;
                      if (url == null) {
                        widget = const AudioLoadingMessage();
                      } else {
                        widget = AudioPlayerMessage(
                          source: AudioSource.uri(Uri.parse(url)),
                          id: defaultMessage.id,
                        );
                      }
                      return SizedBox(
                        width: 250,
                        height: 50,
                        child: widget,
                      );
                    }
                  },
                  deletedBottomRowBuilder: (context, message){
                    return const StreamVisibleFootnote();
                  },
                );
              },
            ),
          ),
          const StreamTypingIndicator(),
          StreamMessageInput(messageInputController: _messageInputController, showCommandsButton : false, focusNode: _focusNode, actions: [
            RecordButton(recordingFinishedCallback: _recordingFinishedCallback)
          ],),
        ],
      ),
    );
  }

  void _recordingFinishedCallback(String path) {
    final uri = Uri.parse(path);
    File file = File(uri.path);
    file.length().then(
          (fileSize) {
        StreamChannel.of(context).channel.sendMessage(
          Message(
            attachments: [
              Attachment(
                type: 'voicenote',
                file: AttachmentFile(
                  size: fileSize,
                  path: uri.path,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _reply(Message message) {
    _messageInputController.quotedMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode!.requestFocus();
    });
  }



}