import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/controllers/inbox_controller.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

class StreamMessageSearchPage extends StatefulWidget {
  const StreamMessageSearchPage({
    Key? key,
    required this.client,
  }) : super(key: key);

  final StreamChatClient client;

  @override
  State<StreamMessageSearchPage> createState() => _StreamMessageSearchState();
}

class _StreamMessageSearchState extends State<StreamMessageSearchPage> {
  InboxController get _chatController => Get.find<InboxController>();
  late final _controller = StreamMessageSearchListController(
    client: widget.client,
    limit: 20,
    filter: Filter.in_(
      'members',
      [StreamChat.of(context).currentUser!.id],
    ),
    searchQuery: _chatController.query.value,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? const Color(0xFF102437)
                  : const Color.fromARGB(255, 247, 253, 255),
          body: StreamMessageSearchListView(
            controller: StreamMessageSearchListController(
              client: widget.client,
              limit: 20,
              filter: Filter.in_(
                'members',
                [StreamChat.of(context).currentUser!.id],
              ),
              searchQuery: _chatController.query.value,
            ),
          ),
        ));
  }
}
