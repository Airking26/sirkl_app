import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirkl/common/controller/common_controller.dart';
import 'package:sirkl/common/model/sign_in_success_dto.dart';
import 'package:sirkl/common/view/stream_chat/stream_chat_flutter.dart';
import 'package:sirkl/home/controller/home_controller.dart';

import '../../../../../global_getx/home/home_controller.dart';

/// It shows the current [Channel] name using a [Text] widget.
///
/// The widget uses a [StreamBuilder] to render the channel information
/// image as soon as it updates.
class StreamChannelName extends StatelessWidget {
  /// Instantiate a new ChannelName
  StreamChannelName({
    super.key,
    required this.channel,
    this.textStyle,
    this.textOverflow = TextOverflow.ellipsis,
  }) : assert(
          channel.state != null,
          'Channel ${channel.id} is not initialized',
        );

  /// The [Channel] to show the name for.
  final Channel channel;

  /// The style of the text displayed
  final TextStyle? textStyle;

  /// How visual overflow should be handled.
  final TextOverflow textOverflow;

 HomeController get _homeController => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) => BetterStreamBuilder<String>(
        stream: channel.nameStream,
        initialData: channel.name,
        builder: (context, channelName) => Text(
          channelName,
          style: textStyle!.copyWith(fontSize: 16),
          overflow: textOverflow,
        ),
        noDataBuilder: (context) => _generateName(
          channel.client.state.currentUser!,
          channel.state!.members,
        ),
      );

  Widget _generateName(
    User currentUser,
    List<Member> members,
  ) =>
      LayoutBuilder(
        builder: (context, constraints) {
          var channelName = context.translations.noTitleText;
          final otherMembers = members.where((member) => member.userId != currentUser.id,);

          if (otherMembers.isNotEmpty) {
            if (otherMembers.length == 1) {
              final user = otherMembers.first.user;
              if (user != null) {
                var userDTO = userFromJson(json.encode(user.extraData["userDTO"]));
                channelName = _homeController.nicknames[userDTO.wallet!] != null ?
                _homeController.nicknames[userDTO.wallet!] + " (" + (userDTO.userName.isNullOrBlank! ? "${userDTO.wallet!.substring(0, 6)}...${userDTO.wallet!.substring(userDTO.wallet!.length - 4)}" : userDTO.userName!) + ")"
                    : (userDTO.userName.isNullOrBlank! ? "${userDTO.wallet!.substring(0, 6)}...${userDTO.wallet!.substring(userDTO.wallet!.length - 4)}": userDTO.userName!);
              }
            } else {
              channelName = channel.extraData['nameOfGroup'] as String;
            }
          } else {
            if(channel.extraData["isGroupPaying"] != null && channel.extraData["isGroupPaying"] == true){
              channelName = channel.extraData["nameOfGroup"] as String;
            }
            else if(channel.extraData['ens'] == null || channel.extraData['ens'] == "0") {
              channelName = "${(channel.extraData['wallet'] as String).substring(0, 6)}...${(channel.extraData['wallet'] as String).substring((channel.extraData['wallet'] as String).length - 4)}";
            } else {
              channelName = channel.extraData["ens"] as String;
            }
          }

          return Row(
            children: [
              Text(
                channelName ,
                style: textStyle!.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                overflow: textOverflow,
              ),
              channel.extraData["isGroupPrivate"] != null && channel.extraData["isGroupPrivate"] == true ? Icon(Icons.lock_outline_rounded, size: 14, color: const Color(0xff00CB7D).withOpacity(0.7),) : const SizedBox(),
              channel.extraData["isGroupPaying"] != null && channel.extraData["isGroupPaying"] == true ? Icon(Icons.attach_money_rounded, size: 16, color: const Color(0xff00CB7D).withOpacity(0.7)) : const SizedBox(),
            ],
          );
        },
      );
}
