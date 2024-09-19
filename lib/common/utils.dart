import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:sirkl/controllers/home_controller.dart';
import 'package:sirkl/models/sign_in_success_dto.dart';
import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

void showToast(BuildContext context, String message) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.removeCurrentSnackBar();
  scaffold.showSnackBar(
    SnackBar(
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF102437),
      content: Text(
        message,
        textAlign: TextAlign.start,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: "Gilroy",
            fontSize: 15,
            color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? const Color(0xFF102437)
                : Colors.white),
      ),
      //action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
    ),
  );
}

String displayName(UserDTO user, HomeController controller) {
  if (controller.nicknames[user.wallet] != null &&
      controller.nicknames[user.wallet]!.isNotEmpty) {
    if (user.userName != null && user.userName!.isNotEmpty) {
      return controller.nicknames[user.wallet] + " (" + user.userName + ")";
    } else {
      return controller.nicknames[user.wallet] +
          " (" +
          user.wallet!.substring(0, 6) +
          "..." +
          user.wallet!.substring(user.wallet!.length - 4) +
          ")";
    }
  } else {
    if (user.userName == null || user.userName!.isEmpty) {
      return "${user.wallet!.substring(0, 6)}...${user.wallet!.substring(user.wallet!.length - 4)}";
    } else {
      return user.userName!;
    }
  }
}

Future<void> showCallNotification(Map<String, dynamic> data) async {
  var params = CallKitParams(
      id: data['uuid'],
      nameCaller: data["title"],
      appName: 'Sirkl',
      avatar: data["pic"] ??
          'https://sirkl-bucket.s3.eu-central-1.amazonaws.com/app_icon_rounded.png',
      handle: data["body"],
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(showNotification: false),
      extra: <String, dynamic>{
        'userCalling': data["caller_id"],
        "userCalled": data['called_id'],
        "callId": data["call_id"],
        "channel": data["channel"]
      },
      android: const AndroidParams(
          isCustomNotification: false,
          isCustomSmallExNotification: false,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#102437',
          actionColor: '#4CAF50'),
      ios: const IOSParams(
          iconName: 'CallKitLogo',
          handleType: '',
          supportsVideo: false,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtonePath: 'system_ringtone_default'));

  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

bool isSolanaAddress(String address) {
  final solanaAddressRegex = RegExp(r'^[A-HJ-NP-Za-km-z1-9]{32,48}$');
  return solanaAddressRegex.hasMatch(address);
}

bool isEthereumAddress(String address) {
  final ethAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
  return ethAddressRegex.hasMatch(address);
}

SortOption<ChannelState> get byLastMessageAt => SortOption<ChannelState>(
      'last_message_at',
      comparator: (a, b) =>
          b.channel?.lastMessageAt
              ?.compareTo(a.channel?.lastMessageAt ?? DateTime(0)) ??
          0,
    );

SortOption<ChannelState> get byUpdatedAt => SortOption<ChannelState>(
      'updated_at',
      comparator: (a, b) =>
          b.channel?.updatedAt.compareTo(a.channel?.updatedAt ?? DateTime(0)) ??
          0,
    );
